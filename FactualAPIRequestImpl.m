//
//  FactualAPIRequest.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualAPIRequestImpl.h"
#import "FactualAPI.h"
#import "CJSONDeserializer.h"
#import "FactualQueryResultImpl.h"
#import "FactualAPIPrivate.h"
#import "FactualSchemaResultImpl.h"
#import <CommonCrypto/CommonHMAC.h>
#import "FactualBase64Transcoder.h"

static long _lastRequestId = 0;

static NSString* kUserAgent = @"Factual-IPhoneSDK-V-1.3.5";
static NSString* kFactualLibHeader = @"X-Factual-Lib";
static NSString* kFactualLibHeaderSDKValue = @"Factual-IPhoneSDK-V-1.3.5";


#pragma mark FactualOASupport
//////////////////////////////////////////////////////////////////////////////////////////////////
// Factual OAuth Support Routines
//////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* kFactualSignatureProvider = @"HMAC-SHA1";

static NSString* Factual_URLEncodedString(NSString* inputString) {
  NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                           (__bridge CFStringRef)inputString,
                                                                                           NULL,
                                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                           kCFStringEncodingUTF8);
	return result;
}

static NSString* Factual_signClearText(NSString* text, NSString* secret) {
  NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
  NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
  unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
  
  //Base64 Encoding
  
  char base64Result[32];
  size_t theResultLength = 32;
  FactualBase64EncodeData(result, 20, base64Result, &theResultLength);
  NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
  
  NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
  
  return base64EncodedResult;
}
#pragma mark -

#pragma mark FactualOARequestParameter
//////////////////////////////////////////////////////////////////////////////////////////////////
// FactualOARequestParameter
//////////////////////////////////////////////////////////////////////////////////////////////////
@interface FactualOARequestParameter : NSObject {
@protected
  NSString *name;
  NSString *value;
}
@property(retain) NSString *name;
@property(retain) NSString *value;

+ (id)requestParameterWithName:(NSString *)aName value:(NSString *)aValue;
- (id)initWithName:(NSString *)aName value:(NSString *)aValue;
- (NSString *)URLEncodedName;
- (NSString *)URLEncodedValue;
- (NSString *)URLEncodedNameValuePair;

@end

@implementation FactualOARequestParameter
@synthesize name, value;

+ (id)requestParameterWithName:(NSString *)aName value:(NSString *)aValue
{
	return [[FactualOARequestParameter alloc] initWithName:aName value:aValue];
}

- (id)initWithName:(NSString *)aName value:(NSString *)aValue
{
  if (self = [super init])
    {
		self.name = aName;
		self.value = aValue;
    }
  return self;
}

- (NSString *)URLEncodedName
{
	return Factual_URLEncodedString(self.name);
}

- (NSString *)URLEncodedValue
{
  return Factual_URLEncodedString(self.value);
}

- (NSString *)URLEncodedNameValuePair
{
  return [NSString stringWithFormat:@"%@=%@", [self URLEncodedName], [self URLEncodedValue]];
}

@end
#pragma mark -

#pragma mark FactualOAMutableURLRequest

//////////////////////////////////////////////////////////////////////////////////////////////////
// FactualOAMutableURLRequest
//////////////////////////////////////////////////////////////////////////////////////////////////
@interface FactualOAMutableURLRequest : NSMutableURLRequest

@property (copy) NSString* consumerKey;
@property (copy) NSString* consumerSecret;
@property (retain) NSString *nonce;
@property (retain) NSString *timestamp;


- (id) initWithURL:(NSURL *)URL consumerKey:(NSString*)key consumerSecret:(NSString*)secret;
- (NSArray *)parameters;
- (void)setParameters:(NSArray *)parameters;

@end

@implementation FactualOAMutableURLRequest

@synthesize consumerKey,consumerSecret,nonce,timestamp;

- (void)_generateTimestamp
{
  timestamp = [NSString stringWithFormat:@"%ld", time(NULL)];
}

- (void)_generateNonce
{
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  nonce = (__bridge_transfer NSString *) CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
}

- (id) initWithURL:(NSURL *)theURL consumerKey:(NSString*)key consumerSecret:(NSString*)secret {
  if (self = [super initWithURL:theURL
                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                timeoutInterval:10.0]) {
    
    self.consumerKey = key;
    self.consumerSecret = secret;
    
    [self _generateTimestamp];
		[self _generateNonce];
    
  }
  return self;
}

- (NSArray *)parameters {
  NSString *encodedParameters;
  
  if ([[self HTTPMethod] isEqualToString:@"GET"] || [[self HTTPMethod] isEqualToString:@"DELETE"])
    encodedParameters = [[self URL] query];
	else
    {
    // POST, PUT
    encodedParameters = [[NSString alloc] initWithData:[self HTTPBody] encoding:NSASCIIStringEncoding];
    }
  
  if ((encodedParameters == nil) || ([encodedParameters isEqualToString:@""]))
    return nil;
  
  NSArray *encodedParameterPairs = [encodedParameters componentsSeparatedByString:@"&"];
  NSMutableArray *requestParameters = [[NSMutableArray alloc] initWithCapacity:16];
  
  for (NSString *encodedPair in encodedParameterPairs)
    {
    NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
    FactualOARequestParameter *parameter = [FactualOARequestParameter requestParameterWithName:[[encodedPairElements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                                         value:[[encodedPairElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [requestParameters addObject:parameter];
    }
  
  return requestParameters;
}

static NSString* Factual_URLStringWithoutQuery(NSURL* url) {
  NSArray *parts = [[url absoluteString] componentsSeparatedByString:@"?"];
  return [parts objectAtIndex:0];
}


- (void)setParameters:(NSArray *)parameters
{
  NSMutableString *encodedParameterPairs = [NSMutableString stringWithCapacity:256];
  
  int position = 1;
  for (FactualOARequestParameter *requestParameter in parameters)
    {
    [encodedParameterPairs appendString:[requestParameter URLEncodedNameValuePair]];
    if (position < [parameters count])
      [encodedParameterPairs appendString:@"&"];
		
    position++;
    }
  
  if ([[self HTTPMethod] isEqualToString:@"GET"] || [[self HTTPMethod] isEqualToString:@"DELETE"])
    [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", Factual_URLStringWithoutQuery([self URL]), encodedParameterPairs]]];
  else
    {
    // POST, PUT
    NSData *postData = [encodedParameterPairs dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [self setHTTPBody:postData];
    [self setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
}

- (NSString *)_signatureBaseString
{
  // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
  // build a sorted array of both request parameters and OAuth header parameters
  NSMutableArray *parameterPairs = [NSMutableArray  arrayWithCapacity:(6 + [[self parameters] count])]; // 6 being the number of OAuth params in the Signature Base String
  
	[parameterPairs addObject:[[FactualOARequestParameter requestParameterWithName:@"oauth_consumer_key" value:self.consumerKey] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[FactualOARequestParameter requestParameterWithName:@"oauth_signature_method" value:kFactualSignatureProvider] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[FactualOARequestParameter requestParameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[FactualOARequestParameter requestParameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[FactualOARequestParameter requestParameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
  
  for (FactualOARequestParameter *param in [self parameters]) {
    [parameterPairs addObject:[param URLEncodedNameValuePair]];
  }
  
  NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
  NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
  
  // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
  NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
                   [self HTTPMethod],
                   Factual_URLEncodedString(Factual_URLStringWithoutQuery([self URL])),
                   Factual_URLEncodedString(normalizedRequestParameters)];
	
	return ret;
}


- (void)prepare
{
  // sign
	// Secrets must be urlencoded before concatenated with '&'
	// TODO: if later RSA-SHA1 support is added then a little code redesign is needed
  NSString* signature = Factual_signClearText([self _signatureBaseString],
                                              [NSString stringWithFormat:@"%@&%@",
                                               Factual_URLEncodedString(self.consumerSecret),
                                               @""]);
  
  NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"%@\", oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"%@",
                           @"", // realm
                           Factual_URLEncodedString(self.consumerKey),
                           @"",
                           Factual_URLEncodedString(kFactualSignatureProvider),
                           Factual_URLEncodedString(signature),
                           timestamp,
                           nonce,
                           @""];
	
  [self setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
}


@end
#pragma mark -

#pragma mark FactualAPIRequestImpl

//////////////////////////////////////////////////////////////////////////////////////////////////
// FactualAPIRequestImpl
//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FactualAPIRequestImpl

@synthesize url=_url,delegate=_delegate,requestId=_requestId,requestType=_requestType,tableId=_tableId,timeoutInterval=_timeoutInterval;

//////////////////////////////////////////////////////////////////////////////////////////////////
// internal helpers ...
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void) generateErrorCallback: (NSString*) errorString {
#ifdef TARGET_IPHONE_SIMULATOR
  NSLog(@"generateErrorCallback:%@ error:%@",_requestId,errorString);
#endif
  if ([_delegate respondsToSelector:@selector(requestComplete:failedWithError:)]) {
    NSError* error = [NSError errorWithDomain:@"FactualCoreErrorDomain"
                                         code:0
                                     userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                          forKey:NSLocalizedDescriptionKey]];
    
    [_delegate requestComplete:self failedWithError:error];
  }
  [self cancel];
}



//////////////////////////////////////////////////////////////////////////////////////////////////
// places query response handler ...
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void) parseQueryResponse:(NSDictionary*) jsonResponse {
  if (jsonResponse != nil) {
      FactualQueryResult* queryResult = [FactualQueryResultImpl queryResultFromJSON:jsonResponse deprecated:false];
    
    if (queryResult != nil) {
      if ([_delegate respondsToSelector:@selector(requestComplete:receivedQueryResult:)]) {
        [_delegate requestComplete:self receivedQueryResult:queryResult];
      }
      return;
    }
  }
  [self generateErrorCallback:@"Unable to create Response Object from Query Response!"];
}

-(void) parseRowFetchResponse:(NSDictionary*) jsonResponse statusCode:(int)statusCode {
    if (jsonResponse != nil) {
        FactualQueryResult* queryResult = [FactualQueryResultImpl queryResultFromJSON:jsonResponse deprecated: statusCode == 301];
        
        if (queryResult != nil) {
            if ([_delegate respondsToSelector:@selector(requestComplete:receivedQueryResult:)]) {
                [_delegate requestComplete:self receivedQueryResult:queryResult];
            }
            return;
        }
    }
    [self generateErrorCallback:@"Unable to create Response Object from Query Response!"];
}

-(void) parseMatchQueryResponse:(NSDictionary*) jsonResponse {
  if (jsonResponse != nil) {
    NSArray* data = [jsonResponse objectForKey:@"data"];
    NSString* factualId = nil;
    if ([data count] > 0) {
      factualId = [[data objectAtIndex:0] objectForKey:@"factual_id"];
    }
    if ([_delegate respondsToSelector:@selector(requestComplete:receivedMatchResult:)]) {
      [_delegate requestComplete:self receivedMatchResult:factualId];
    }
    return;
  }
  [self generateErrorCallback:@"Unable to create Response Object from Query Response!"];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// raw request query response handler ...
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void) parseRawRequestResponse:(NSDictionary*) jsonResponse {
  if (jsonResponse != nil) {
    if ([_delegate respondsToSelector:@selector(requestComplete:receivedRawResult:)]) {
      [_delegate requestComplete:self receivedRawResult:jsonResponse];
    }
    return;
  }
  [self generateErrorCallback:@"Unable to create Response Object from Query Response!"];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// internal helpers
//////////////////////////////////////////////////////////////////////////////////////////////////

/*
-(NSURLConnection*) buildConnection:(NSString*) payload {
  NSMutableURLRequest* request =
  
  [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                      timeoutInterval:kTimeoutInterval];
  
  [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
  [request setValue:kFactualLibHeaderSDKValue forHTTPHeaderField:kFactualLibHeader];
  
  if (payload != nil) {
    _httpMethod = @"POST";
  }
  
  [request setHTTPMethod:_httpMethod];
  
  if (payload != nil) {
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  return [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
*/


-(NSURLConnection*) buildOAuthConnection:(NSString*) key
                          consumerSecret:(NSString*) secret
                                 payload:(NSString*) payload
                           requestMethod: (NSString*) requestMethod {
  
  
  
  
  FactualOAMutableURLRequest* request = [[FactualOAMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_url] consumerKey:key consumerSecret:secret];
  
  
  [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
  [request setTimeoutInterval:_timeoutInterval];
  [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
  [request setValue:kFactualLibHeaderSDKValue forHTTPHeaderField:kFactualLibHeader];
  
  _httpMethod = requestMethod;
  
  [request setHTTPMethod:_httpMethod];
  
  if (payload != nil) {
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  // prepare the url
  [request prepare];
  
  return [[NSURLConnection alloc] initWithRequest:request delegate:self];
}




// helper to generate NSError from error response ...
-(void) generateErrorCallbackFromServerError:(NSDictionary*) jsonResp {
  NSString *errorMessage = (
                            ([jsonResp objectForKey:@"message"]!= nil) ? [jsonResp objectForKey:@"message"] : @"Unable to parse response");
  
  return [self generateErrorCallback:errorMessage];
}




-(void) handleResponseData:(NSData*) responsePayload statusCode:(int) statusCode {
  //NSLog(@"NSURLConnection handleResponseData:%@ URL:%@\nPayload:%@",
  //        _requestId,[_url description],[[[NSString alloc]initWithData:responsePayload encoding:NSASCIIStringEncoding] autorelease] );
  
  // ok get ready to parse the response ...
  NSError* error = nil;
  // construct parser ...
  CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
  
  // parse the json
  NSDictionary *jsonResp = [deserializer deserialize:responsePayload error:&error];
  
  // check for errors ...
	if (jsonResp == nil
      || error != nil
      || [jsonResp objectForKey:@"status"] == nil
      ) {
    // call delegate here ...
    NSString *errorMessage = (error ? [error localizedDescription] : @"Unable to parse response");
    
    [self generateErrorCallback:errorMessage];
    
    return;
  }
  // ok check status field next ...
  if ([[jsonResp objectForKey:@"status"] caseInsensitiveCompare:@"ok"] != 0) {
    [self generateErrorCallbackFromServerError:jsonResp];
    return;
  }
  // next do request specific parsing ...
  switch (_requestType) {
    case FactualRequestType_PlacesQuery: {
      [self parseQueryResponse:[jsonResp objectForKey:@"response"]];
    }
      break;
    case FactualRequestType_FacetQuery: {
      [self parseQueryResponse:[jsonResp objectForKey:@"response"]];
    }
      break;
    case FactualRequestType_RawRequest: {
      [self parseRawRequestResponse:jsonResp];
    }
      break;
    case FactualRequestType_ResolveQuery: {
      [self parseQueryResponse:[jsonResp objectForKey:@"response"]];
    }
      break;
    case FactualRequestType_MatchQuery: {
      [self parseMatchQueryResponse:[jsonResp objectForKey:@"response"]];
    }
      break;
    case FactualRequestType_SchemaQuery: {
      [self parseRawRequestResponse:[jsonResp objectForKey:@"response"]];
    }
      break;
    case FactualRequestType_FetchRowQuery: {
        [self parseRowFetchResponse:[jsonResp objectForKey:@"response"] statusCode:statusCode];
    }
      break;
    default: {
      [NSException raise:NSGenericException format:@"Unknown Request Type!"];
    }
      break;
  }
  [self cancel];
}



//////////////////////////////////////////////////////////////////////////////////////////////////
// init / dealloc
//////////////////////////////////////////////////////////////////////////////////////////////////

/*
-(id) initWithURL:(NSString *) theURL
      requestType:(NSInteger) theRequestType
  optionalTableId:(NSString*) tableId
     withDelegate:(id<FactualAPIDelegate>) theDelegate
    withAPIObject:(id) theAPIObject
  optionalPayload:(NSString*) payload

{
  if ( self = [super init]) {
    _url = [theURL copy];
    _requestType = theRequestType;
    _delegate = theDelegate;
    _tableId  = tableId;
    _httpMethod = @"GET";
    _responseText = nil;
    @synchronized(@"FactualAPIRequestImpl") {
      _requestId = [[NSNumber numberWithLong:++_lastRequestId] stringValue];
    }
    _connection = [self buildConnection:payload];
  }
  return self;
}
*/
-(id) initOAuthRequestWithURL:(NSString *) theURL
                  requestType:(NSInteger) theRequestType
              optionalTableId:(NSString*) tableId
                 withDelegate:(id<FactualAPIDelegate>) theDelegate
                withAPIObject:(id) theAPIObject
              optionalPayload:(NSString*) payload
                  consumerKey:(NSString*) consumerKey
               consumerSecret:(NSString*) consumerSecret
                requestMethod:(NSString*) requestMethod
              timeoutInterval:(NSTimeInterval) timeoutInterval {
  
  if ( self = [super init]) {
    _url = [theURL copy];
    _requestType = theRequestType;
    _delegate = theDelegate;
    _tableId  = tableId;
    _httpMethod = requestMethod;
    _responseText = nil;
    _timeoutInterval = timeoutInterval;

    @synchronized(@"FactualAPIRequestImpl") {
      _requestId = [[NSNumber numberWithLong:++_lastRequestId] stringValue];
    }
    _connection = [self buildOAuthConnection:consumerKey consumerSecret:consumerSecret payload:payload requestMethod: requestMethod];
  }
  return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// FactualAPIRequestImplementation
//////////////////////////////////////////////////////////////////////////////////////////////////

-(void) cancel {
  if (_responseText != nil) {
    _responseText = nil;
  }
  if (_connection != nil) {
    [_connection cancel];
    _connection = nil;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  //NSLog(@"NSURLConnection:%@ URL:%@ Did Receive Response",_requestId,_url);
  _responseText = [[NSMutableData alloc] init];
  if ([response isKindOfClass: [NSHTTPURLResponse class]])
    _statusCode = [(NSHTTPURLResponse*) response statusCode];
  if ([_delegate respondsToSelector:@selector(requestDidReceiveInitialResponse:)]) {
    [_delegate requestDidReceiveInitialResponse:self];
  }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  //NSLog(@"NSURLConnection:%@ URL:%@ Did Receive Data",_requestId,_url);
  [_responseText appendData:data];
  if ([_delegate respondsToSelector:@selector(requestDidReceiveData:)]) {
    [_delegate requestDidReceiveData:self];
  }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
  return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#ifdef TARGET_IPHONE_SIMULATOR
  NSLog(@"NSURLConnection:%@ URL:%@ Finished Loading",_requestId,_url);
#endif
    [self handleResponseData:_responseText statusCode: _statusCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#ifdef TARGET_IPHONE_SIMULATOR
  NSLog(@"NSURLConnection:%@ URL: returned Error:%@",_url,[error localizedDescription]);
#endif
  if ([_delegate respondsToSelector:@selector(requestComplete:failedWithError:)]) {
    [_delegate requestComplete:self failedWithError:error];
  }
  [self cancel];
}

@end

#pragma mark -
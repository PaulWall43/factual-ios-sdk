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
#import "OAMutableURLRequest.h"

static long _lastRequestId = 0;

static const NSTimeInterval kTimeoutInterval = 180.0;
static NSString* kUserAgent = @"Factual-IPhoneSDK-V-1.0";
static NSString* kFactualLibHeader = @"X-Factual-Lib";
static NSString* kFactualLibHeaderSDKValue = @"factual--iPhone-SDK-1.0";



@implementation FactualAPIRequestImpl

@synthesize url=_url,delegate=_delegate,requestId=_requestId,requestType=_requestType,tableId=_tableId;


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
-(void) parsePlacesQueryResponse:(NSDictionary*) jsonResponse {
  if (jsonResponse != nil) {
    
    FactualQueryResult* queryResult = [FactualQueryResultImpl queryResultFromPlacesJSON:jsonResponse];
    
    if (queryResult != nil) {
      if ([_delegate respondsToSelector:@selector(requestComplete:receivedQueryResult:)]) {
        [_delegate requestComplete:self receivedQueryResult:queryResult];
      }
      return;
    }
  }
  [self generateErrorCallback:@"Unable to create Response Object from Query Response!"];
}




//////////////////////////////////////////////////////////////////////////////////////////////////
// internal helpers 
//////////////////////////////////////////////////////////////////////////////////////////////////

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

-(NSURLConnection*) buildOAuthConnection:(NSString*) consumerKey 
                         consumerSecret:(NSString*) consumerSecret
                                 payload:(NSString*) payload {
  OAConsumer* consumer = [[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]autorelease];
  
  OAMutableURLRequest* request = [[[OAMutableURLRequest alloc ]initWithURL:[NSURL URLWithString:_url]
                                                                 consumer:consumer
                                                                    token:nil
                                                                    realm:nil
                                                        signatureProvider:nil] autorelease];

  [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
  [request setTimeoutInterval:kTimeoutInterval];
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
  
  // prepare the url 
  [request prepare];
  
  return [[NSURLConnection alloc] initWithRequest:request delegate:self];
}




// helper to generate NSError from error response ... 
-(void) generateErrorCallbackFromServerError:(NSDictionary*) jsonResp {
  NSString *errorMessage = (
                            ([jsonResp objectForKey:@"error"]!= nil) ? [jsonResp objectForKey:@"error"] : @"Unable to parse response");
  
  return [self generateErrorCallback:errorMessage];
}




-(void) handleResponseData:(NSData*) responsePayload {
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
      [self parsePlacesQueryResponse:[jsonResp objectForKey:@"response"]];
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


-(id) initWithURL:(NSString *) theURL
      requestType:(NSInteger) theRequestType
  optionalTableId:(NSString*) tableId
      withDelegate:(id<FactualAPIDelegate>) theDelegate
      withAPIObject:(id) theAPIObject
      optionalPayload:(NSString*) payload

{
  if ( self = [super init]) {
    _url = [[theURL copy ]retain];
    _requestType = theRequestType;
    _apiObject = theAPIObject;
    _delegate = [theDelegate retain];
    _tableId  = [tableId retain];
    _httpMethod = @"GET";
    _responseText = nil;
    @synchronized(@"FactualAPIRequestImpl") {
      _requestId = [[[NSNumber numberWithLong:++_lastRequestId] stringValue] retain];
    }
    _connection = [self buildConnection:payload];
  }
  return self;
}

-(id) initOAuthRequestWithURL:(NSString *) theURL
                  requestType:(NSInteger) theRequestType
              optionalTableId:(NSString*) tableId
                 withDelegate:(id<FactualAPIDelegate>) theDelegate
                withAPIObject:(id) theAPIObject
              optionalPayload:(NSString*) payload
                  consumerKey:(NSString*) consumerKey
              consumerSecret:(NSString*) consumerSecret { 

  if ( self = [super init]) {
    _url = [[theURL copy ]retain];
    _requestType = theRequestType;
    _apiObject = theAPIObject;
    _delegate = [theDelegate retain];
    _tableId  = [tableId retain];
    _httpMethod = @"GET";
    _responseText = nil;
    @synchronized(@"FactualAPIRequestImpl") {
      _requestId = [[[NSNumber numberWithLong:++_lastRequestId] stringValue] retain];
    }
    _connection = [self buildOAuthConnection:consumerKey consumerSecret:consumerSecret payload:payload];
  }
  return self;
}


- (void)dealloc {
  [self cancel];
  [_requestId release];
  [_tableId release];
  [_delegate release];
  [_connection cancel];
  [_connection release];
  [_url release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// FactualAPIRequestImplementation
//////////////////////////////////////////////////////////////////////////////////////////////////

-(void) cancel {
  if (_responseText != nil) {
    [_responseText release];
    _responseText = nil;
  }
  if (_apiObject != nil) {
    [((FactualAPI*)_apiObject) releaseRequest:self];
    _apiObject = nil;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  //NSLog(@"NSURLConnection:%@ URL:%@ Did Receive Response",_requestId,_url);
  _responseText = [[NSMutableData alloc] init];

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
  [self handleResponseData:_responseText];
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
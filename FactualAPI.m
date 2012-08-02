//
//  FactualAPI.m
//  FactualCore
//
//  Created by Ahad Rana on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FactualAPI.h"
#import "FactualAPIHelper.h"
#import "FactualAPIRequestImpl.h"
#import "FactualAPIPrivate.h"
#import "CJSONSerializer.h"
#import "NSString (Escaping).h"
#import "FactualGeopulse.h"
#import "FactualGeopulseImpl.h"
#import "FactualResolve.h" 
#import "FactualResolveImpl.h" 
#import "FactualSubmit.h" 
#import "FactualSubmitImpl.h" 
#import "FactualMetadata.h" 
#import "FactualMetadataImpl.h" 
#import "FactualMatchQuery.h" 
#import "FactualMatchQueryImpl.h" 
#import "FactualUrlUtil.h" 


NSString *const FactualCoreErrorDomain = @"FactualCoreErrorDomain";


@implementation FactualAPI

@synthesize factualHome =_factualHome;
@synthesize apiKey = _apiKey;
@synthesize debug = _debug;
@dynamic apiVersion;

-(id) initWithAPIKey:(NSString*) apiKey secret:(NSString *)secret{
    if (self = [super init]) {
        _apiKey = apiKey;
        _secret = [secret copy];
        _factualHome = @"http://api.v3.factual.com";
    }
    return self;
}


- (FactualAPIRequest*) allocateOAuthRequest:(NSString*) urlStr
                                requestType:(NSInteger)theRequestType 
                            optionalTableId:(NSString*)tableId
                               withDelegate:(id<FactualAPIDelegate>) delegate
                            optionalPayload:(NSString*) payload
                              requestMethod: (NSString*) requestMethod {
    
    // build the request object ...
    FactualAPIRequestImpl* requestObject 
    = [[FactualAPIRequestImpl alloc] initOAuthRequestWithURL:urlStr 
                                                 requestType:theRequestType  
                                             optionalTableId:tableId
                                                withDelegate:delegate
                                               withAPIObject:self
                                             optionalPayload:payload
                                                 consumerKey:_apiKey
                                              consumerSecret:_secret
                                               requestMethod: requestMethod];
    
    return requestObject;
}

- (FactualAPIRequest*)   get:(NSString*) path  
                      params:(NSDictionary*) params
                withDelegate:(id<FactualAPIDelegate>) delegate { 
    
	NSMutableString *qry = [[NSMutableString alloc] initWithFormat:path];
    [qry appendString:@"?"];
    
    for(id key in params) {
        [qry appendString:key];
        [qry appendString:@"="];
        NSString* escapedParamValue = (__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)[params objectForKey:key],NULL,CFSTR("?=&+"),kCFStringEncodingUTF8);
        [qry appendString:escapedParamValue];
    }
    NSString* urlStr = [self createRequestString: qry];
    
    return [self sendRequest: urlStr ofType: FactualRequestType_RawRequest requestMethod:@"GET" payload: nil withDelegate: delegate];
}

- (FactualAPIRequest*)   geopulse:(FactualGeopulse*) geopulse
                     withDelegate:(id<FactualAPIDelegate>) delegate { 
    
	NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"places/geopulse?"];
    [(FactualGeopulseImpl*)geopulse generateQueryString:qry];
    return [self request:qry ofType: FactualRequestType_PlacesQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   reverseGeocode:(CLLocationCoordinate2D) location
                           withDelegate:(id<FactualAPIDelegate>) delegate { 
	NSMutableString *queryString = [[NSMutableString alloc] initWithFormat:@"places/geocode?"];
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:1];
    [params addObject:[NSString stringWithFormat:@"geo=%@", [FactualUrlUtil locationToJson: location]]];
    [FactualUrlUtil appendParams:params to:queryString];
    return [self request:queryString ofType: FactualRequestType_PlacesQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   monetize:(FactualQuery*) queryParams
                     withDelegate:(id<FactualAPIDelegate>) delegate { 
    NSString* queryString = [FactualAPIHelper buildQueryString:((_secret == nil) ? _apiKey: nil) path:@"places/monetize" queryParams:queryParams];
    return [self request:queryString ofType: FactualRequestType_PlacesQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                      resolveParams:(FactualResolve*) resolve
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    NSString *qryPath = [[NSString alloc] initWithFormat:@"%@/resolve", tableId];
	NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"%@?", qryPath];
    [(FactualResolveImpl*) resolve generateQueryString:queryStr];
    return [self request:queryStr ofType: FactualRequestType_ResolveQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                        matchParams:(FactualMatchQuery*) match
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    NSString *qryPath = [[NSString alloc] initWithFormat:@"%@/match", tableId];
	NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"%@?", qryPath];
    [(FactualMatchQueryImpl*) match generateQueryString:queryStr];
    return [self request:queryStr ofType: FactualRequestType_MatchQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                optionalQueryParams:(FactualQuery*) queryParams
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    // build a query string using query object and table id
    NSString* queryStr = [FactualAPIHelper buildPlacesQueryString:((_secret == nil) ? _apiKey: nil) tableId:tableId queryParams:queryParams];
    return [self request:queryStr ofType: FactualRequestType_PlacesQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}


- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                        facetParams:(FactualFacetQuery*) facet
                       withDelegate:(id<FactualAPIDelegate>) delegate {
    // build a query string using query object and table id
    NSString* queryStr = [FactualAPIHelper buildPlacesQueryString:((_secret == nil) ? _apiKey: nil) tableId:tableId facetParams:facet];
    return [self request:queryStr ofType: FactualRequestType_FacetQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (NSString*)   createRequestString:(NSString*) path {
    return [NSString stringWithFormat:@"%@/%@", _factualHome, path];
}

- (FactualAPIRequest*)   request:(NSString*) queryStr ofType:(NSInteger)theRequestType requestMethod: (NSString*) requestMethod payload:payload withDelegate:(id<FactualAPIDelegate>) delegate { 
    // build url .. 
    NSString* urlStr = [self createRequestString: queryStr];
    if (_debug) {
        NSLog(@"Url: %@", urlStr);
        NSLog(@"Request Method: %@", requestMethod);
        NSLog(@"Payload: %@", payload);
    }
    return [self sendRequest: urlStr ofType: theRequestType requestMethod:requestMethod payload:payload withDelegate: delegate];
}

- (FactualAPIRequest*)   sendRequest:(NSString*) urlStr ofType:(NSInteger)theRequestType requestMethod: (NSString*) requestMethod payload:(NSString*) payload withDelegate:(id<FactualAPIDelegate>) delegate { 
#ifdef TARGET_IPHONE_SIMULATOR
    NSLog(@"using OAuth Request for Places Request");
#endif
    
    return [self allocateOAuthRequest:urlStr
                          requestType:theRequestType 
                      optionalTableId:nil
                         withDelegate:delegate 
                      optionalPayload:payload
                        requestMethod: requestMethod];
}

- (FactualAPIRequest*) submit:(NSString*) tableId
                 submitParams: (FactualSubmit*) submit 
                     metadata:(FactualMetadata*) metadata
                 withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"t/%@/submit", tableId];
    FactualSubmitImpl* submitImpl = (FactualSubmitImpl*)submit;
    NSMutableString *payload = [[NSMutableString alloc] init];
    [(FactualMetadataImpl*)metadata generateQueryString:payload];
    [payload appendString: @"&"];
    [submitImpl generateQueryString:payload];
    return [self request:queryStr ofType: FactualRequestType_RawRequest requestMethod:@"POST" payload: payload withDelegate:delegate];
}

- (FactualAPIRequest*) submit:(NSString*) tableId
                    factualId: (NSString*) factualId
                 submitParams: (FactualSubmit*) submit
                     metadata:(FactualMetadata*) metadata
                 withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"t/%@/%@/submit", tableId, factualId];
    FactualSubmitImpl* submitImpl = (FactualSubmitImpl*)submit;
    NSMutableString *payload = [[NSMutableString alloc] init];
    [(FactualMetadataImpl*)metadata generateQueryString:payload];
    [payload appendString: @"&"];
    [submitImpl generateQueryString:payload];
    return [self request:queryStr ofType: FactualRequestType_RawRequest requestMethod:@"POST" payload: payload withDelegate:delegate];
}


- (FactualAPIRequest*) flagDuplicate:(NSString*) tableId
                           factualId: (NSString*) factualId
                            metadata:(FactualMetadata*) metadata
                        withDelegate:(id<FactualAPIDelegate>) delegate {
    return [self flagProblem: @"duplicate" tableId: tableId factualId: factualId metadata: metadata withDelegate: delegate];
}

- (FactualAPIRequest*) flagInaccurate:(NSString*) tableId
                            factualId: (NSString*) factualId
                             metadata:(FactualMetadata*) metadata
                         withDelegate:(id<FactualAPIDelegate>) delegate {
    return [self flagProblem: @"inaccurate" tableId: tableId factualId: factualId metadata: metadata withDelegate: delegate];
}

- (FactualAPIRequest*) flagInappropriate:(NSString*) tableId
                               factualId: (NSString*) factualId
                                metadata:(FactualMetadata*) metadata
                            withDelegate:(id<FactualAPIDelegate>) delegate {
    return [self flagProblem: @"inappropriate" tableId: tableId factualId: factualId metadata: metadata withDelegate: delegate];
}

- (FactualAPIRequest*) flagNonExistent:(NSString*) tableId
                             factualId: (NSString*) factualId
                              metadata:(FactualMetadata*) metadata
                          withDelegate:(id<FactualAPIDelegate>) delegate {
    return [self flagProblem: @"nonexistent" tableId: tableId factualId: factualId metadata: metadata withDelegate: delegate];
}

- (FactualAPIRequest*) flagSpam:(NSString*) tableId
                      factualId: (NSString*) factualId
                       metadata:(FactualMetadata*) metadata
                   withDelegate:(id<FactualAPIDelegate>) delegate {
    return [self flagProblem: @"spam" tableId: tableId factualId: factualId metadata: metadata withDelegate: delegate];
}

- (FactualAPIRequest*) flagOther:(NSString*) tableId
                       factualId: (NSString*) factualId
                        metadata:(FactualMetadata*) metadata
                    withDelegate:(id<FactualAPIDelegate>) delegate {
    return [self flagProblem: @"other" tableId: tableId factualId: factualId metadata: metadata withDelegate: delegate];
}

- (FactualAPIRequest*) flagProblem: (NSString*) problem 
                           tableId: (NSString*) tableId
                         factualId: (NSString*) factualId
                          metadata:(FactualMetadata*) metadata
                      withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"t/%@/%@/flag", tableId, factualId];
    NSMutableString *payload = [[NSMutableString alloc] init];
    [(FactualMetadataImpl*)metadata generateQueryString:payload];
    [payload appendString:@"&"];
    [payload appendString:[NSString stringWithFormat:@"problem=%@",[problem stringWithPercentEscape]]];
    return [self request:queryStr ofType: FactualRequestType_RawRequest requestMethod:@"POST" payload: payload withDelegate:delegate];
}

// schema query api
- (FactualAPIRequest*) getTableSchema:(NSString*) tableId 
                         withDelegate:(id<FactualAPIDelegate>) delegate {
    // build a query string using query object and table id
    NSString* queryStr = [FactualAPIHelper buildSchemaQueryString:((_secret == nil) ? _apiKey: nil) tableId:tableId];
    return [self request:queryStr ofType: FactualRequestType_SchemaQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// FactualAPIPrivate implementation 
//////////////////////////////////////////////////////////////////////////////////////////////////



@end

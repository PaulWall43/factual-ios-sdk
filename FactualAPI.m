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
#import "NSString(Escaping).h"
#import "FactualRowMetadata.h" 
#import "FactualRowMetadataImpl.h" 
#import "FactualUrlUtil.h" 


NSString *const FactualCoreErrorDomain = @"FactualCoreErrorDomain";


@implementation FactualAPI

@synthesize factualHome =_factualHome;
@synthesize apiKey = _apiKey;
@synthesize debug = _debug;
@synthesize timeoutInterval = _timeoutInterval;
@dynamic apiVersion;

-(id) initWithAPIKey:(NSString*) apiKey secret:(NSString *)secret{
    if (self = [super init]) {
        _apiKey = apiKey;
        _secret = [secret copy];
        _factualHome = @"http://api.v3.factual.com";
        _timeoutInterval = 180.0;
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
                                               requestMethod: requestMethod
                                             timeoutInterval:_timeoutInterval];
    
    return requestObject;
}

- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                optionalQueryParams:(FactualQuery*) queryParams
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    // build a query string using query object and table id
    NSString* queryStr = [FactualAPIHelper buildPlacesQueryString:((_secret == nil) ? _apiKey: nil) tableId:tableId queryParams:queryParams];
    return [self request:queryStr ofType: FactualRequestType_PlacesQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   get:(NSString*) path  
                      params:(NSDictionary*) params
                withDelegate:(id<FactualAPIDelegate>) delegate { 
    
	NSMutableString *qry = [[NSMutableString alloc] initWithFormat:path];
    [qry appendString:@"?"];
    
    for(id key in params) {
        [qry appendString:key];
        [qry appendString:@"="];
        NSString* escapedParamValue = (__bridge_transfer NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)[params objectForKey:key],NULL,CFSTR("?=&+"),kCFStringEncodingUTF8);
        [qry appendString:escapedParamValue];
    }
    NSString* urlStr = [self createRequestString: qry];
    
    return [self sendRequest: urlStr ofType: FactualRequestType_RawRequest requestMethod:@"GET" payload: nil withDelegate: delegate];
}

- (FactualAPIRequest*)   queryGeopulse:(CLLocationCoordinate2D) point
                          withDelegate:(id<FactualAPIDelegate>) delegate { 
    return [self queryGeopulse:point selectTerms:[NSMutableArray arrayWithCapacity:0] withDelegate:delegate];
}

- (FactualAPIRequest*)   queryGeopulse:(CLLocationCoordinate2D) point
                           selectTerms: (NSMutableArray*) selectTerms
                          withDelegate:(id<FactualAPIDelegate>) delegate { 
    
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:2];
    [params addObject:[NSString stringWithFormat:@"geo=%@", [FactualUrlUtil locationToJson: point]]];
    if ([selectTerms count] != 0) {
        NSMutableString* selectValues = [[NSMutableString alloc] init];
        int termNumber=0;
        for (NSString* term in selectTerms) {
            if(termNumber++ != 0) 
                [selectValues appendString:@","];
            [selectValues appendString:term];
        }
        [params addObject:[NSString stringWithFormat:@"select=%@",[selectValues stringWithPercentEscape]]];
    }
    NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"geopulse/context?"];
    [FactualUrlUtil appendParams:params to:qry];
    
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

- (FactualAPIRequest*)   resolveRow:(NSString*) tableId  
                         withValues:(NSDictionary*) values
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    NSString *qryPath = [[NSString alloc] initWithFormat:@"%@/resolve", tableId];
	NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"%@?", qryPath];
    
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:1];
    if ([values count] != 0) {
        NSError *error = NULL;
        NSData *serialized = [[CJSONSerializer serializer] serializeObject:values error:&error];
        NSString *serializedStr = [[NSString alloc] initWithData: serialized encoding: NSUTF8StringEncoding];
        [params addObject:[NSString stringWithFormat:@"values=%@", [serializedStr stringWithPercentEscape]]];
    }
    [FactualUrlUtil appendParams:params to:queryStr];
    
    return [self request:queryStr ofType: FactualRequestType_ResolveQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   matchRow:(NSString*) tableId  
                       withValues:(NSDictionary*) values
                     withDelegate:(id<FactualAPIDelegate>) delegate { 
    NSString *qryPath = [[NSString alloc] initWithFormat:@"%@/match", tableId];
	NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"%@?", qryPath];
    
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:1];
    if ([values count] != 0) {
        NSError *error = NULL;
        NSData *serialized = [[CJSONSerializer serializer] serializeObject:values error:&error];
        NSString *serializedStr = [[NSString alloc] initWithData: serialized encoding: NSUTF8StringEncoding];
        [params addObject:[NSString stringWithFormat:@"values=%@", [serializedStr stringWithPercentEscape]]];
    }
    [FactualUrlUtil appendParams:params to:queryStr];
    return [self request:queryStr ofType: FactualRequestType_MatchQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (FactualAPIRequest*)   facetTable:(NSString*) tableId  
                optionalQueryParams:(FactualQuery*) queryParams
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    NSMutableString *requestStr = [[NSMutableString alloc] init];
    
    NSString *queryStr = [[NSString alloc] initWithFormat:@"t/%@/facets", tableId];
	queryStr = [FactualAPIHelper buildQueryString:(_secret == nil) ? _apiKey: nil path:queryStr queryParams:queryParams];
    [requestStr appendString:queryStr];
    
    return [self request:queryStr ofType: FactualRequestType_FacetQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
}

- (NSString*)   createRequestString:(NSString*) path {
    return [NSString stringWithFormat:@"%@/%@", _factualHome, path];
}

- (FactualAPIRequest*)   request:(NSString*) queryStr ofType:(NSInteger)requestType requestMethod: (NSString*) requestMethod payload:payload withDelegate:(id<FactualAPIDelegate>) delegate { 
    // build url .. 
    NSString* urlStr = [self createRequestString: queryStr];
    if (_debug) {
        NSLog(@"Url: %@", urlStr);
        NSLog(@"Request Method: %@", requestMethod);
        NSLog(@"Payload: %@", payload);
    }
    return [self sendRequest: urlStr ofType: requestType requestMethod:requestMethod payload:payload withDelegate: delegate];
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

- (FactualAPIRequest*) submitRow:(NSString*) tableId
                      withValues: (NSMutableDictionary*) values 
                    withMetadata:(FactualRowMetadata*) metadata
                    withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *path = [[NSMutableString alloc] initWithFormat:@"t/%@/submit", tableId];
    return [self submitRowInternal: path withValues:values withMetadata:metadata withDelegate:delegate];
}

- (FactualAPIRequest*) submitRowWithId:(NSString*) factualId
                               tableId: (NSString*) tableId
                            withValues: (NSMutableDictionary*) values
                          withMetadata:(FactualRowMetadata*) metadata
                          withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *path = [[NSMutableString alloc] initWithFormat:@"t/%@/%@/submit", tableId, factualId];
    return [self submitRowInternal: path withValues:values withMetadata:metadata withDelegate:delegate];
}

- (FactualAPIRequest*) submitRowInternal:(NSMutableString*) path
                              withValues: (NSMutableDictionary*) values 
                            withMetadata:(FactualRowMetadata*) metadata
                            withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *payload = [[NSMutableString alloc] init];
    [(FactualRowMetadataImpl*)metadata generateQueryString:payload];
    [payload appendString: @"&"];
    
    NSError *error = NULL;
    NSData *serialized = [[CJSONSerializer serializer] serializeObject:values error:&error];
    NSString *serializedStr = [[NSString alloc] initWithData: serialized encoding: NSUTF8StringEncoding];
    [payload appendString:[NSString stringWithFormat:@"values=%@", [serializedStr stringWithPercentEscape]]];
    
    return [self request:path ofType: FactualRequestType_RawRequest requestMethod:@"POST" payload: payload withDelegate:delegate];
}

- (FactualAPIRequest*)    clearRowWithId:(NSMutableString*) factualId
                                 tableId: (NSMutableString*) tableId
                              withFields: (NSArray*) fields
                            withMetadata:(FactualRowMetadata*) metadata
                            withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"t/%@/%@/clear", tableId, factualId];
    NSMutableString *payload = [[NSMutableString alloc] init];
    [(FactualRowMetadataImpl*)metadata generateQueryString:payload];
    [payload appendString:@"&"];
    
    NSMutableString* clearStr = [[NSMutableString alloc] init];
    int termNumber=0;
    for (NSString* term in fields) {
        if(termNumber++ != 0)
            [clearStr appendString:@","];
        [clearStr appendString:term];
    }
    [payload appendString:[NSString stringWithFormat:@"fields=%@",[clearStr stringWithPercentEscape]]];
    return [self request:queryStr ofType: FactualRequestType_RawRequest requestMethod:@"POST" payload: payload withDelegate:delegate];
    
}

- (FactualAPIRequest*) flagProblem: (FactualFlagType) problem
                           tableId: (NSString*) tableId
                         factualId: (NSString*) factualId
                          metadata:(FactualRowMetadata*) metadata
                      withDelegate:(id<FactualAPIDelegate>) delegate {
    NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"t/%@/%@/flag", tableId, factualId];
    NSMutableString *payload = [[NSMutableString alloc] init];
    [(FactualRowMetadataImpl*)metadata generateQueryString:payload];
    [payload appendString:@"&"];
    
    NSString* problemStr = nil;
    
    switch (problem) {
        case FactualFlagType_Duplicate: { 
            problemStr = @"duplicate";
        }
            break;
        case FactualFlagType_Inaccurate: { 
            problemStr = @"inaccurate";
        }
            break;
        case FactualFlagType_Inappropriate: {
            problemStr = @"inappropriate";
        }
            break;
        case FactualFlagType_Nonexistent: {
            problemStr = @"nonexistent";
        }
            break;
        case FactualFlagType_Spam: {
            problemStr = @"spam";
        }
            break;         
        case FactualFlagType_Other: {
            problemStr = @"other";
        }
            break;          
        default: {
            [NSException raise:NSGenericException format:@"Unknown problem type: %@", problem];
        }
            break;
    }
    
    [payload appendString:[NSString stringWithFormat:@"problem=%@",[problemStr stringWithPercentEscape]]];
    return [self request:queryStr ofType: FactualRequestType_RawRequest requestMethod:@"POST" payload: payload withDelegate:delegate];
}


- (FactualAPIRequest*)   fetchRow:(NSString*) tableId
                        factualId:(NSString*) factualId
                     withDelegate:(id<FactualAPIDelegate>) delegate {
    return [self fetchRow:tableId factualId:factualId only:[[NSMutableArray alloc] init] withDelegate:delegate];
}

- (FactualAPIRequest*)   fetchRow:(NSString*) tableId
                        factualId:(NSString*) factualId
                             only:(NSArray*) only
                     withDelegate:(id<FactualAPIDelegate>) delegate {
    NSString* queryStr = [FactualAPIHelper buildFetchRowQueryString:((_secret == nil) ? _apiKey: nil) tableId:tableId factualId:factualId only:only];
    return [self request:queryStr ofType: FactualRequestType_FetchRowQuery requestMethod:@"GET" payload: nil withDelegate:delegate];
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

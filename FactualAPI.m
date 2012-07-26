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
#import "Geocode.h"
#import "Geopulse.h"
#import "Resolve.h" 

typedef enum {
	FactualApplicationModeNormal = 0,
	FactualApplicationModeSandbox
} FactualApplicationMode;


static NSString* hosts[] = {
  @"api.factual.com",
  @"api.factual.com"
};

static NSInteger API_VERSION = 2;

NSString *const FactualCoreErrorDomain = @"FactualCoreErrorDomain";


@implementation FactualAPI

@synthesize apiKey = _apiKey;
@dynamic apiVersion;

-(id) initWithAPIKey:(NSString*) apiKey secret:(NSString *)secret{
  if (self = [super init]) {
    _apiKey = apiKey;
    _secret = [secret copy];
  }
  return self;
}

- (NSInteger) apiVersion {
	return API_VERSION;
}

- (FactualAPIRequest*) allocateRequest:(NSString*) urlStr
                           requestType:(NSInteger)theRequestType 
                        optionalTableId:(NSString*)tableId
                          withDelegate:(id<FactualAPIDelegate>) delegate
                          optionalPayload:(NSString*) payload {
 
  // build the request object ...
  FactualAPIRequestImpl* requestObject 
  = [[FactualAPIRequestImpl alloc] initWithURL:urlStr 
                                    requestType:theRequestType  
                                optionalTableId:tableId
                                   withDelegate:delegate
                                  withAPIObject:self
                                optionalPayload:payload];
  
  return requestObject;
}

- (FactualAPIRequest*) allocateOAuthRequest:(NSString*) urlStr
                           requestType:(NSInteger)theRequestType 
                       optionalTableId:(NSString*)tableId
                          withDelegate:(id<FactualAPIDelegate>) delegate
                       optionalPayload:(NSString*) payload {
  
    // build the request object ...
  FactualAPIRequestImpl* requestObject 
  = [[FactualAPIRequestImpl alloc] initOAuthRequestWithURL:urlStr 
                                    requestType:theRequestType  
                                optionalTableId:tableId
                                   withDelegate:delegate
                                  withAPIObject:self
                                optionalPayload:payload
                                consumerKey:_apiKey
                                consumerSecret:_secret];
  
  return requestObject;
}

- (FactualAPIRequest*) submitRowData:(NSString*) tableId 
                      facts:(NSDictionary*) facts
                      withDelegate:(id<FactualAPIDelegate>) delegate 
                     optionalRowId:(NSString*) rowId 
                    optionalSource:(NSString*) source 
                   optionalComment:(NSString*) comment 
                   optionalUserToken:(NSString*) tokenId 

{
   
  // build a query string using  table id
  NSString* queryStr = [FactualAPIHelper buildUpdateQueryString:tableId];
  // build url .. 
  NSString* urlStr = [FactualAPIHelper buildAPIRequestURL:hosts[FactualApplicationModeNormal] apiVersion:API_VERSION queryStr:queryStr];
  
  // build post body with remaining parameters and facts
  NSString* postBodyStr = [FactualAPIHelper buildTableUpdatePostBody:_apiKey
                                                               facts:facts
                                                       optionalRowId:rowId optionalSource:source optionalUserTokenId:tokenId 
                                                     optionalComment:comment];
#ifdef TARGET_IPHONE_SIMULATOR  
  NSLog(@"update URL:%@\nBODY:%@",urlStr,postBodyStr);
#endif
  
  return [self allocateRequest:urlStr 
                   requestType:FactualRequestType_RowUpdate 
               optionalTableId:tableId
                  withDelegate:delegate 
               optionalPayload:postBodyStr];
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
    NSString* urlStr = [FactualAPIHelper buildAPIRequestURL:hosts[FactualApplicationModeNormal] apiVersion:3 queryStr:qry];
    
    if (_secret != nil) { 
#ifdef TARGET_IPHONE_SIMULATOR
        NSLog(@"using OAuth Request for Places Request");
#endif
        
        return [self allocateOAuthRequest:urlStr
                              requestType:FactualRequestType_PlacesQuery 
                          optionalTableId:nil
                             withDelegate:delegate 
                          optionalPayload:nil];
        
    }
    else { 
        return [self allocateRequest:urlStr
                         requestType:FactualRequestType_PlacesQuery 
                     optionalTableId:nil
                        withDelegate:delegate 
                     optionalPayload:nil];
    }
}

- (FactualAPIRequest*)   geopulse:(Geopulse*) geopulse
                           withDelegate:(id<FactualAPIDelegate>) delegate { 
    
	NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"places/geopulse?"];
    [geopulse generateQueryString:qry];
    return [self request:qry ofType: FactualRequestType_PlacesQuery withDelegate:delegate];
}

- (FactualAPIRequest*)   reverseGeocode:(Geocode*) geocode
                         withDelegate:(id<FactualAPIDelegate>) delegate { 
    
	NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"places/geocode?"];
    [geocode generateQueryString:qry];
    return [self request:qry ofType: FactualRequestType_PlacesQuery withDelegate:delegate];
}

- (FactualAPIRequest*)   monetize:(FactualQuery*) queryParams
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    // build a query string using query object and table id
    NSString* queryStr = [FactualAPIHelper buildQueryString:((_secret == nil) ? _apiKey: nil) path:@"places/monetize" queryParams:queryParams];
    return [self request:queryStr ofType: FactualRequestType_PlacesQuery withDelegate:delegate];
}

- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                        resolveParams:(Resolve*) resolve
                        withDelegate:(id<FactualAPIDelegate>) delegate { 
    NSString *qryPath = [[NSString alloc] initWithFormat:@"%@/resolve", tableId];
	NSMutableString *queryStr = [[NSMutableString alloc] initWithFormat:@"%@?", qryPath];
    [resolve generateQueryString:queryStr];
    return [self request:queryStr ofType: FactualRequestType_PlacesQuery withDelegate:delegate];
}

- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                        optionalQueryParams:(FactualQuery*) queryParams
                        withDelegate:(id<FactualAPIDelegate>) delegate { 
    // build a query string using query object and table id
  NSString* queryStr = [FactualAPIHelper buildPlacesQueryString:((_secret == nil) ? _apiKey: nil) tableId:tableId queryParams:queryParams];
  return [self request:queryStr ofType: FactualRequestType_PlacesQuery withDelegate:delegate];
}


- (FactualAPIRequest*)   queryTable:(NSString*) tableId  
                        facetParams:(FactualFacetQuery*) facet
                       withDelegate:(id<FactualAPIDelegate>) delegate {
    // build a query string using query object and table id
    NSString* queryStr = [FactualAPIHelper buildPlacesQueryString:((_secret == nil) ? _apiKey: nil) tableId:tableId facetParams:facet];
    return [self request:queryStr ofType: FactualRequestType_FacetQuery withDelegate:delegate];
}


- (FactualAPIRequest*)   request:(NSString*) queryStr ofType:(NSInteger)theRequestType 
                       withDelegate:(id<FactualAPIDelegate>) delegate { 
    // build url .. 
    NSString* urlStr = [FactualAPIHelper buildAPIRequestURL:hosts[FactualApplicationModeNormal] apiVersion:3 queryStr:queryStr];

    if (_secret != nil) { 
#ifdef TARGET_IPHONE_SIMULATOR
        NSLog(@"using OAuth Request for Places Request");
#endif
        
        return [self allocateOAuthRequest:urlStr
                              requestType:theRequestType 
                          optionalTableId:nil
                             withDelegate:delegate 
                          optionalPayload:nil];
        
    }
    else { 
        return [self allocateRequest:urlStr
                         requestType:theRequestType 
                     optionalTableId:nil
                        withDelegate:delegate 
                     optionalPayload:nil];
    }

}

// schema query api
- (FactualAPIRequest*) getTableSchema:(NSString*) tableId 
                           withDelegate:(id<FactualAPIDelegate>) delegate {
  // build a query string using query object and table id
  NSString* queryStr = [FactualAPIHelper buildSchemaQueryString:_apiKey tableId:tableId];

  // build url .. 
  NSString* urlStr = [FactualAPIHelper buildAPIRequestURL:hosts[FactualApplicationModeNormal] apiVersion:API_VERSION queryStr:queryStr];
  
  return [self allocateRequest:urlStr 
                   requestType:FactualRequestType_SchemaQuery 
               optionalTableId:tableId
                  withDelegate:delegate 
               optionalPayload:nil];
}


// schema query api
- (FactualAPIRequest*) flagBadRow:(NSString*) tableId 
                            rowId:(NSString*) rowId
                   optionalSource:(NSString*) source 
                  optionalComment:(NSString*) comment
                     withDelegate:(id<FactualAPIDelegate>) delegate {
  

  // build a query string using query object and table id
  NSString* queryStr = [FactualAPIHelper buildRateQueryString:_apiKey 
                                                      tableId:tableId
                                                        rowId:rowId
                                                       source:source
                                                      comment:comment];
  
  // build url .. 
  NSString* urlStr = [FactualAPIHelper buildAPIRequestURL:hosts[FactualApplicationModeNormal] apiVersion:API_VERSION queryStr:queryStr];
  
  return [self allocateRequest:urlStr 
                   requestType:FactualRequestType_FlagBadRowRequest 
               optionalTableId:tableId
                  withDelegate:delegate 
               optionalPayload:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// FactualAPIPrivate implementation 
//////////////////////////////////////////////////////////////////////////////////////////////////



@end

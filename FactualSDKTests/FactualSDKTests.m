//
//  FactualSDKTests.m
//  FactualSDKTests
//
//  Created by Brandon Yoshimoto on 7/16/12.
//  Copyright (c) 2012 Factual. All rights reserved.
//

#import "FactualSDKTests.h"
#import <FactualSDK/FactualAPI.h>
#import "FactualQueryImpl.h"
#import "FactualFacetQueryImpl.h"
#import "FactualGeopulse.h"
#import "FactualMatchQuery.h"
#import "FactualResolve.h"
#import "FactualMetadata.h"
#import <CoreLocation/CLLocation.h>
#import "FactualFacetResponse.h"

@implementation FactualSDKTests

FactualAPI* _apiObject;
BOOL _finished;
FactualQueryResult* _queryResult;
FactualResolveResult* _resolveResult;
NSDictionary* _rawResult;
FactualFacetResponse* _facetResult;
NSString* _matchResult;

double _latitude;
double _longitude;
double _meters;

// Add your key and secret
NSString* _key = nil;
NSString* _secret = nil;

- (void)setUp
{
    [super setUp];
    _latitude = 34.06018;
    _longitude = -118.41835;
    _meters = 5000;

    _finished = false;
    
    _queryResult = nil;
    _resolveResult = nil;
    _rawResult = nil;
    _facetResult = nil;
    _matchResult = nil;
    _apiObject = [[FactualAPI alloc] initWithAPIKey:_key secret:_secret];
}

- (void)tearDown
{
    [super tearDown];
    
    _finished = false;
    
    _queryResult = nil;
    _resolveResult = nil;
    _rawResult = nil;
    _facetResult = nil;
    _matchResult = nil;
}

- (void)testCoreExample1
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"country"
                                                  equalTo:@"US"]];
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    [self waitForResponse];
}

- (void)testCoreExample2
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name"
                                               beginsWith:@"Star"]];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testCoreExample3
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addFullTextQueryTerm:@"Fried Chicken, Los Angeles"];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testCoreExample4
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addFullTextQueryTerm:@"Fried Chicken, Los Angeles"];
    queryObject.offset = 20;
    queryObject.limit = 5;
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertEquals(5U, [_queryResult.rows count], @"Not equal");
}

- (void)testCoreExample5
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name"
                                                  equalTo:@"Stand"]];
    
    CLLocationCoordinate2D coordinate = {_latitude, _longitude};
    [queryObject setGeoFilter:coordinate 
               radiusInMeters:_meters];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
}

- (void)testSort_byDistance
{
    FactualQuery* queryObject = [FactualQuery query];
    
    CLLocationCoordinate2D coordinate = {_latitude, _longitude};
    [queryObject setGeoFilter:coordinate 
               radiusInMeters:_meters];
    
    FactualSortCriteria* primarySort = [[FactualSortCriteria alloc] initWithFieldName:@"$distance" sortOrder:FactualSortOrder_Ascending];
    [queryObject setPrimarySortCriteria:primarySort];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testRowFilters_2beginsWith
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name"
                                               beginsWith:@"McDonald's"]];
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category"
                                               beginsWith:@"Food & Beverage"]];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testIn
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"region"
                                                       In:@"CA",@"NM",@"FL",nil]];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
}

- (void)testComplicated
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"region"
                                                       In:@"MA",@"VT",@"NH",nil]];
    [queryObject addRowFilter:[FactualRowFilter orFilter:[FactualRowFilter fieldName:@"name"
                                                                          beginsWith:@"Coffee"]
                               ,[FactualRowFilter fieldName:@"name"
                                                 beginsWith:@"Star"], nil]];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
}

- (void)testSimpleTel
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"tel"
                                               beginsWith:@"(212)"]];
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testFullTextSearch_on_a_field
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name"
                                                   search:@"Fried Chicken"]];
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testCrosswalk_ex1
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"factual_id"
                                                  equalTo:@"97598010-433f-4946-8fd5-4a6dd1639d77"]];    
    
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
    [self waitForResponse];
}

- (void)testCrosswalk_ex2
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"factual_id"
                                                  equalTo:@"97598010-433f-4946-8fd5-4a6dd1639d77"]];    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace"
                                                  equalTo:@"loopt"]];    
    
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
    [self waitForResponse];
}

- (void)testCrosswalk_ex3
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace"
                                                  equalTo:@"foursquare"]];    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace_id"
                                                  equalTo:@"4ae4df6df964a520019f21e3"]];    
    
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
    [self waitForResponse];
}

- (void)testCrosswalk_limit
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"factual_id"
                                                  equalTo:@"97598010-433f-4946-8fd5-4a6dd1639d77"]];    
    queryObject.limit = 1;
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
    [self waitForResponse];
}

- (void)testMonetize
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"place_locality"
                                                  equalTo:@"Los Angeles"]];
    
    [_apiObject monetize:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testSelect
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"country"
                                                  equalTo:@"US"]];
    [queryObject addSelectTerm:@"address"];
    [queryObject addSelectTerm:@"country"];
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testWorldGeographies
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name"
                                                  equalTo:@"philadelphia"]];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"country"
                                                  equalTo:@"us"]];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"placetype"
                                                  equalTo:@"locality"]];
    [_apiObject queryTable:@"world-geographies" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testResolve_ex1
{
    FactualResolve* queryObject = [FactualResolve resolve];
    [queryObject addProperty:@"name" value:@"McDonalds"];
    [queryObject addProperty:@"address" value:@"10451 Santa Monica Blvd"];
    [queryObject addProperty:@"region" value:@"CA"];
    [queryObject addProperty:@"postcode" value:@"90025"];
    [_apiObject queryTable:@"places" resolveParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    NSLog(@"Is resolved: %u, Obj: %@", [_resolveResult isResolved], [_resolveResult getResolved]);
    
} 

- (void)testFacet
{
    FactualFacetQuery* queryObject = [FactualFacetQuery facetQuery];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"country"
                                                  equalTo:@"US"]];
    [queryObject addSelectTerm:@"region"];
    [queryObject addSelectTerm:@"locality"];
    [queryObject addFullTextQueryTerm:@"Starbucks"];
    
    queryObject.maxValuesPerFacet = 20;
    queryObject.minCountPerFacetValue = 100;
    queryObject.includeRowCount = true;
    
    [_apiObject queryTable:@"places" facetParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testSchema
{
    [_apiObject getTableSchema:@"restaurants-us" withDelegate:self];
    
    [self waitForResponse];
}

- (void)testMatch
{
    FactualMatchQuery* queryObject = [FactualMatchQuery match];
    [queryObject addProperty:@"name" value:@"McDonalds"];
    [queryObject addProperty:@"address" value:@"10451 Santa Monica Blvd"];
    [queryObject addProperty:@"region" value:@"CA"];
    [queryObject addProperty:@"postcode" value:@"90025"];
    [_apiObject queryTable:@"places" matchParams:queryObject withDelegate:self];
    
    [self waitForResponse];
}

- (void)testGeopulse
{
    CLLocationCoordinate2D point;
    point.longitude = _longitude;
    point.latitude = _latitude;
    FactualGeopulse* geopulse = [FactualGeopulse geopulse:point];
    [geopulse addSelectTerm:@"commercial_density"];
    [geopulse addSelectTerm:@"commercial_profile"];
    [_apiObject geopulse:geopulse withDelegate:self];
    [self waitForResponse];
}

- (void)testGeocode
{
    CLLocationCoordinate2D point;
    point.longitude = _longitude;
    point.latitude = _latitude;
    [_apiObject reverseGeocode:point withDelegate:self];
    [self waitForResponse];
}

- (void)testRawRead
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setValue:@"3" forKey:@"limit"];
    [_apiObject get:@"t/places" params:params withDelegate: self];
    
    [self waitForResponse];
}

- (void)testFlagDuplicate
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    [_apiObject flagDuplicate:@"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testFlagInaccurate
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    [_apiObject flagInaccurate:@"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testFlagInappropriate
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    [_apiObject flagInappropriate:@"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testFlagNonExistent
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    [_apiObject flagNonExistent:@"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testFlagSpam
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    [_apiObject flagSpam:@"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testFlagOther
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    [_apiObject flagOther:@"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testSubmitAdd
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    
    FactualSubmit* submit = [FactualSubmit submit];
    [submit addProperty:@"longitude" value:@"100"];
    [_apiObject submit:@"2EH4Pz" submitParams:submit metadata:metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testSubmitEdit
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    
    FactualSubmit* submit = [FactualSubmit submit];
    [submit addProperty:@"longitude" value:@"100"];
    [_apiObject submit:@"2EH4Pz" factualId:@"f33527e0-a8b4-4808-a820-2686f18cb00c" submitParams:submit metadata:metadata withDelegate:self];
    [self waitForResponse];
}

- (void)testSubmitDelete
{
    FactualMetadata* metadata = [FactualMetadata metadata: @"testuser"];
    metadata.comment = @"my comment";
    metadata.reference = @"www.mytest.com";
    
    FactualSubmit* submit = [FactualSubmit submit];
    [submit removeValue:@"longitude"];
    [_apiObject submit:@"2EH4Pz" factualId:@"f33527e0-a8b4-4808-a820-2686f18cb00c" submitParams:submit metadata:metadata withDelegate:self];
    [self waitForResponse];
}

- (void)waitForResponse
{
    while (!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) requestComplete:(FactualAPIRequest *)request receivedRawResult:(NSDictionary *)result {
    _rawResult = result;
    _finished = true;
     for (id key in result) {
     NSLog(@"KEY: %@, VALUE: %@", key, [result objectForKey:key]);
     }
}

-(void) requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResult {
    _queryResult = queryResult;
    _finished = true;
     for (id row in queryResult.rows) {
     NSLog(@"Row: %@", row);
     }
}

-(void) requestComplete:(FactualAPIRequest *)request receivedResolveResult:(FactualResolveResult *)result {
    _resolveResult = result;
    _finished = true;
    
     for (id row in result.rows) {
     NSLog(@"Resolve Row: %@", row);
     }
}

-(void) requestComplete:(FactualAPIRequest *)request receivedMatchResult:(NSString *)factualId {
    _matchResult = factualId;
    _finished = true;
}

-(void) requestComplete:(FactualAPIRequest *)request receivedFacetResult:(FactualFacetResponse *)result {
    _facetResult = result;
    _finished = true;
    
     for (id key in result.data) {
     NSLog(@"KEY: %@, VALUE: %@", key, [result.data objectForKey:key]);
     }
     NSLog(@"TOTAL ROW COUNT: %d", result.totalRows);
}

-(void) requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"FAILED with error");
    _finished = true;
}
@end

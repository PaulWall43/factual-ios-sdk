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
#import "FactualPoint.h"
#import "Geocode.h"
#import "Geopulse.h"
#import "Resolve.h"

@implementation FactualSDKTests

FactualAPI* _apiObject;
BOOL finished;
FactualQueryResult* queryResult;
NSDictionary* rawResult;
double latitude;
double longitude;
double meters;

- (void)setUp
{
    [super setUp];
    latitude = 34.06018;
    longitude = -118.41835;
    meters = 5000;
    finished = false;
    queryResult = nil;
    queryResult = nil;

    _apiObject = [[FactualAPI alloc] initWithAPIKey:@"U3QbOw7bW9nxDN4TppoqQlxwnJmSISUbJ3h3pRj1" secret:@"2AFaSQYCFjSsDkZKLOhpT8QE2zQRLCUxcJnMMfSa"];
}

- (void)tearDown
{
    [super tearDown];
    
    finished = false;
    queryResult = nil;
    rawResult = nil;
}

- (void)testCoreExample1
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"country"
                                                equalTo:@"US"]];

    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];

    [self waitForResponse];
    [self assertOk];

}

- (void)testCoreExample2
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name"
                                                beginsWith:@"Star"]];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];
}

- (void)testCoreExample3
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addFullTextQueryTerm:@"Fried Chicken, Los Angeles"];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];
}

- (void)testCoreExample4
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addFullTextQueryTerm:@"Fried Chicken, Los Angeles"];
    queryObject.offset = 20;
    queryObject.limit = 5;
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];
    
    STAssertEquals(5U, [queryResult.rows count], @"Not equal");
}

- (void)testCoreExample5
{
    FactualQuery* queryObject = [FactualQuery query];
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name"
                                                  equalTo:@"Stand"]];
    
    CLLocationCoordinate2D coordinate = {latitude, longitude};
    [queryObject setGeoFilter:coordinate 
                 radiusInMeters:meters];

    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];

}

- (void)testSort_byDistance
{
    FactualQuery* queryObject = [FactualQuery query];
    
    CLLocationCoordinate2D coordinate = {latitude, longitude};
    [queryObject setGeoFilter:coordinate 
               radiusInMeters:meters];
    
    FactualSortCriteria* primarySort = [[FactualSortCriteria alloc] initWithFieldName:@"$distance" sortOrder:FactualSortOrder_Ascending];
    [queryObject setPrimarySortCriteria:primarySort];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];
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
    [self assertOk];
}

- (void)testIn
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"region"
                                                       In:@"CA",@"NM",@"FL",nil]];
    
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];

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
    [self assertOk];
    
}


- (void)testSimpleTel
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"tel"
                                               beginsWith:@"(212)"]];
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];
}

// Doesn't work
- (void)testFullTextSearch_on_a_field
{
}

- (void)testCrosswalk_ex1
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"factual_id"
                                                  equalTo:@"97598010-433f-4946-8fd5-4a6dd1639d77"]];    
    
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
    [self waitForResponse];
    [self assertOk];
    
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
    [self assertOk];
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
    [self assertOk];
}

- (void)testCrosswalk_limit
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"factual_id"
                                                  equalTo:@"97598010-433f-4946-8fd5-4a6dd1639d77"]];    
    queryObject.limit = 1;
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
    [self waitForResponse];
    [self assertOk];
}


// Doesn't work
- (void)testApiException_BadAuth
{
}

// Doesn't work
- (void)testApiException_BadSelectField
{
}


- (void)testSelect
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"country"
                                                  equalTo:@"US"]];
    [_apiObject queryTable:@"places" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    [self assertOk];
}

// Doesn't work
- (void)testCustomRead1
{
}

// Doesn't work
- (void)testCustomRead2
{
}
 
 - (void)testGeocode
 {
 FactualPoint* point = [[FactualPoint alloc] initWithLatitude:latitude longitude:longitude];
 Geocode* geocode = [[Geocode alloc] initWithPoint:point];
 [_apiObject reverseGeocode:geocode withDelegate:self];
 [self waitForResponse];
 [self assertOk];
 }
 
 - (void)testGeopulse
 {
 FactualPoint* point = [[FactualPoint alloc] initWithLatitude:latitude longitude:longitude];
 Geopulse* geopulse = [[Geopulse alloc] initWithPoint:point];
 [geopulse addSelectTerm:@"commercial_density"];
 [geopulse addSelectTerm:@"commercial_profile"];
 [_apiObject geopulse:geopulse withDelegate:self];
 [self waitForResponse];
 [self assertOk];
 }
 - (void)testMonetize
 {
 FactualQuery* queryObject = [FactualQuery query];
 [queryObject addRowFilter:[FactualRowFilter fieldName:@"place_locality"
 equalTo:@"Los Angeles"]];
 
 [_apiObject monetize:queryObject withDelegate:self];
 
 [self waitForResponse];
 [self assertOk];
 }
 
 - (void)testResolve_ex1
 {
 Resolve* queryObject = [Resolve resolve];
 [queryObject addProperty:@"name" value:@"McDonalds"];
 [queryObject addProperty:@"address" value:@"10451 Santa Monica Blvd"];
 [queryObject addProperty:@"region" value:@"CA"];
 [queryObject addProperty:@"postcode" value:@"90025"];
 [_apiObject queryTable:@"places" resolveParams:queryObject withDelegate:self];
 [self waitForResponse];
 [self assertOk];
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
    [self assertOk];
    
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
    [self assertOk];
}

 
- (void)assertOk
{
    STAssertTrue(true, @"Finished");
    NSLog(@"Active request Completed with row count:%d TableId:%@", [queryResult rowCount], queryResult.tableId);
    //for (FactualRow* row in queryResult.rows) {
     //   NSLog(@"Row: %@, Names-values: %@", row.rowId, row.namesAndValues);
    //}
}

- (void)waitForResponse
{
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) requestComplete:(FactualAPIRequest *)request receivedRawResult:(NSDictionary *)rawResult {
    rawResult = rawResult;
    finished = true;
    for (id key in rawResult) {
        NSLog(@"KEY: %@, VALUE: %@", key, [rawResult objectForKey:key]);
    }
}

-(void) requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResultObj {
    queryResult = queryResultObj;
    finished = true;
}

-(void) requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"FAILED with error");
    finished = true;
}
@end

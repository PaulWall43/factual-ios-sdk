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
#import "FactualRowMetadata.h"
#import "FactualAPI.h"
#import <CoreLocation/CLLocation.h>

@implementation FactualSDKTests

FactualAPI* _apiObject;
BOOL _finished;
FactualQueryResult* _queryResult;
NSDictionary* _rawResult;
NSString* _matchResult;

double _latitude;
double _longitude;
double _meters;

// Add your key and secret
NSString* _key = @"";
NSString* _secret = @"";

- (void)setUp
{
    [super setUp];
    _latitude = 34.06018;
    _longitude = -118.41835;
    _meters = 5000;
    
    _finished = false;
    
    _queryResult = nil;
    _rawResult = nil;
    _matchResult = nil;
    _apiObject = [[FactualAPI alloc] initWithAPIKey:_key secret:_secret];
}

- (void)tearDown
{
    [super tearDown];
    
    _finished = false;
    
    _queryResult = nil;
    _rawResult = nil;
    _matchResult = nil;
}


- (void)testSchema
{
    [_apiObject getTableSchema:@"places-us" withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue(_rawResult != nil, @"Invalid response");
    
}

- (void)testFullTextSearch
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addFullTextQueryTerm:@"century city mall"];
    queryObject.includeRowCount = true;
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    
}

- (void)testRowFiltersIncludes
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category_ids"
                                                 includes:@"347"]];
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];

    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    STAssertTrue(_queryResult.totalRows == -1, @"Invalid total rows");
}

- (void)testRowFiltersIncludesAny
{
    NSMutableArray* categories = [[NSMutableArray alloc] initWithCapacity:2];
    [categories addObject:[NSNumber numberWithInteger:312]];
    [categories addObject:[NSNumber numberWithInteger:347]];
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category_ids"
                                                includesAnyArray: categories]];
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    STAssertTrue(_queryResult.totalRows == -1, @"Invalid total rows");
}

- (void)testRowFilterExcludes
{
    FactualQuery* queryObject = [FactualQuery query];
    FactualRowFilter* andFilter = [FactualRowFilter andFilter:
                                   [FactualRowFilter fieldName:@"category_ids"
                                                     includes:@"317"],
                                   [FactualRowFilter fieldName:@"category_ids"
                                                     excludes:@"318"], nil];
    [queryObject addRowFilter:andFilter];
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid response");
    
}

- (void)testStarbucksInLosAngeles
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addFullTextQueryTerm:@"starbucks"];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"locality" equalTo:@"los angeles"]];
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid response");
}

- (void)testStarbucksOrFilter
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addFullTextQueryTerm:@"starbucks"];
    FactualRowFilter* orFilter = [FactualRowFilter orFilter:
                                   [FactualRowFilter fieldName:@"locality"
                                                      equalTo:@"los angeles"],
                                   [FactualRowFilter fieldName:@"locality"
                                                      equalTo:@"santa monica"], nil];
    [queryObject addRowFilter:orFilter];
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid response");
    
}

- (void)testStarbucksOrFilterSecondPage
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addFullTextQueryTerm:@"starbucks"];
    FactualRowFilter* orFilter = [FactualRowFilter orFilter:
                                  [FactualRowFilter fieldName:@"locality"
                                                      equalTo:@"los angeles"],
                                  [FactualRowFilter fieldName:@"locality"
                                                      equalTo:@"santa monica"], nil];
    [queryObject addRowFilter:orFilter];
    queryObject.offset = 20;
    queryObject.limit = 20;
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid response");
    
}

- (void)testCoffeeNearFactual
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addFullTextQueryTerm:@"coffee"];
    CLLocationCoordinate2D coordinate = {34.058583, -118.416582};
    [queryObject setGeoFilter:coordinate
               radiusInMeters:1000];
    [_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    
}

- (void)testExistenceConfident
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setValue:@"confident" forKey:@"threshold"];
    [_apiObject get:@"t/places-us" params:params withDelegate: self];
    
    [self waitForResponse];
    
    STAssertTrue(_rawResult != nil, @"Invalid response");
    
    NSDictionary* resp = [_rawResult objectForKey:@"response"];
    int includedRows = [[resp objectForKey:@"included_rows"] unsignedIntValue];
    NSLog(@"ROW COUNT: %d", includedRows);

    STAssertTrue(includedRows > 0, @"Invalid row count");
    
}

- (void)testRowByFactualId
{
    [_apiObject get:@"t/places-us/03c26917-5d66-4de9-96bc-b13066173c65" params:[[NSMutableDictionary alloc] init] withDelegate: self];
    
    [self waitForResponse];
    
    STAssertTrue(_rawResult != nil, @"Invalid response");
    
    NSDictionary* resp = [_rawResult objectForKey:@"response"];
    int includedRows = [[resp objectForKey:@"included_rows"] unsignedIntValue];
    NSLog(@"ROW COUNT: %d", includedRows);
    STAssertTrue(includedRows == 1, @"Invalid row count");
    
}

- (void)testFacet
{
    FactualQuery* query = [FactualQuery query];
    query.minCountPerFacetValue = 20;
    query.limit = 5;
    [query addRowFilter:[FactualRowFilter fieldName:@"region"
                                            equalTo:@"CA"]];
    [query addSelectTerm:@"locality"];
    [query addFullTextQueryTerm:@"starbucks"];
    [_apiObject facetTable:@"places-us" optionalQueryParams:query withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    STAssertTrue(_queryResult.totalRows > 0, @"Invalid total rows");
    
}

- (void)testResolveNameAddress
{
    NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
    [values setValue:@"McDonalds" forKey:@"name"];
    [values setValue:@"10451 Santa Monica Blvd" forKey:@"address"];
    [values setValue:@"CA" forKey:@"region"];
    [values setValue:@"90025" forKey:@"postcode"];
    [_apiObject resolveRow:@"t/places-us" withValues:values withDelegate:self];
    
    [self waitForResponse];
    
    //STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    
}

- (void)testResolveNameLocation
{
    NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
    [values setValue:@"McDonalds" forKey:@"name"];
    [values setValue:@"34.05671" forKey:@"latitude"];
    [values setValue:@"-118.42586" forKey:@"longitude"];
    [_apiObject resolveRow:@"t/places-us" withValues:values withDelegate:self];
    
    [self waitForResponse];
    
    //STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    
}

- (void)testCrosswalkForYelp
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"factual_id"
                                                  equalTo:@"3b9e2b46-4961-4a31-b90a-b5e0aed2a45e"]];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace"
                                                  equalTo:@"yelp"]];
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];

    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
}

- (void)testCrosswalkForFoursquare
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace_id"
                                                  equalTo:@"4ae4df6df964a520019f21e3"]];
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace"
                                                  equalTo:@"foursquare"]];
    [_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
}

- (void)testWorldGeographiesCaliforniaUSA
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addFullTextQueryTerm:@"los angeles"];
    FactualRowFilter* andFilter = [FactualRowFilter andFilter:
                                   [FactualRowFilter fieldName:@"name"
                                                      equalTo:@"California"],
                                   [FactualRowFilter fieldName:@"country"
                                                      equalTo:@"US"],
                                   [FactualRowFilter fieldName:@"placetype"
                                                       equalTo:@"region"], nil];
    [queryObject addRowFilter:andFilter];
    [queryObject addSelectTerm:@"contextname"];
    [queryObject addSelectTerm:@"factual_id"];
    [_apiObject queryTable:@"world-geographies" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    
}

- (void)testWorldGeographiesCitiesTownsInCalifornia
{
    FactualQuery* queryObject = [FactualQuery query];
    [queryObject addFullTextQueryTerm:@"los angeles"];
    FactualRowFilter* andFilter = [FactualRowFilter andFilter:
                                   [FactualRowFilter fieldName:@"ancestors"
                                                       includes:@"08649c86-8f76-11e1-848f-cfd5bf3ef515"],
                                   [FactualRowFilter fieldName:@"country"
                                                       equalTo:@"US"],
                                   [FactualRowFilter fieldName:@"placetype"
                                                       equalTo:@"locality"], nil];
    [queryObject addRowFilter:andFilter];
    [queryObject addSelectTerm:@"contextname"];
    [queryObject addSelectTerm:@"factual_id"];
    [_apiObject queryTable:@"world-geographies" optionalQueryParams:queryObject withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue([_queryResult.rows count] > 0, @"Invalid row count");
    
}

- (void)testSubmitAdd
{
    FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"a_user_id"];
    NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:11];
    [values setValue:@"Factual" forKey:@"name"];
    [values setValue:@"1999 Avenue of the Stars" forKey:@"address"];
    [values setValue:@"34th floor" forKey:@"address_extended"];
    [values setValue:@"Los Angeles" forKey:@"locality"];
    [values setValue:@"CA" forKey:@"region"];
    [values setValue:@"90067" forKey:@"postcode"];
    [values setValue:@"us" forKey:@"country"];
    [values setValue:@"34.058743" forKey:@"latitude"];
    [values setValue:@"-118.41694" forKey:@"longitude"];
    [values setValue:@"[209,213]" forKey:@"category_ids"];
    [values setValue:@"Mon 11:30am-2pm Tue-Fri 11:30am-2pm, 5:30pm-9pm Sat-Sun closed" forKey:@"hours"];
    [_apiObject submitRow:@"us-sandbox" withValues:values withMetadata:metadata withDelegate:self];
    
    [self waitForResponse];
    
    STAssertTrue(_rawResult != nil, @"Invalid response");
    
}

- (void)testFlagDuplicate
{
    FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"a_user_id"];
    metadata.preferred = @"9d676355-6c74-4cf6-8c4a-03fdaaa2d66a";
    [_apiObject flagProblem:FactualFlagType_Duplicate tableId: @"us-sandbox" factualId: @"4e4a14fe-988c-4f03-a8e7-0efc806d0a7f" metadata: metadata withDelegate:self];

    [self waitForResponse];
    
    STAssertTrue(_rawResult != nil, @"Invalid response");
}

- (void)testFlagClosed
{
    FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"a_user_id"];
    metadata.comment = @"was shut down when I went there yesterday.";
    [_apiObject flagProblem:FactualFlagType_Closed tableId: @"us-sandbox" factualId: @"4e4a14fe-988c-4f03-a8e7-0efc806d0a7f" metadata: metadata withDelegate:self];

    [self waitForResponse];
    
    STAssertTrue(_rawResult != nil, @"Invalid response");
    
}

- (void)testFlagRelocated
{
    FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"a_user_id"];
    metadata.preferred = @"9d676355-6c74-4cf6-8c4a-03fdaaa2d66a";
    [_apiObject flagProblem:FactualFlagType_Relocated tableId: @"us-sandbox" factualId: @"4e4a14fe-988c-4f03-a8e7-0efc806d0a7f" metadata: metadata withDelegate:self];

    [self waitForResponse];
    
    STAssertTrue(_rawResult != nil, @"Invalid response");
    
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

-(void) requestComplete:(FactualAPIRequest *)request receivedMatchResult:(NSString *)factualId {
    _matchResult = factualId;
    _finished = true;
}

-(void) requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"FAILED with error");
    _finished = true;
}
@end

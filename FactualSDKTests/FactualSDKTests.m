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


- (void)testFacet
{
    FactualQuery* query = [FactualQuery query];
    query.maxValuesPerFacet = 20;
    query.minCountPerFacetValue = 100;
    
    [query addRowFilter:[FactualRowFilter fieldName:@"country"
                                            equalTo:@"US"]];
    [query addSelectTerm:@"region"];
    [query addSelectTerm:@"locality"];
    [query addFullTextQueryTerm:@"Starbucks"];
    query.includeRowCount = true;
    
    [_apiObject facetTable:@"places" optionalQueryParams:query withDelegate:self];
    
    [self waitForResponse];
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
    NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
    [values setValue:@"McDonalds" forKey:@"name"];    
    [values setValue:@"10451 Santa Monica Blvd" forKey:@"address"];    
    [values setValue:@"CA" forKey:@"region"];    
    [values setValue:@"90025" forKey:@"postcode"];
    [_apiObject resolveRow:@"places" withValues:values withDelegate:self];
    
    [self waitForResponse];
    
} 


- (void)testGeopulse
{
    CLLocationCoordinate2D point = {_latitude, _longitude};
    NSMutableArray* terms = [[NSMutableArray alloc] initWithCapacity:2];
    [terms addObject:@"commercial_density"];
    [terms addObject:@"commercial_profile"];
    [_apiObject queryGeopulse:point selectTerms:terms withDelegate:self];
    [self waitForResponse];
}

- (void)testMatch
{
    NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
    [values setValue:@"McDonalds" forKey:@"name"];    
    [values setValue:@"10451 Santa Monica Blvd" forKey:@"address"];    
    [values setValue:@"CA" forKey:@"region"];    
    [values setValue:@"90025" forKey:@"postcode"];
    [_apiObject matchRow:@"places" withValues:values withDelegate:self];
    
    [self waitForResponse];
    
    NSLog(@"MATCH RESULT: %@", _matchResult);
}

- (void)testSchema
{
    [_apiObject getTableSchema:@"restaurants-us" withDelegate:self];
    
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
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 [_apiObject flagProblem:FactualFlagType_Duplicate tableId: @"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testFlagInaccurate
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 [_apiObject flagProblem:FactualFlagType_Inaccurate tableId:@"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testFlagInappropriate
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 [_apiObject flagProblem:FactualFlagType_Inappropriate tableId: @"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testFlagNonExistent
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 [_apiObject flagProblem:FactualFlagType_Nonexistent tableId: @"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testFlagSpam
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 [_apiObject flagProblem:FactualFlagType_Spam tableId: @"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testFlagOther
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 [_apiObject flagProblem:FactualFlagType_Other tableId: @"2EH4Pz" factualId: @"f33527e0-a8b4-4808-a820-2686f18cb00c" metadata: metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testSubmitAdd
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 
 NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
 [values setValue:@"100" forKey:@"longitude"];   
 
 [_apiObject submitRow:@"2EH4Pz" withValues:values withMetadata:metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testSubmitEdit
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 
 NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
 [values setValue:@"100" forKey:@"longitude"];    
 
 [_apiObject submitRowWithId:@"f33527e0-a8b4-4808-a820-2686f18cb00c" tableId:@"2EH4Pz" withValues:values withMetadata:metadata withDelegate:self];
 [self waitForResponse];
 }
 
 - (void)testSubmitDelete
 {
 FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"testuser"];
 metadata.comment = @"my comment";
 metadata.reference = @"www.mytest.com";
 
 NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
 [values setValue:@"null" forKey:@"longitude"];    
 
 [_apiObject submitRowWithId:@"f33527e0-a8b4-4808-a820-2686f18cb00c" tableId:@"2EH4Pz" withValues:values withMetadata:metadata withDelegate:self];
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

-(void) requestComplete:(FactualAPIRequest *)request receivedMatchResult:(NSString *)factualId {
    _matchResult = factualId;
    _finished = true;
}

-(void) requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"FAILED with error");
    _finished = true;
}
@end

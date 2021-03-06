# Factual IOS SDK

## Get an API Key
Obtain an oauth key and secret from Factual at [https://www.factual.com/api-keys/request](https://www.factual.com/api-keys/request).  Do not expose your _secret_ to third-parties (keep it secret).

## Installation

### Distribution

1.	Download the latest driver [version 1.3.9](https://github.com/Factual/factual-ios-sdk/blob/develop/downloads/factual-ios-sdk-1.3.9.tgz?raw=true)
2.	Untar and add the FactualSDK.framework to your appropriate XCode project directory. Add it to the list of linked frameworks in your project. 

**IMPORTANT:**
Starting February 1, 2015, any new iOS app must have 64-bit support, and be build through the iOS 8 SDK. Version 1.3.9 of the Factual iOS driver or newer will meet the requirements. [Details from Apple.](https://developer.apple.com/news/?id=10202014a)
    
### Source

1.	Download the driver source
2.	Run makeFramework.sh.
3.	Add build/Framework/FactualSDK.framework to your appropriate XCode project directory.  Add it to the list of linked frameworks in your project. 


## Sample Code

Refer to the Factual IOS SDK Demo project at [https://github.com/Factual/factual-ios-sdk-demo]( https://github.com/Factual/factual-ios-sdk-demo ) for an example of how to use the SDK. 

## Supported Platforms

The SDK supports armv6, armv7, and armv7s architectures. It is built to support IOS versions 3.2 and 
onwards but it officially supports devices running IOS 4.3 and higher.  ARC is supported by the SDK.

## Special Considerations

The SDK currently is built as a static library. IOS applications linking against the SDK must specify 
the -all_load linker flag as documented here ( http://developer.apple.com/library/mac/#qa/qa1490/_index.html ).


## Schema
Use the schema API call to determine which fields are available, the datatypes of those fields, and which operations (sorting, searching, writing, facetting) can be performed on each field.

Full documentation: http://developer.factual.com/api-docs/#Schema
```objc
[_apiObject getTableSchema:@"places-us" withDelegate:self];
[self waitForResponse];
```

## Read
Use the read API call to query data in Factual tables with any combination of full-text search, parametric filtering, and geo-location filtering.

Full documentation: http://developer.factual.com/api-docs/#Read

Related place-specific documentation:
* Categories: http://developer.factual.com/working-with-categories/
* Placerank, Sorting: http://developer.factual.com/search-placerank-and-boost/

```objc
// Full-text search:
FactualQuery* queryObject = [FactualQuery query];
[queryObject addFullTextQueryTerm:@"century city mall"];
queryObject.includeRowCount = true;
[_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];

// Row filters:
//  search restaurants (http://developer.factual.com/working-with-categories/)
//  note that this will return all sub-categories of 347 as well.
FactualQuery* queryObject = [FactualQuery query];
[queryObject addRowFilter:[FactualRowFilter fieldName:@"category_ids"
                                            includes:@"347"]];
[_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];


//  search restaurants or bars
NSMutableArray* categories = [[NSMutableArray alloc] initWithCapacity:2];
[categories addObject:[NSNumber numberWithInteger:312]];
[categories addObject:[NSNumber numberWithInteger:347]];
FactualQuery* queryObject = [FactualQuery query];
[queryObject addRowFilter:[FactualRowFilter fieldName:@"category_ids"
                                            includesAnyArray: categories]];
[_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];


//  search entertainment venues but NOT adult entertainment
FactualQuery* queryObject = [FactualQuery query];
FactualRowFilter* andFilter = [FactualRowFilter andFilter:
                               [FactualRowFilter fieldName:@"category_ids"
                                                 includes:@"317"],
                               [FactualRowFilter fieldName:@"category_ids"
                                                 excludes:@"318"], nil];
[queryObject addRowFilter:andFilter];
[_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];

//  search for Starbucks in Los Angeles
FactualQuery* queryObject = [FactualQuery query];
[queryObject addFullTextQueryTerm:@"starbucks"];
[queryObject addRowFilter:[FactualRowFilter fieldName:@"locality" equalTo:@"los angeles"]];
[_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];

//  search for starbucks in Los Angeles or Santa Monica 
FactualQuery* queryObject = [FactualQuery query];
[queryObject addFullTextQueryTerm:@"starbucks"];
FactualRowFilter* orFilter = [FactualRowFilter orFilter:
                               [FactualRowFilter fieldName:@"locality"
                                                  equalTo:@"los angeles"],
                               [FactualRowFilter fieldName:@"locality"
                                                  equalTo:@"santa monica"], nil];
[queryObject addRowFilter:orFilter];
[_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];

// Paging:
//  search for starbucks in Los Angeles or Santa Monica (second page of results):
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

// Geo filter:
//  coffee near the Factual office
FactualQuery* queryObject = [FactualQuery query];
[queryObject addFullTextQueryTerm:@"coffee"];
CLLocationCoordinate2D coordinate = {34.058583, -118.416582};
[queryObject setGeoFilter:coordinate
           radiusInMeters:1000];
[_apiObject queryTable:@"places-us" optionalQueryParams:queryObject withDelegate:self];

// Existence threshold:
//  prefer precision over recall:
NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
[params setValue:@"confident" forKey:@"threshold"];
[_apiObject get:@"t/places-us" params:params withDelegate: self];

// Get a row by factual id:
[_apiObject get:@"t/places-us/03c26917-5d66-4de9-96bc-b13066173c65" params:[[NSMutableDictionary alloc] init] withDelegate: self];

```

## Facets
Use the facets call to get summarized counts, grouped by specified fields.

Full documentation: http://developer.factual.com/api-docs/#Facets
```objc
// show top 5 cities that have more than 20 Starbucks in California
FactualQuery* query = [FactualQuery query];
query.minCountPerFacetValue = 20;
query.limit = 5;
[query addRowFilter:[FactualRowFilter fieldName:@"region"
                                        equalTo:@"CA"]];
[query addSelectTerm:@"locality"];
[query addFullTextQueryTerm:@"starbucks"];
[_apiObject facetTable:@"places-us" optionalQueryParams:query withDelegate:self];
```

## Resolve
Use resolve to generate a confidence-based match to an existing set of place attributes.

Full documentation: http://developer.factual.com/api-docs/#Resolve
```objc
// resolve from name and address info
NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
[values setValue:@"McDonalds" forKey:@"name"];
[values setValue:@"10451 Santa Monica Blvd" forKey:@"address"];
[values setValue:@"CA" forKey:@"region"];
[values setValue:@"90025" forKey:@"postcode"];
[_apiObject resolveRow:@"t/places-us" withValues:values withDelegate:self];

// resolve from name and geo location
NSMutableDictionary* values  = [NSMutableDictionary dictionaryWithCapacity:4];
[values setValue:@"McDonalds" forKey:@"name"];
[values setValue:@"34.05671" forKey:@"latitude"];
[values setValue:@"-118.42586" forKey:@"longitude"];
[_apiObject resolveRow:@"t/places-us" withValues:values withDelegate:self];
```

## Crosswalk
Crosswalk contains third party mappings between entities.

Full documentation: http://developer.factual.com/places-crosswalk/

```objc
// Query with factual id, and only show entites from Yelp:
FactualQuery* queryObject = [FactualQuery query];
[queryObject addRowFilter:[FactualRowFilter fieldName:@"factual_id"
                                              equalTo:@"3b9e2b46-4961-4a31-b90a-b5e0aed2a45e"]];
[queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace"
                                              equalTo:@"yelp"]];
[_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
```

```objc
// query with an entity from Foursquare:
FactualQuery* queryObject = [FactualQuery query];
[queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace_id"
                                              equalTo:@"4ae4df6df964a520019f21e3"]];
[queryObject addRowFilter:[FactualRowFilter fieldName:@"namespace"
                                              equalTo:@"foursquare"]];
[_apiObject queryTable:@"crosswalk" optionalQueryParams:queryObject withDelegate:self];
```

## World Geographies
World Geographies contains administrative geographies (states, counties, countries), natural geographies (rivers, oceans, continents), and assorted geographic miscallaney.  This resource is intended to complement the Global Places and add utility to any geo-related content.

```objc
// find California, USA
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
// returns 08649c86-8f76-11e1-848f-cfd5bf3ef515 as the Factual Id of "California, US"
```

```objc
// find cities and town in California (first 20 rows)
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
```

## Submit
Submit new data, or update existing data. Submit behaves as an "upsert", meaning that Factual will attempt to match the provided data against any existing places first. Note: you should ALWAYS store the *commit ID* returned from the response for any future support requests.

Full documentation: http://developer.factual.com/api-docs/#Submit

Place-specific Write API documentation: http://developer.factual.com/write-api/

```objc
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
```

## Flag
Use the flag API to flag problems in existing data.

Full documentation: http://developer.factual.com/api-docs/#Flag

Flag a place that is a duplicate of another. The *preferred* entity that should persist is passed as a GET parameter.
```objc
FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"a_user_id"];
metadata.preferred = @"9d676355-6c74-4cf6-8c4a-03fdaaa2d66a";
[_apiObject flagProblem:FactualFlagType_Duplicate tableId: @"us-sandbox" factualId: @"4e4a14fe-988c-4f03-a8e7-0efc806d0a7f" metadata: metadata withDelegate:self];
[self waitForResponse];
```

Flag a place that is closed.
```objc
FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"a_user_id"];
metadata.comment = @"was shut down when I went there yesterday.";
[_apiObject flagProblem:FactualFlagType_Closed tableId: @"us-sandbox" factualId: @"4e4a14fe-988c-4f03-a8e7-0efc806d0a7f" metadata: metadata withDelegate:self];
```

Flag a place that has been relocated, so that it will redirect to the new location. The *preferred* entity (the current location) is passed as a GET parameter. The old location is identified in the URL.
```objc
FactualRowMetadata* metadata = [FactualRowMetadata metadata: @"a_user_id"];
metadata.preferred = @"9d676355-6c74-4cf6-8c4a-03fdaaa2d66a";
[_apiObject flagProblem:FactualFlagType_Relocated tableId: @"us-sandbox" factualId: @"4e4a14fe-988c-4f03-a8e7-0efc806d0a7f" metadata: metadata withDelegate:self];
```

## Error Handling
The error object is the first argument of the callback functions, it will be null if no errors.

## Debug Mode
To see detailed debug information at runtime, you can turn on Debug Mode:
```objc
// start debug mode
_apiObject.debug = true;

// run your querie(s)

// stop debug mode
_apiObject.debug = false;
```
Debug Mode will output useful information about what's going on, including  the request sent to Factual and the response from Factual, outputting to stdout and stderr.


## Custom timeouts
You can set the request timeout (in milliseconds):
```objc
// set the timeout as 1 second
_apiObject.timeoutInterval = 1;
// clear the custom timeout setting (by setting it to the default value)
_apiObject.timeoutInterval = 180;
```
You will get [Error: socket hang up] for custom timeout errors.


# Where to Get Help

If you think you've identified a specific bug in this driver, please file an issue in the github repo. Please be as specific as you can, including:

  * What you did to surface the bug
  * What you expected to happen
  * What actually happened
  * Detailed stack trace and/or line numbers

If you are having any other kind of issue, such as unexpected data or strange behaviour from Factual's API (or you're just not sure WHAT'S going on), please contact us through the [Factual support site](http://support.factual.com/factual).


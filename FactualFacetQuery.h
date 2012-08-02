//
//  FactualFacetQuery.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/30/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FactualQuery.h"
#import "FactualQueryImpl.h"

/*!@abstract Encapsulates all the parameters supported by the Factual Facet API
 @discussion
 */
@interface FactualFacetQuery : NSObject 

/*! @property 
 @discussion For each facet value count, the minimum number of results it must have in order to be returned in the response. Must be zero or greater. The default is 1.
 */ 
@property (nonatomic, assign) NSUInteger minCountPerFacetValue;

/*! @property 
 @discussion The maximum number of unique facet values that can be returned for a single field. Range is 1-250. The default is 25.
 */ 
@property (nonatomic, assign) NSUInteger maxValuesPerFacet;

/*! @property 
 @discussion filter the results by a specific row id. Setting a rowId filter 
 invalidates all other filter criteria and returns either 0 or 1 records
 */ 
@property (nonatomic, copy) NSString* rowId;

/*! @property 
 @discussion used to specify the offset (number of records to skip) when
 paginating a large record set.
 */ 
@property (nonatomic, assign) NSUInteger offset;
/*! @property 
 @discussion used to limit the number of returned records in a single response.
 This system will return the lessor of either the limit value or the max limit 
 value associated with the user's API Key.
 paginating a large record set.
 */ 
@property (nonatomic, assign) NSUInteger limit;

/*! @property 
 @discussion set the primary sort criteria for the query in context. This 
 parameter is ignored in the case of full-text (see below) or geo (see below 
 queries).
 */
@property (nonatomic,retain) FactualSortCriteria* primarySortCriteria;
/*! @property 
 @discussion set the secondary sort criteria for the query in context. Same
 restrictions as the pimrary sort criteria
 */
@property (nonatomic,retain) FactualSortCriteria* secondarySortCriteria;
/*! @property 
 @discussion row filter that are going to be applied to this query 
 */
@property (nonatomic,readonly) NSMutableArray* rowFilters;
/*! @property 
 @discussion text query terms used to perform a full-text query 
 */
@property(nonatomic,readonly) NSMutableArray* fullTextTerms;

/*! @property 
 @discussion when true, the response will include a count of the total number of rows in
 * the table that conform to the request based on included filters.
 * Requesting the row count will increase the time required to return a
 * response. The default behavior is to NOT include a row count 
 */
@property (nonatomic, assign) BOOL includeRowCount;

/*! @property 
 @discussion Sets the fields to select. This is optional.
 */
@property (nonatomic,readonly) NSMutableArray* selectTerms;

@property(nonatomic,retain)   FactualGeoFilter* geoFilter;

@end


@interface FactualFacetQuery(FactualFacetQueryMethods)

+(FactualFacetQuery*) facetQuery;

/*! @method 
 @discussion add a text term to the full-text filter associated with the  
 query. Full-text queries are only valid if support for them has been enabled
 in the target Factual table. Follow the last term by a nil. 
 */
-(void) addFullTextQueryTerm:(NSString*) textTerm;

/*! @method 
 @discussion add one or more text terms to the full-text filter associated with the 
 query. Full-text queries are only valid if support for them has been enabled
 in the target Factual table. Follow the last term by a nil. 
 */
-(void) addFullTextQueryTerms:(NSString*) textTerm,... NS_REQUIRES_NIL_TERMINATION;

/*! @method 
 @discussion add one or more text terms, contained within the passed in NSArray,
 to the full-text filter associated with the query. Full-text queries are only valid
 if support for them has been enabled in the target Factual table. Follow the last
 term by a nil. 
 */
-(void) addFullTextQueryTermsFromArray:(NSArray*) terms;


/*! @method 
 @discussion clear all text terms previosuly associated with this query object
 */
-(void) clearFullTextFilter;

/*! @method 
 @discussion search records by location and radius. This filter type is only 
 valid for geo-enabled tables and if specified, the returned record set is 
 sorted by distance from the specified point, so the primary and secondary 
 sort criteria query fields are ignored if a geo filter has been specified.
 */
-(void) setGeoFilter:(CLLocationCoordinate2D)location radiusInMeters:(double)radius;
/*! @method 
 @discussion clear the previously set geo filter state
 */
-(void) clearGeoFilter;

/*! @method 
 @discussion add one or more row filters to the query. Row filters further limit
 the query results by applying the specified filters against any records returned
 as a result of any other query filter operations (full-text / geo). 
 */
-(void) addRowFilter:(FactualRowFilter*) rowFilter;
/*! @method 
 @discussion clear all previously set row filters 
 */
-(void) clearRowFilters;

/*! @method 
 @discussion clear all previously set row filters 
 */
-(void) addSelectTerm:(NSString*) selectTerm;

@end

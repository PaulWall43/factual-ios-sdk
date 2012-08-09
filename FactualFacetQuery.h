//
//  FactualFacetQuery.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/30/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@end


@interface FactualFacetQuery(FactualFacetQueryMethods)

+(FactualFacetQuery*) facetQuery;

@end

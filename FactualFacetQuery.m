//
//  FactualFacetQuery.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/30/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualQuery.h"
#import "FactualFacetQueryImpl.h"

@implementation FactualFacetQuery
@dynamic minCountPerFacetValue,maxValuesPerFacet,rowId,offset,limit,primarySortCriteria,secondarySortCriteria,rowFilters,fullTextTerms,includeRowCount,selectTerms,geoFilter;

+(FactualFacetQuery*) facetQuery {
    return [[FactualFacetQueryImplementation alloc] init];
}
@end


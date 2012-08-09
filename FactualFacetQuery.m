//
//  FactualFacetQuery.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/8/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualQuery.h"
#import "FactualFacetQueryImpl.h"

@implementation FactualFacetQuery
@dynamic minCountPerFacetValue,maxValuesPerFacet;

+(FactualFacetQuery*) facetQuery {
    return [[FactualFacetQueryImplementation alloc] init];
}
@end
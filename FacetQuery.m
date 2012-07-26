//
//  FacetQuery.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FacetQuery.h"


@implementation FacetQuery


@dynamic maxValuePerFacet,minCountPerFacetValue;
-(id) initFacet {
    if (self = [super init]) {
    }
    return self;
}
@end

@implementation FacetQueryImplementation
    @synthesize maxValuePerFacet=_maxValuePerFacet;
    @synthesize minCountPerFacetValue=_minCountPerFacetValue;
@end
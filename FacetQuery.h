//
//  FacetQuery.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualQuery.h"
#import "FactualQueryImpl.h"

@interface FacetQuery : FactualQuery
    @property (nonatomic, assign) NSUInteger maxValuePerFacet;
    @property (nonatomic, assign) NSUInteger minCountPerFacetValue;
    -(id) initFacet;
@end


@interface FacetQueryImplementation : FacetQuery {
    NSUInteger  _maxValuePerFacett;
    NSUInteger  _minCountPerFacetValue;
}

@end

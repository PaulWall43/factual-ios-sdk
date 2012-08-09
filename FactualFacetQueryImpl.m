//
//  FactualFacetQueryImpl.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/8/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//


#import "FactualFacetQueryImpl.h"
#import "CJSONSerializer.h"
#import "NSString (Escaping).h"
#import "FactualUrlUtil.h"

@implementation FactualFacetQueryImplementation

@synthesize minCountPerFacetValue=_minCountPerFacetValue;
@synthesize maxValuesPerFacet=_maxValuesPerFacet;

-(id) init {
    if (self = [super init]) {
        _maxValuesPerFacet  = -1;
        _minCountPerFacetValue  = -1;
    }
    return self;
}

-(void) generateQueryString:(NSMutableString*)qryString {
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
    if (_maxValuesPerFacet != -1) {
        [array addObject:[NSString stringWithFormat:@"limit=%d", _maxValuesPerFacet]];
    }
    if (_minCountPerFacetValue != -1) {
        [array addObject:[NSString stringWithFormat:@"min_count=%d", _minCountPerFacetValue]];
    }
    
    [FactualUrlUtil appendParams:array to:qryString];
}

@end
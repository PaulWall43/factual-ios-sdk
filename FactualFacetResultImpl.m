//
//  FactualFacetResponseImpl.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualFacetResultImpl.h"

@implementation FactualFacetResultImpl

@synthesize data=_data;
@synthesize totalRows=_totalRows;

-(id) initWithJson:(NSDictionary *)jsonResponse {
    if (self = [super init]) {
        _data = [jsonResponse objectForKey:@"data"];
        NSNumber *theTotalRows = [jsonResponse objectForKey:@"total_row_count"];
        if (theTotalRows) {
            _totalRows = [theTotalRows unsignedIntValue];
        }
    }
    return self;
}            

+(FactualFacetResult *) facetResponseFromJSON:(NSDictionary *)jsonResponse {
    return [[FactualFacetResultImpl alloc] initWithJson:jsonResponse];
}

@end

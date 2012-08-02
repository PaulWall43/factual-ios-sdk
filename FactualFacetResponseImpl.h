//
//  FactualFacetResponseImpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualFacetResponse.h"

@interface FactualFacetResponseImpl : FactualFacetResponse {
    NSUInteger       _totalRows;
    NSMutableDictionary* _data;
}

-(id) initWithJson:(NSDictionary *)jsonResponse;

+(FactualFacetResponse *) facetResponseFromJSON:(NSDictionary *)jsonResponse;

@end

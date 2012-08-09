//
//  FactualFacetQueryImpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/30/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FactualFacetQuery.h"

@interface FactualFacetQueryImplementation : FactualFacetQuery {
    NSUInteger  _minCountPerFacetValue;
    NSUInteger  _maxValuesPerFacet;
}
-(void) generateQueryString:(NSMutableString*)qryString;
@end

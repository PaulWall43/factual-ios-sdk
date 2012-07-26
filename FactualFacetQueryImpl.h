//
//  FactualFacetQueryImpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/30/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FactualFacetQuery.h"
#import "FactualQueryImpl.h"

@interface FactualFacetQueryImplementation : FactualFacetQuery {
    NSUInteger  _minCountPerFacetValue;
    NSUInteger  _maxValuesPerFacet;
    NSString*   _rowId;
    NSUInteger  _offset;
    NSUInteger  _limit;
    FactualSortCriteria* _primarySortCriteria;
    FactualSortCriteria* _secondarySortCriteria;
    NSMutableArray*    _rowFilters;
    NSMutableArray*    _textTerms;
    FactualGeoFilter* _geoFilter;
    NSMutableArray*    _selectTerms;
}
@end

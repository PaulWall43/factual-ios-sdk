//
//  FactualFacetQueryImpl.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/30/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualFacetQueryImpl.h"
#import "CJSONSerializer.h"
#import "NSString (Escaping).h"
#import "FactualUrlUtil.h"

@implementation FactualFacetQueryImplementation

@synthesize minCountPerFacetValue=_minCountPerFacetValue;
@synthesize maxValuesPerFacet=_maxValuesPerFacet;


@synthesize rowId=_rowId;
@synthesize offset=_offset;
@synthesize limit=_limit;
@synthesize primarySortCriteria=_primarySortCriteria;
@synthesize secondarySortCriteria=_secondarySortCriteria;
@synthesize fullTextTerms=_textTerms;
@synthesize rowFilters=_rowFilters;
@synthesize geoFilter=_geoFilter;
@synthesize includeRowCount=_includeRowCount;
@synthesize selectTerms=_selectTerms;


-(id) init {
    if (self = [super init]) {
        _rowFilters = [NSMutableArray arrayWithCapacity:0];
        _textTerms  = [NSMutableArray arrayWithCapacity:0];
        _selectTerms  = [NSMutableArray arrayWithCapacity:0];
        _offset = 0;
        _limit  = 0;
        _maxValuesPerFacet  = 0;
        _minCountPerFacetValue  = 0;
        _includeRowCount = false;
    }
    return self;
}

-(void) addFullTextQueryTerm:(NSString*) textTerm {
    if ([textTerm length] != 0) {
        [_textTerms addObject:textTerm];    
    }
}

-(void) addFullTextQueryTerms:(NSString*) textTerm,... {
    va_list args;
    va_start(args, textTerm);
    
    for (NSString *arg = textTerm; arg != nil; arg = va_arg(args, NSString*)) {
        [_textTerms addObject:arg];
    }
    va_end(args);
}

-(void) addFullTextQueryTermsFromArray:(NSArray*) termArray {
    for (NSString* term in termArray) {
        if ([term length] >0) {
            [_textTerms addObject:term];
        }
    }
}

-(void) addSelectTerm:(NSString*) selectTerm {
    if ([selectTerm length] != 0) {
        [_selectTerms addObject:selectTerm];    
    }
}

-(void) clearFullTextFilter {
    [_textTerms removeAllObjects];
}

-(void) setGeoFilter:(CLLocationCoordinate2D)location radiusInMeters:(double)radius {
    self.geoFilter = [FactualGeoFilter createDistanceFromPointGeoFilter:location distance:radius];
}

-(void) clearGeoFilter {
    self.geoFilter = nil;
}

-(void) addRowFilter:(FactualRowFilter*) rowFilter {
    [_rowFilters addObject:rowFilter];
}

-(void) clearRowFilters {
    [_rowFilters removeAllObjects];
}

-(void) generateQueryString:(NSMutableString*)qryString {
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (_includeRowCount) {
        [array addObject:[NSString stringWithFormat:@"include_count=true"]];
    }
    
    if (_limit > 0) {
        [array addObject:[NSString stringWithFormat:@"limit=%d", _limit]];
    }
    
    if (_offset > 0) {
        [array addObject:[NSString stringWithFormat:@"offset=%d", _offset]];
    }
    
    if (_primarySortCriteria != nil || _secondarySortCriteria != nil) {
        NSMutableString* sortStr = [[NSMutableString alloc]init ];
        [sortStr appendString:@"sort="];
        if (_primarySortCriteria != nil) {
            [_primarySortCriteria generateQueryString:sortStr];
            if (_secondarySortCriteria != nil) {
                [sortStr appendString:@","];
            }
        }
        if (_secondarySortCriteria != nil) {
            [_secondarySortCriteria generateQueryString:sortStr];
        }
        [array addObject:sortStr];
    }
    
    if ([_rowFilters count] != 0) {
        NSMutableDictionary* filterDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        if ([_rowFilters count] == 1) {
            [[_rowFilters objectAtIndex: 0] appendToDictionary:filterDictionary];
        } else {
            FactualCompoundRowFilterPredicate* andFilter = [[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:And filterValues:_rowFilters];
            [andFilter appendToDictionary:filterDictionary];
        }
        NSError *error = nil;
        NSMutableString* filterStr = [[NSMutableString alloc]init ];
        [filterStr appendFormat:@"filters=%@",
         [[[NSString alloc] initWithData:
           [[CJSONSerializer serializer] serializeDictionary:filterDictionary  error:&error] 
                                encoding:NSUTF8StringEncoding]
          stringWithPercentEscape]];
        [array addObject:filterStr];
    }
    
    if ([_textTerms count] != 0) {
        NSMutableString* qString = [[NSMutableString alloc] init];
        int termNumber=0;
        for (NSString* term in _textTerms) {
            if(termNumber++ != 0) 
                [qString appendString:@","];
            [qString appendString:term];
        }
        
        [array addObject:[NSString stringWithFormat:@"q=%@",[qString stringWithPercentEscape]]];
        
    }
    if ([_selectTerms count] != 0) {
        NSMutableString* qString = [[NSMutableString alloc] init];
        int termNumber=0;
        for (NSString* term in _selectTerms) {
            if(termNumber++ != 0) 
                [qString appendString:@","];
            [qString appendString:term];
        }
        
        [array addObject:[NSString stringWithFormat:@"select=%@",[qString stringWithPercentEscape]]];
        
    }
    
    if (_geoFilter != nil) {
        NSMutableDictionary* geoDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [_geoFilter appendToDictionary:geoDictionary];
        
        NSError *error = nil;
        [array addObject:[NSString stringWithFormat:@"geo=%@",
                          [[[NSString alloc] initWithData:
                            [[CJSONSerializer serializer] serializeDictionary:geoDictionary error:&error] 
                                                 encoding:NSUTF8StringEncoding] stringWithPercentEscape]]];
    }
    
    if (_maxValuesPerFacet != 0) {
        [array addObject:[NSString stringWithFormat:@"limit=%d", _maxValuesPerFacet]];
    }
    if (_minCountPerFacetValue != 0) {
        [array addObject:[NSString stringWithFormat:@"min_count=%d", _minCountPerFacetValue]];
    }
    
    [FactualUrlUtil appendParams:array to:qryString];
}

@end
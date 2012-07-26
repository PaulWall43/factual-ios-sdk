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
#import "UrlUtil.h"

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
    
    if (self.includeRowCount) {
        [array addObject:[NSString stringWithFormat:@"include_count=true"]];
    }
    //[qryString appendString:@"include_count=t&"];
    
    if (self.rowId != nil) {
        [array addObject:[NSString stringWithFormat:@"subjectKey=%@",
                          [self.rowId stringWithPercentEscape]]];
        /*
         [qryString appendFormat:@"subjectKey=%@&",
		 [self.rowId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
         */
    }
    else {
        if (self.limit > 0) {
            [array addObject:[NSString stringWithFormat:@"limit=%d", self.limit]];
            //[qryString appendFormat:@"limit=%d&", self.limit];
        }
        
        if (self.offset > 0) {
            [array addObject:[NSString stringWithFormat:@"offset=%d", self.offset]];
            //[qryString appendFormat:@"offset=%d&", self.offset];
        }
        
        if (self.primarySortCriteria != nil || self.secondarySortCriteria != nil) {
            NSMutableString* sortStr = [[NSMutableString alloc]init ];
            [sortStr appendString:@"sort="];
            if (self.primarySortCriteria != nil) {
                [self.primarySortCriteria generateQueryString:sortStr];
                if (self.secondarySortCriteria != nil) {
                    [sortStr appendString:@","];
                }
            }
            if (self.secondarySortCriteria != nil) {
                [self.secondarySortCriteria generateQueryString:sortStr];
            }
            [array addObject:sortStr];
            //[qryString appendString:sortStr];
            //[qryString appendString:@"&"];
        }
        
        
        if ([self.rowFilters count] != 0) {
            NSMutableDictionary* filterDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            if ([self.rowFilters count] == 1) {
                [[self.rowFilters objectAtIndex: 0] appendToDictionary:filterDictionary];
            } else {
                FactualCompoundRowFilterPredicate* andFilter = [[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:And filterValues:self.rowFilters];
                [andFilter appendToDictionary:filterDictionary];
            }
            
            NSMutableString* filterStr = [[NSMutableString alloc]init ];
            
            NSError *error = NULL;
            NSData *serial = [[CJSONSerializer serializer] serializeDictionary:filterDictionary error:&error];
            NSString *str = [[NSString alloc] initWithData: serial encoding: NSUTF8StringEncoding];
            
            
            [filterStr appendFormat:@"filters=%@",[str
              stringWithPercentEscape]];
            
            [array addObject:filterStr];
            //[qryString appendString:filterStr];
            //[qryString appendString:@"&"];
        }
        
        if ([self.fullTextTerms count] != 0) {
            NSMutableString* qString = [[NSMutableString alloc] init];
            int termNumber=0;
            for (NSString* term in self.fullTextTerms) {
                if(termNumber++ != 0) 
                    [qString appendString:@","];
                [qString appendString:term];
            }
            
            [array addObject:[NSString stringWithFormat:@"q=%@",[qString stringWithPercentEscape]]];
            
            //[qryString appendFormat:@"q=%@&",[qString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        if ([self.selectTerms count] != 0) {
            NSMutableString* qString = [[NSMutableString alloc] init];
            int termNumber=0;
            for (NSString* term in self.selectTerms) {
                if(termNumber++ != 0) 
                    [qString appendString:@","];
                [qString appendString:term];
            }
            
            [array addObject:[NSString stringWithFormat:@"select=%@",[qString stringWithPercentEscape]]];
            
            //[qryString appendFormat:@"q=%@&",[qString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if (self.geoFilter != nil) {
            NSMutableDictionary* geoDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            [self.geoFilter appendToDictionary:geoDictionary];

            NSError *error = NULL;
            NSData *serial = [[CJSONSerializer serializer] serializeDictionary:geoDictionary error:&error];
            NSString *str = [[NSString alloc] initWithData: serial encoding: NSUTF8StringEncoding];
            
            [array addObject:[NSString stringWithFormat:@"geo=%@",
                              [str stringWithPercentEscape]]];
            
            /*[qryString appendFormat:@"geo=%@",
             [[[[CJSONSerializer serializer] serializeDictionary:geoDictionary] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] ];    
             */
            
        }
        
        if (self.maxValuesPerFacet != 0) {
            [array addObject:[NSString stringWithFormat:@"limit=%d", self.maxValuesPerFacet]];
        }
        if (self.minCountPerFacetValue != 0) {
            [array addObject:[NSString stringWithFormat:@"min_count=%d", self.minCountPerFacetValue]];
        }
    }
    
    [UrlUtil appendParams:array to:qryString];
}

@end
//
//  GeopulseImpl.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualGeopulseImpl.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualGeopulseImpl

@synthesize selectTerms=_selectTerms;
@synthesize point=_point;

-(id) initWithPoint:(CLLocationCoordinate2D) location {
    if (self = [super init]) {
        _point = location;
        _selectTerms  = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

-(void) addSelectTerm:(NSString*) selectTerm {
    if ([selectTerm length] != 0) {
        [_selectTerms addObject:selectTerm];    
    }
}

-(void) generateQueryString:(NSMutableString*)queryString {
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:2];
    [params addObject:[NSString stringWithFormat:@"geo=%@", [FactualUrlUtil locationToJson: _point]]];
    if ([_selectTerms count] != 0) {
        NSMutableString* selectValues = [[NSMutableString alloc] init];
        int termNumber=0;
        for (NSString* term in _selectTerms) {
            if(termNumber++ != 0) 
                [selectValues appendString:@","];
            [selectValues appendString:term];
        }
        [params addObject:[NSString stringWithFormat:@"select=%@",[selectValues stringWithPercentEscape]]];
    }
    [FactualUrlUtil appendParams:params to:queryString];
}  
@end

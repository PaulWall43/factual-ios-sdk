//
//  Geopulse.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "Geopulse.h"
#import "FactualPoint.h"
#import "UrlUtil.h"
#import "NSString (Escaping).h"

@implementation Geopulse
@synthesize point=_point;
@synthesize selectTerms=_selectTerms;

-(id) initWithPoint:(FactualPoint*) point {
    if (self = [super init]) {
        self.point = point;
        _selectTerms  = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
-(void) addSelectTerm:(NSString*) selectTerm {
    if ([selectTerm length] != 0) {
        [_selectTerms addObject:selectTerm];    
    }
}

-(void) generateQueryString:(NSMutableString*)qryString {
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
    if (self.point) {
        [array addObject:[NSString stringWithFormat:@"geo=%@", [self.point toJson]]];
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
    }
    [UrlUtil appendParams:array to:qryString];
}  
@end
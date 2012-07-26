//
//  Geopulse.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FactualPoint.h"

@interface Geopulse : NSObject
    @property (nonatomic, retain) NSMutableArray* selectTerms;
    @property (nonatomic, retain) FactualPoint* point;
    -(id) initWithPoint:(FactualPoint*) point;
    -(void) addSelectTerm:(NSString*) selectTerm;
    -(void) generateQueryString:(NSMutableString*)qryString;
@end

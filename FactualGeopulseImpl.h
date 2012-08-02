//
//  GeopulseImpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FactualGeopulse.h"
#import <CoreLocation/CoreLocation.h>

@interface FactualGeopulseImpl : FactualGeopulse {
    NSMutableArray* selectTerms;
    CLLocationCoordinate2D point;
}
-(void) generateQueryString:(NSMutableString*)queryString;
-(id) initWithPoint:(CLLocationCoordinate2D) point;
@end

//
//  Geopulse.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualGeopulse.h"
#import "FactualGeopulseImpl.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"
#import <CoreLocation/CoreLocation.h>

@implementation FactualGeopulse

@dynamic point,selectTerms;

+(FactualGeopulse*) geopulse:(CLLocationCoordinate2D) point  {
    return [[FactualGeopulseImpl alloc] initWithPoint: point];
}
@end
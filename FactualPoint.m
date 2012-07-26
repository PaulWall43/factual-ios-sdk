//
//  Point.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualPoint.h"
#import "CJSONSerializer.h"
#import "NSString (Escaping).h"

@implementation FactualPoint

@synthesize latitude=_latitude;
@synthesize longitude=_longitude;

-(id) initWithLatitude:(double) latitude longitude:(double) longitude {
    if (self = [super init]) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

-(NSString*) toJson {
    NSMutableDictionary* locationDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray* pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    [pointArray addObject:[NSNumber numberWithDouble: self.latitude]];
    [pointArray addObject:[NSNumber numberWithDouble: self.longitude]];
    [locationDict setValue: pointArray forKey:@"$point"];
    NSError *error = NULL;
    NSData *serial = [[CJSONSerializer serializer] serializeObject:locationDict error:&error];
    NSString *str = [[NSString alloc] initWithData: serial encoding: NSUTF8StringEncoding];
    return [str stringWithPercentEscape];
}
@end

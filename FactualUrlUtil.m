//
//  UrlUtil.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualUrlUtil.h"
#import "CJSONSerializer.h"
#import "NSString (Escaping).h"
#import <CoreLocation/CoreLocation.h>

@implementation FactualUrlUtil
+(void) appendParams:(NSMutableArray*)array to: (NSMutableString*)qryString {
    int paramCount=0;
    for (NSString* str in array) {
        if (paramCount++ != 0) 
            [qryString appendString:@"&"];
        [qryString appendString:str];
    }
}

+(NSString*) locationToJson: (CLLocationCoordinate2D) location {
    NSMutableDictionary* locationDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray* pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    [pointArray addObject:[NSNumber numberWithDouble: location.latitude]];
    [pointArray addObject:[NSNumber numberWithDouble: location.longitude]];
    [locationDict setValue: pointArray forKey:@"$point"];
    NSError *error = NULL;
    NSData *serialized = [[CJSONSerializer serializer] serializeObject:locationDict error:&error];
    NSString *serializedStr = [[NSString alloc] initWithData: serialized encoding: NSUTF8StringEncoding];
    return [serializedStr stringWithPercentEscape];
}
@end

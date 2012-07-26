//
//  UrlUtil.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "UrlUtil.h"

@implementation UrlUtil
+(void) appendParams:(NSMutableArray*)array to: (NSMutableString*)qryString {
    int paramCount=0;
    for (NSString* str in array) {
        if (paramCount++ != 0) 
            [qryString appendString:@"&"];
        [qryString appendString:str];
    }
}
@end

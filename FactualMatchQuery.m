//
//  MatchQuery.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/2/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualMatchQuery.h"
#import "FactualMatchQueryImpl.h"
#import "CJSONSerializer.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualMatchQuery

@dynamic values;

+(FactualMatchQuery*) match {
    return [[FactualMatchQueryImpl alloc] init];
}

@end
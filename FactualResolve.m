//
//  Resolve.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualResolve.h"
#import "FactualResolveImpl.h"
#import "CJSONSerializer.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualResolve

@dynamic values;

+(FactualResolve*) resolve {
    return [[FactualResolveImpl alloc] init];
}

@end

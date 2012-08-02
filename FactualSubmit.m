//
//  FactualSubmit.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/1/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualSubmit.h"
#import "FactualSubmitImpl.h"

@implementation FactualSubmit

@dynamic values;
+(FactualSubmit*) submit {
    return [[FactualSubmitImpl alloc] init];
}
@end

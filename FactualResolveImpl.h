//
//  ResolveImpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualResolve.h"

@interface FactualResolveImpl : FactualResolve
{
    NSMutableDictionary* values;
}
-(void) generateQueryString:(NSMutableString*)qryString;

@end
//
//  MatchQueryImpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/2/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualMatchQuery.h"

@interface FactualMatchQueryImpl : FactualMatchQuery
{
    NSMutableDictionary* values;
}
-(void) generateQueryString:(NSMutableString*)qryString;

@end
//
//  MatchQueryImpl.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/2/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualMatchQueryImpl.h"
#import "CJSONSerializer.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualMatchQueryImpl

@synthesize values=_values;

-(id) init {
    if (self = [super init]) {
        _values  = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

-(void) addProperty:(NSString*) prop value:(NSString*) value {
    [_values setValue:value forKey:prop];    
}

-(void) generateQueryString:(NSMutableString*) queryString {
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:1];
    if ([_values count] != 0) {
        NSError *error = NULL;
        NSData *serialized = [[CJSONSerializer serializer] serializeObject:_values error:&error];
        NSString *serializedStr = [[NSString alloc] initWithData: serialized encoding: NSUTF8StringEncoding];
        [params addObject:[NSString stringWithFormat:@"values=%@", [serializedStr stringWithPercentEscape]]];
    }
    return [FactualUrlUtil appendParams:params to:queryString];
}
@end
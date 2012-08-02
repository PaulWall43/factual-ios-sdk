//
//  FactualSubmitImpl.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/1/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualSubmitImpl.h"
#import "CJSONSerializer.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualSubmitImpl

@synthesize values=_values;

-(void) addProperty:(NSString*) prop value:(NSString*) value {
    [_values setValue:value forKey:prop];    
}

-(void) removeValue:(NSString*) prop {
    [_values setValue:nil forKey:prop];    
}

-(id) init {
    if (self = [super init]) {
        _values  = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

-(void) generateQueryString:(NSMutableString*) queryString {
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:1];
    NSError *error = NULL;
    NSData *serialized = [[CJSONSerializer serializer] serializeObject:_values error:&error];
    NSString *serializedStr = [[NSString alloc] initWithData: serialized encoding: NSUTF8StringEncoding];
    [params addObject:[NSString stringWithFormat:@"values=%@", [serializedStr stringWithPercentEscape]]];
    return [FactualUrlUtil appendParams:params to:queryString];
}
@end

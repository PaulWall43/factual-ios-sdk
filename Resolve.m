//
//  Resolve.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "Resolve.h"
#import "CJSONSerializer.h"
#import "UrlUtil.h"
#import "NSString (Escaping).h"

@implementation Resolve

@synthesize values=_values;

+(Resolve*) resolve {
    return [[Resolve alloc] init];
}

-(id) init {
    if (self = [super init]) {
        _values  = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

-(void) addProperty:(NSString*) prop value:(NSString*) value {
     [_values setValue:value forKey:prop];    
}

-(void) generateQueryString:(NSMutableString*)qryString {
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
    if ([self.values count] != 0) {
        
        NSError *error = NULL;
        NSData *serial = [[CJSONSerializer serializer] serializeObject:self.values error:&error];
        NSString *str = [[NSString alloc] initWithData: serial encoding: NSUTF8StringEncoding];
        
        [array addObject:[NSString stringWithFormat:@"values=%@", [str stringWithPercentEscape]]];
    }
    return [UrlUtil appendParams:array to:qryString];
}
@end

//
//  FactualMetadataIimpl.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/6/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualMetadataImpl.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualMetadataImpl

@synthesize username=_username;
@synthesize comment=_comment;
@synthesize reference=_reference;

-(void) generateQueryString:(NSMutableString*) queryString {
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:2];
    if (_username != nil) {
        [params addObject:[NSString stringWithFormat:@"user=%@", _username]];
    }
    if (_comment != nil) {
        [params addObject:[NSString stringWithFormat:@"comment=%@", _comment]];
    }
    if (_reference != nil) {
        [params addObject:[NSString stringWithFormat:@"reference=%@", _reference]];
    }
    return [FactualUrlUtil appendParams:params to:queryString];
}


-(id) initWithUserName: (NSString *) username {
    if (self = [super init]) {
        _username = username;
    }
    return self;
}

@end

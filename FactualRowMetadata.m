//
//  FactualMetadata.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/1/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualRowMetadata.h"
#import "FactualRowMetadataImpl.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualRowMetadata

@dynamic username, comment, reference;

+(FactualRowMetadata*) metadata: (NSString *) username {
    return [[FactualRowMetadataImpl alloc] initWithUserName:username];
}
@end

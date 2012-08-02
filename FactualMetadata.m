//
//  FactualMetadata.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/1/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualMetadata.h"
#import "FactualMetadataImpl.h"
#import "FactualUrlUtil.h"
#import "NSString (Escaping).h"

@implementation FactualMetadata

@dynamic username, comment, reference;

+(FactualMetadata*) metadata: (NSString *) username {
    return [[FactualMetadataImpl alloc] initWithUserName:username];
}
@end

//
//  FactualMetadataIimpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/6/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualMetadata.h"

@interface FactualMetadataImpl : FactualMetadata
{
    NSString* username;
    NSString* comment;
    NSString* reference;
}
-(void) generateQueryString:(NSMutableString*)qryString;

-(id) initWithUserName: (NSString *) username;

@end

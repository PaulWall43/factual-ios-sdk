//
//  FactualFacetResponse.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FactualFacetResponse : NSObject
@property (nonatomic,readonly)    NSUInteger totalRows;
@property (nonatomic,readonly)    NSDictionary* data;
@end

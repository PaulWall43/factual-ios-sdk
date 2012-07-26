//
//  Point.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FactualPoint : NSObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

-(id) initWithLatitude:(double) latitude longitude:(double) longitude;
-(NSString*) toJson;
@end

//
//  Resolve.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Resolve : NSObject

@property (nonatomic, retain) NSMutableDictionary* values;

+(Resolve*) resolve;
-(void) generateQueryString:(NSMutableString*)qryString;
-(void) addProperty:(NSString*) prop value:(NSString*) value;
@end

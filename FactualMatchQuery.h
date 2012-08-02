//
//  MatchQuery.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/2/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FactualMatchQuery : NSObject
@property (nonatomic, retain) NSMutableDictionary* values;
@end

@interface FactualMatchQuery(FactualMatchQueryMethods)

+(FactualMatchQuery*) match;

/*! @method 
 @discussion add property and value pair to use in matching to a Factual id
 */
-(void) addProperty:(NSString*) prop value:(NSString*) value;

@end
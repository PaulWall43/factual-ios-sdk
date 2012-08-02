//
//  Resolve.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!@abstract Encapsulates all the parameters supported by the Factual Resolve API
 @discussion
 */
@interface FactualResolve : NSObject

/*! @property 
 @discussion values to use in resolving to a valid entity
 */
@property (nonatomic, retain) NSMutableDictionary* values;
@end

@interface FactualResolve(FactualResolveMethods)

+(FactualResolve*) resolve;

/*! @method 
 @discussion add property and value pair to use in resolve
 */
-(void) addProperty:(NSString*) prop value:(NSString*) value;
@end
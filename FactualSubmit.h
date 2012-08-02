//
//  FactualSubmit.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/1/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FactualSubmit : NSObject
@property (nonatomic, retain) NSMutableDictionary* values;
@end

@interface FactualSubmit(FactualSubmitMethods)
+(FactualSubmit*) submit;

/*! @property 
 @discussion value and key pair to request for submission
 */
-(void) addProperty:(NSString*) prop value:(NSString*) value;
/*! @property 
 @discussion value and key pair to request for removal in this submit
 */
-(void) removeValue:(NSString*) prop;
@end

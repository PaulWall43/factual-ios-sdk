//
//  Geopulse.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/*!@abstract Encapsulates all the parameters supported by the Factual Geopulse API
 @discussion
 
 A coordinate location is required.
 */
@interface FactualGeopulse : NSObject

/*! @property 
 @discussion fields to select out of the results 
 */
@property (nonatomic, retain) NSMutableArray* selectTerms;

/*! @property 
 @discussion the geographic point at which this geopulse request is executed 
 */
@property (nonatomic) CLLocationCoordinate2D point;
@end

@interface FactualGeopulse(FactualGeopulseMethods)

+(FactualGeopulse*) geopulse:(CLLocationCoordinate2D) location;

/*! @method 
 @discussion add a field to select
 */
-(void) addSelectTerm:(NSString*) selectTerm;
@end
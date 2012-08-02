//
//  FactualSubmitImpl.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/1/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualSubmit.h"

@interface FactualSubmitImpl : FactualSubmit
{
    NSMutableDictionary* values;
}
-(void) generateQueryString:(NSMutableString*)qryString;
-(id) init;
@end

//
//  FactualResolveResult.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualQueryResultImpl.h"

@interface FactualResolveResult : FactualQueryResultImpl
-(bool) isResolved;
-(FactualRow*) getResolved;
+(FactualResolveResult *) resolveResultFromPlacesJSON:(NSDictionary *)jsonResponse;
@end

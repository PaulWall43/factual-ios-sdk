//
//  Geocode.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/27/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "Geocode.h"
#import "FactualPoint.h"
#import "UrlUtil.h"

@implementation Geocode
    @synthesize point=_point;

-(id) initWithPoint:(FactualPoint*) point {
    if (self = [super init]) {
        self.point = point;
    }
    return self;
}

-(void) generateQueryString:(NSMutableString*)qryString {
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
    if (self.point) {
        [array addObject:[NSString stringWithFormat:@"geo=%@", [self.point toJson]]];
    }
    [UrlUtil appendParams:array to:qryString];
}  
@end

//
//  FactualResolveResult.m
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 7/31/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "FactualResolveResult.h"
#import "FactualQueryResultImpl.h"

@implementation FactualResolveResult

-(bool) isResolved {
    if ([_rows count] > 0) {
        FactualRow* row = (FactualRow*) [_rows objectAtIndex:0];
        if ([[NSNumber numberWithInt:1] isEqual:[row valueForName:@"resolved"]]) {
            return true;
        }
    }
    return false;
}

-(FactualRow*) getResolved {
    if ([self isResolved]) {
        return (FactualRow*) [_rows objectAtIndex:0];
    } else {
        return nil;
    }
}

+(FactualResolveResult *) resolveResultFromPlacesJSON:(NSDictionary *)jsonResponse {
	NSArray *rows = [jsonResponse objectForKey:@"data"];
    // bail if no data ... 
    if (rows == nil) {
#ifdef TARGET_IPHONE_SIMULATOR        
        NSLog(@"fields or row data missing!");
#endif    
        return nil;
    }
    
	NSNumber *theTotalRows = [jsonResponse objectForKey:@"total_row_count"];
    
	long totalRows = 0L;
    if (!theTotalRows) {
#ifdef TARGET_IPHONE_SIMULATOR        
		NSLog(@"total_rows object missing");
#endif    
	}
    else {
        totalRows = [theTotalRows unsignedIntValue];
    }
    // ok ready to go... alloc response object and return ... 
    FactualResolveResult* objectOut 
    = [[FactualResolveResult alloc]initWithOnlyRows:rows 
                                          totalRows:totalRows 
                                            tableId:nil ];
    
    return objectOut;
}
@end

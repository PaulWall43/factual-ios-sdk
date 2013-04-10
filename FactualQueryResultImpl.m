//
//  FactualQueryResultImpl.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualQueryResultImpl.h"
#import "FactualRowImpl.h"

@implementation FactualQueryResultImpl
@synthesize rows=_rows,totalRows=_totalRows,tableId=_tableId,deprecated=_deprecated;

+(FactualQueryResult *) queryResultFromJSON:(NSDictionary *)jsonResponse deprecated:(BOOL)deprecated {
    
	id rows = [jsonResponse objectForKey:@"data"];
    
    NSMutableArray *rowData = [[NSMutableArray alloc] init];
    if([rows isKindOfClass:[NSArray class]]) {
        NSArray* rowArray = (NSArray*) rows;
        for (NSDictionary* rowValues in rowArray) {
            NSString* rowId = @"undefined";
            NSString* factualId = [rowValues valueForKey:@"factual_id"];;
            if (factualId != nil) { 
                rowId = factualId;
            }
            NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
            [result setValue: rowId forKey:@"row_id"];
            [result setValue: rowValues forKey:@"values"];
            [rowData addObject:result];
        }
    } else if ([rows isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *) rows;
        for (NSString* key in dict) {
            NSString* facetName = key;
            NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
            [result setValue: facetName forKey:@"facet_name"];
            [result setValue: [dict objectForKey:key] forKey:@"values"];
            [rowData addObject:result];
        }
    }
    
    // bail if no data ... 
    if (rows == nil) {
#ifdef TARGET_IPHONE_SIMULATOR        
        NSLog(@"fields or row data missing!");
#endif    
        return nil;
    }
    
	NSNumber *theTotalRows = [jsonResponse objectForKey:@"total_row_count"];
    
	long totalRows = -1L;
    if (theTotalRows) {
        totalRows = [theTotalRows unsignedIntValue];
    }
    // ok ready to go... alloc response object and return ... 
    FactualQueryResultImpl* objectOut 
    = [[FactualQueryResultImpl alloc]initWithOnlyRows:rowData 
                                            totalRows:totalRows 
                                              tableId:nil
                                           deprecated:deprecated];
    
    return objectOut;
}

-(id) initWithOnlyRows:(NSArray*) theRows 
             totalRows:(NSUInteger) theTotalRows
               tableId:(NSString*) tableId
            deprecated:(BOOL) deprecated {
    if (self = [super init]) {
        
        _tableId = tableId;
        // setup total rows 
        _totalRows = theTotalRows;
        
        if ([theRows count] != 0) { 
            // ok, now populate row data ...  
            _rows = [NSMutableArray arrayWithCapacity:[_rows count]];
            for (NSDictionary* rowData in theRows) {
                NSString* rowId = [rowData valueForKey:@"row_id"];
                NSString* facetName = [rowData valueForKey:@"facet_name"];
                NSDictionary* values = [rowData valueForKey:@"values"];
                FactualRowImpl* rowObject =[[FactualRowImpl alloc]initWithJSONObject:values withRowId:rowId withFacetName:facetName];
                
                [_rows addObject: rowObject];
            }
        }
        _deprecated = deprecated;
        
    }
    return self;
}

// get the row at the given index 
-(FactualRow*) rowAtIndex:(NSInteger) index {
    if (index < [_rows count]) {
        return [_rows objectAtIndex:index];
    }
    return nil;
}


-(NSInteger) rowCount {
    return [_rows count];
}

-(NSInteger) columnCount {
    return [_columns count];
}

-(NSString*) description {
    return [NSString 
            stringWithFormat:@"FactualQueryResult rowCount:%d \
            columnCount:%d totalRows:%d",
            [self rowCount],[self columnCount],[self totalRows]];
}

@end
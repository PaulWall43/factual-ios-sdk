//
//  FactualQueryResultImpl.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualQueryResultImpl.h"
#import "FactualRowImpl.h"

@implementation FactualQueryResultImpl
@synthesize rows=_rows,totalRows=_totalRows,tableId=_tableId;


+(FactualQueryResult *) queryResultFromJSON:(NSDictionary *)jsonResponse
                                    tableId:(NSString*) tableId {
  // ok allocate the  containers upfront ... 
  // ok now parse json data structure ... 
  NSArray *columns = [jsonResponse objectForKey:@"fields"];
	NSArray *rows = [jsonResponse objectForKey:@"data"];
  // bail if no data ... 
  if (columns == nil && rows == nil) {
    NSLog(@"fields or row data missing!");
    return nil;
  }
  // otherwise validate rows have proper number of cells ... 
  for (NSArray* row in rows) {
     if ([row count] != [columns count]) {
       NSLog(@"Invalid Cell Count in Row!");
       return nil;
     }
  }
  // otherwise things look pretty good up to this point ... 
  // extract total rows if available ...
	NSNumber *theTotalRows = [jsonResponse objectForKey:@"total_rows"];
	long totalRows = 0L;
  if (!theTotalRows) {
		NSLog(@"total_rows object missing");
	}
  else {
    totalRows = [theTotalRows unsignedIntValue];
  }
  
  // ok ready to go... alloc response object and return ... 
  FactualQueryResultImpl* objectOut 
    = [[[FactualQueryResultImpl alloc]initWithColumns:columns 
                                                 rows:rows 
                                            totalRows:totalRows 
                                              tableId:tableId ]autorelease];

  return objectOut;
}

+(FactualQueryResult *) queryResultFromPlacesJSON:(NSDictionary *)jsonResponse {
	NSArray *rows = [jsonResponse objectForKey:@"data"];
    // bail if no data ... 
  if (rows == nil) {
    NSLog(@"fields or row data missing!");
    return nil;
  }

	NSNumber *theTotalRows = [jsonResponse objectForKey:@"total_row_count"];
  
	long totalRows = 0L;
  if (!theTotalRows) {
		NSLog(@"total_rows object missing");
	}
  else {
    totalRows = [theTotalRows unsignedIntValue];
  }
  
    // ok ready to go... alloc response object and return ... 
  FactualQueryResultImpl* objectOut 
  = [[[FactualQueryResultImpl alloc]initWithOnlyRows:rows 
                                          totalRows:totalRows 
                                            tableId:nil ]autorelease];
  
  return objectOut;
}


-(id) initWithColumns:(NSArray*) theColumns 
                 rows:(NSArray*) theRows 
            totalRows:(NSUInteger) theTotalRows
              tableId:(NSString*) tableId {
  if (self = [super init]) {
    _tableId = [tableId retain];
    // setup total rows 
    _totalRows = theTotalRows;
    // setup columns array 
    _columns = [[NSMutableArray arrayWithCapacity:([theColumns count]-1)] retain];
    // and dictionary 
    _columnToIndex = [[NSMutableDictionary dictionaryWithCapacity: [theColumns count]-1]retain];
    
    // populate both ... 
    for (NSUInteger i=1;i<[theColumns count];++i) {
      [_columnToIndex setValue: [NSNumber numberWithUnsignedInt:(i-1)] forKey:[theColumns objectAtIndex:i]];
      [((NSMutableArray*)_columns) addObject: [theColumns objectAtIndex:i]];
    }    
    _rows = [[NSMutableArray arrayWithCapacity:[_rows count]]retain];
    for (NSArray* rowData in theRows) {
      [_rows addObject: [[FactualRowImpl alloc]initWithJSONArray:rowData optionalRowId:nil columnNames:_columns columnIndex:_columnToIndex copyValues:NO]];
    }
    

  }
  return self;
}

-(id) initWithOnlyRows:(NSArray*) theRows 
            totalRows:(NSUInteger) theTotalRows
              tableId:(NSString*) tableId {
  if (self = [super init]) {
    
    _tableId = [tableId retain];
      // setup total rows 
    _totalRows = theTotalRows;
    
    if ([theRows count] != 0) { 
      // ok, now populate row data ...  
      _rows = [[NSMutableArray arrayWithCapacity:[_rows count]]retain];
      for (NSDictionary* rowData in theRows) {
        
        FactualRowImpl* rowObject =[[[FactualRowImpl alloc]initWithJSONObject:rowData] autorelease];
        
        [_rows addObject: rowObject];
      }
    }
    
    
  }
  return self;
}


-(void) dealloc {
  [_columnToIndex release];
  [_rows release];
  [_columns release];
  [_tableId release];
  [super dealloc];
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
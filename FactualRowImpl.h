//
//  FactualTableRowImpl.h
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FactualRow.h"


@interface FactualRowImpl : FactualRow {
  NSArray*  _cells;
  NSString* _rowId;  
  NSString* _facetName;  
  NSMutableArray*  _columns;
  NSMutableDictionary* _columnIndex;
  NSMutableDictionary* _jsonObject;
  
}

// internal init 
-(id) initWithJSONArray:(NSArray*) cellValues 
          optionalRowId:(NSString*) rowId
      optionalFacetName:(NSString*) facetName
            columnNames:(NSArray*) columnNames
            columnIndex:(NSDictionary*) columnIndex
             copyValues: (boolean_t) copyValues;

-(id) initWithJSONObject:(NSDictionary*) cellValues withRowId: (NSString*) rowId withFacetName: (NSString*) facetName;

-(NSString*) stringValueForName:(NSString*) fieldName;

-(NSString*) stringValueAtIndex:(NSInteger) fieldIndex;
  
@end

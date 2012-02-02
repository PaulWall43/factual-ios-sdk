//
//  FactualRowImpl.m
//  FactualCore
//
//  Created by Ahad Rana on 12/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FactualRowImpl.h"
#import "CJSONDataSerializer.h"


@implementation FactualRowImpl
@synthesize rowId=_rowId;
 

// internal init 
-(id) initWithJSONArray:(NSArray*) cellValues
            optionalRowId:(NSString*) optionalRowId
            columnNames:(NSArray*) columnNames
            columnIndex:(NSDictionary*) columnIndex copyValues:(boolean_t) copyValues {
  if (self = [super init]) {
    // hold on to a reference to the underlying column name and index dictionaries 
    _columns = [columnNames retain];
    _columnIndex = [columnIndex retain];
    
    //if optional row is not null, then assign row id directly 
    if (optionalRowId != nil) {
      if (copyValues) {
        _rowId = [optionalRowId copy];
      }
      else {
        _rowId = [optionalRowId retain];
      }
    }
    // see if capacity is at least at min required
    NSMutableArray* cells = nil;
    if ([cellValues count] > 1) {
      // allocate for remaining cells   
      cells = [NSMutableArray arrayWithCapacity: ([cellValues count] -1) ];
      int index=0;
      for (NSObject* cellValue in cellValues) {
        if (index++ == 0 && optionalRowId == nil) {
          if (copyValues) {
            _rowId = [cellValue copy];
          }
          else {
            _rowId = [cellValue retain];
          }
          
        }
        else {
          if (copyValues) {
            if ([cellValue isKindOfClass:[NSString class]]) {
              [cells addObject:[[NSString alloc ]initWithString:(NSString *)cellValue]];
            }
            else {
              [cells addObject:[cellValue copy]];
            }
            
          }
          else {
            [cells addObject:cellValue];
          }
          
        }
      }
    }
    else {
      cells = [NSArray array];
      _rowId = [[cellValues objectAtIndex:0]retain];
    }
    _cells = [cells retain];
  }
  return self;
}


-(id) initWithJSONObject:(NSDictionary*) cellValues { 
  

  if (self = [super init]) {
      // hold on to a reference to the underlying column name and index dictionaries 
      //_columns = [columnNames retain];
      //_columnIndex = [columnIndex retain];
    
    _jsonObject = [cellValues retain];
    
    // see if capacity is at least at min required
    // locate factual id 
    NSString* factualId = [cellValues valueForKey:@"factual_id"];
    if (factualId != nil) { 
      _rowId = [factualId retain];
    }
    else { 
      _rowId = @"undefined";
    }
  }
  return self;
}



-(void) dealloc {
  [_cells release];
  [_rowId release];
  [_columns release];
  [_columnIndex release];
  [_jsonObject release];
  [super dealloc];
}


// get row id ... 
-(NSString*) rowId {
  return _rowId;
}

// get value by column name 
-(id) valueForName:(NSString*) fieldName {
  if (_jsonObject != nil) { 
    return [_jsonObject objectForKey:fieldName];
  }
  else { 
    NSNumber* number = [_columnIndex objectForKey:fieldName];
    if (number != nil) {
      return [_cells objectAtIndex:[number unsignedIntValue]];
    }
    return nil;
  }
}

// get fact by column name as string (possibly coerced) 
-(NSString*) stringValueForName:(NSString*) fieldName {
  if (_jsonObject != nil) { 
    NSObject* object = [_jsonObject objectForKey:fieldName];
    if (object != nil) { 
      if ([object isKindOfClass:[NSNull class]])
        {
        return @"";
        }
      else if ([object isKindOfClass:[NSNumber class]])
        {
        return [((NSNumber*)object) stringValue];
        }
      else if ([object isKindOfClass:[NSString class]])
        {
        return (NSString*)object;
        }
      else if ([object isKindOfClass:[NSArray class]])
        { 
          CJSONDataSerializer* serializer = [CJSONDataSerializer serializer];
          NSData* data = [serializer serializeArray:(NSArray*)object];
          return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
      else if ([object isKindOfClass:[NSDictionary class]])
        {
        CJSONDataSerializer* serializer = [CJSONDataSerializer serializer];
        NSData* data = [serializer serializeDictionary:(NSDictionary*)object];
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
      else
        {
  #ifdef TARGET_IPHONE_SIMULATOR      
        NSLog(@"Cannot serialize data of type '%@'", NSStringFromClass([object class]));
  #endif
        }
    }
    return nil;
  }
  else { 
    NSNumber* number = [_columnIndex objectForKey:fieldName];
    if (number != nil) {
      return [self stringValueAtIndex:[number unsignedIntValue]];
    }
    return nil;
  }
}


// get fact by column index
-(id) valueAtIndex:(NSInteger) fieldIndex {
  if (fieldIndex < [_columns count]) {
    return [_cells objectAtIndex:fieldIndex];
  }
  return nil;
}


-(void) setValueForName:(NSString*) fieldName value:(id) value {
  if (_jsonObject != nil) { 
    [_jsonObject setObject:value forKey:fieldName];
  }
  else { 
    NSNumber* number = [_columnIndex objectForKey:fieldName];
    if (number != nil) {
      [((NSMutableArray*)_cells) replaceObjectAtIndex:[number unsignedIntValue]  withObject:value];
    }
    else {
  #ifdef TARGET_IPHONE_SIMULATOR      
      NSLog(@"No valid field found for name:%@",fieldName);
  #endif
    }
  }
}

/*
-(void) setValueAtIndex:(NSUInteger) index value:(id) value {
  if (index < [_columns count]) {
    [((NSMutableArray*)_cells) replaceObjectAtIndex:index  withObject:value];
  }
  else {
#ifdef TARGET_IPHONE_SIMULATOR      
    NSLog(@"Invalid index specified in setValueAtIndex:(%d)",index);
#endif
  }
}
 */


// get fact by column index as string (possibly coerced) 
-(NSString*) stringValueAtIndex:(NSInteger) fieldIndex {
  NSObject* object = [self valueAtIndex:fieldIndex];
  if ([object isKindOfClass:[NSNull class]])
	{
    return @"";
	}
  else if ([object isKindOfClass:[NSNumber class]])
	{
    return [((NSNumber*)object) stringValue];
	}
  else if ([object isKindOfClass:[NSString class]])
	{
    return (NSString*)object;
	}
  else if ([object isKindOfClass:[NSArray class]])
	{ 
    CJSONDataSerializer* serializer = [CJSONDataSerializer serializer];
    NSData* data = [serializer serializeArray:(NSArray*)object];
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}
  else if ([object isKindOfClass:[NSDictionary class]])
	{
    CJSONDataSerializer* serializer = [CJSONDataSerializer serializer];
    NSData* data = [serializer serializeDictionary:(NSDictionary*)object];
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}
  else
	{
#ifdef TARGET_IPHONE_SIMULATOR      
    NSLog(@"Cannot serialize data of type '%@'", NSStringFromClass([object class]));
#endif
	}
  return nil;
}

-(NSInteger)   fieldIndexForName:(NSString*) fieldName {
  NSNumber* indexValue = [_columnIndex objectForKey:fieldName];
  if (indexValue == nil) {
    return -1;
  }
  return [indexValue intValue];
}

-(NSString*)   fieldNameAtIndex:(NSUInteger) index {
  return [_columns objectAtIndex:index];
}

-(id) copyWithZone:(NSZone *)zone {
  return [[FactualRowImpl allocWithZone:zone] initWithJSONArray:_cells optionalRowId:_rowId columnNames:_columns columnIndex:_columnIndex copyValues:YES]; 
}

-(NSInteger) valueCount {
  return [_cells count];
}

-(NSString*) description {
  NSMutableString* mutableString = [NSMutableString stringWithCapacity:([self valueCount] * 100)];
  
  if (_jsonObject != nil) { 
    [mutableString  appendString:[NSString stringWithFormat:@"FactualRow rowId:%@ valueCount:%d\n",
                                  [self rowId],[_jsonObject count]]];
    for (NSString* columnName in _jsonObject) {
      [mutableString appendString:[NSString stringWithFormat:@"\t Cell:%@ Value:%@\n",
                                   columnName,
                                   [_jsonObject objectForKey:columnName]]];
      
    }
  }
  else { 
    [mutableString  appendString:[NSString stringWithFormat:@"FactualRow rowId:%@ valueCount:%d\n",
            [self rowId],[self valueCount]]];
    
    int valueIndex=0;
    for (;valueIndex<[self valueCount];++valueIndex) {
      [mutableString appendString:[NSString stringWithFormat:@"\t Cell:%@ Value:%@\n",
                                   [self fieldNameAtIndex:valueIndex],
                                   [self stringValueAtIndex:valueIndex]]];
      
    }
  }
  return mutableString;
}

-(NSDictionary *) namesAndValues {
  if (_jsonObject != nil) { 
    return _jsonObject;
  }
  else { 
    return [NSDictionary dictionaryWithObjects:_cells forKeys:_columns]; 
  }
}

@end

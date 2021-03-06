//
//  FactualRowImpl.m
//  FactualCore
//
//  Created by Ahad Rana on 12/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FactualRowImpl.h"

#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"


@implementation FactualRowImpl
@synthesize rowId=_rowId;
@synthesize facetName=_facetName;

-(id) initWithJSONObject:(NSMutableDictionary*) cellValues withRowId: (NSString*) rowId withFacetName: (NSString*) facetName { 
  

  if (self = [super init]) {
      // hold on to a reference to the underlying column name and index dictionaries 
      //_columns = [columnNames retain];
      //_columnIndex = [columnIndex retain];
    
    _jsonObject = cellValues;
    _rowId = rowId;
    _facetName = facetName;
  }
  return self;
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
          NSError *theError = nil;
          CJSONSerializer* serializer = [CJSONSerializer serializer];
          NSData* data = [serializer serializeArray:(NSArray*)object error:&theError];
          return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
      else if ([object isKindOfClass:[NSDictionary class]])
      {
          NSError *theError = nil;
        CJSONSerializer* serializer = [CJSONSerializer serializer];
        NSData* data = [serializer serializeDictionary:(NSDictionary*)object error:&theError];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
        
        NSError *theError = nil;
    CJSONSerializer* serializer = [CJSONSerializer serializer];
        NSData* data = [serializer serializeArray:(NSArray*)object  error:&theError];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
  else if ([object isKindOfClass:[NSDictionary class]])
  {
      NSError *theError = nil;
    CJSONSerializer* serializer = [CJSONSerializer serializer];
    NSData* data = [serializer serializeDictionary:(NSDictionary*)object error:&theError];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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

-(NSInteger) valueCount {
  return [_cells count];
}

-(NSString*) description {
  NSMutableString* mutableString = [NSMutableString stringWithCapacity:([self valueCount] * 100)];
  
  if (_jsonObject != nil) { 
    [mutableString  appendString:[NSString stringWithFormat:@"FactualRow rowId:%@ facetName:%@ valueCount:%d\n",
                                  [self rowId],[self facetName],[_jsonObject count]]];
    for (NSString* columnName in _jsonObject) {
      [mutableString appendString:[NSString stringWithFormat:@"\t Cell:%@ Value:%@\n",
                                   columnName,
                                   [_jsonObject objectForKey:columnName]]];
      
    }
  }
  else { 
    [mutableString  appendString:[NSString stringWithFormat:@"FactualRow rowId:%@ facetName:%@ valueCount:%d\n",
            [self rowId],[self facetName],[self valueCount]]];
    
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

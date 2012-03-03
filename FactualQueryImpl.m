//
//  FactualQueryImpl.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualQuery.h"
#import "FactualQueryImpl.h"
#import "CJSONSerializer.h"
#import "NSString (Escaping).h"

/* -----------------------------------------------------------------------------
 Predicate Strings
 ------------------------------------------------------------------------------*/


static NSString* simplePredicateStrings[]  = {
  @"$eq",
  @"$neq",
  @"$gt",
  @"$lt",
  @"$gte",
  @"$lte",
  @"$bw"
};

static NSString* compoundValuePredicateStrings[] = {
  @"$in"
};

static NSString* compoundFilterPredicateStrings[] = {
  @"$and",
  @"$or"
};

/* -----------------------------------------------------------------------------
 FactualSimpleValueFilterPredicate IMPLEMENTATION
 ------------------------------------------------------------------------------*/
@implementation FactualSimpleValueFilterPredicate 

@synthesize type=_type;
@synthesize value=_value;
@synthesize fieldName=_fieldName;



-(id) initWithPredicateType:(SimplePredicateType) type fieldName:(NSString*) fieldName value:(id)value {
  if (self = [super init]) {
    self.fieldName = fieldName;
    _type = type;
    self.value = value;
  }
  return self;
}

-(void) dealloc {
  [_value release];
  [_fieldName release];
  [super dealloc];
}

-(void) appendToDictionary:(NSMutableDictionary*) dictionary {
  NSDictionary* tuple  = [NSDictionary dictionaryWithObject:_value forKey:simplePredicateStrings[_type]]; 
  [dictionary setObject:tuple forKey:self.fieldName];
}


@end

/* -----------------------------------------------------------------------------
 FactualCompoundRowFilterPredicate IMPLEMENTATION
 ------------------------------------------------------------------------------*/

@implementation FactualCompoundRowFilterPredicate

@synthesize type=_type;
@synthesize filterValues=_filters;


-(id) initWithPredicateType:(CompoundFilterPredicateType) type  filterValues:(NSArray*) filterValues {
  
  if (self = [super init]) {
    _type = type;
    _filters = (NSMutableArray*)[filterValues retain];
  }
  return self;
}

-(void) dealloc {
  [_filters release];
  [super dealloc];
}

-(void) appendToDictionary:(NSMutableDictionary*) dictionary {
  NSMutableArray* array  = [NSMutableArray arrayWithCapacity:[_filters count]];
  for (FactualRowFilter* filter in _filters) {
    NSMutableDictionary* nestedDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [filter  appendToDictionary:nestedDictionary];
    [array addObject:nestedDictionary];
  }
  [dictionary setObject:array forKey:compoundFilterPredicateStrings[_type]];
}


@end

/* -----------------------------------------------------------------------------
 FactualCompoundValueFilterPredicate IMPLEMENTATION
 ------------------------------------------------------------------------------*/

@implementation FactualCompoundValueFilterPredicate

@synthesize type=_type;
@synthesize values=_values;
@synthesize fieldName=_fieldName;

-(id) initWithPredicateType:(CompoundValuePredicateType)type fieldName:(NSString*) fieldName values:(NSArray *)values {
  if (self = [super init]) {
    self.fieldName = fieldName;
    _type = type;
    self.values = values;
  }
  return self;
}

-(void) dealloc {
  [_fieldName release];
  [_values release];
  [super dealloc];
}

-(void) appendToDictionary:(NSMutableDictionary*) dictionary {
  NSMutableDictionary* nestedDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
  [nestedDictionary setObject:_values forKey:compoundValuePredicateStrings[_type]];
  [dictionary setObject:nestedDictionary forKey:self.fieldName];
}

@end

/* -----------------------------------------------------------------------------
 FactualRowFilter IMPLEMENTATION
 ------------------------------------------------------------------------------*/
@implementation FactualRowFilter

+(FactualRowFilter*) fieldName:(NSString*)  fieldName equalTo:(id) value {
  return [[[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Eq fieldName:fieldName value:value]autorelease];
}

+(FactualRowFilter*) fieldName:(NSString*)  fieldName notEqualTo:(id) value {
  return [[[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:NEq fieldName:fieldName value:value]autorelease];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName greaterThan:(id) value {
  return [[[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Gt fieldName:fieldName value:value]autorelease];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName lessThan:(id) value {
  return [[[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Lt fieldName:fieldName value:value]autorelease];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName greaterThanOrEqualTo:(id) value {
  return [[[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:GtEq fieldName:fieldName value:value]autorelease];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName lessThanOrEqualTo:(id) value {
  return [[[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:LtEq fieldName:fieldName value:value]autorelease];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName In:(id) value,... {
  NSMutableArray* values = [NSMutableArray array];
  
  va_list ap;
  va_start(ap, value);
  
  while (value) {
    [values addObject:value];
    value = va_arg(ap, id);
  }
  va_end(ap);
  
  return [[[FactualCompoundValueFilterPredicate alloc] initWithPredicateType:In fieldName:fieldName values:values]autorelease];
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName InArray:(NSArray*) values {
  return [[[FactualCompoundValueFilterPredicate alloc] initWithPredicateType:In fieldName:fieldName values:values]autorelease];
}


+(FactualRowFilter*) fieldName:(NSString*) fieldName beginsWith:(NSString*) value {
  return [[[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:BeginsWith fieldName:fieldName value:value]autorelease];
}

+(FactualRowFilter*) orFilter:(FactualRowFilter*)rowFilter,... {

  NSMutableArray* rowFilters = [NSMutableArray arrayWithCapacity:0];
  
  va_list ap;
  va_start(ap, rowFilter);
  
  while (rowFilter) {
    [rowFilters addObject:rowFilter];
    rowFilter = va_arg(ap, FactualRowFilter*);
  }
  va_end(ap);
  
  return [[[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:Or filterValues:rowFilters] autorelease];
}

+(FactualRowFilter*) orFilterWithArray:(NSArray*)rowFilters {
  
  for (NSObject* object in  rowFilters) {
    if (object == nil || ![object isKindOfClass:[FactualRowFilter class]]) {
      @throw [NSException exceptionWithName:@"Invalid Arguement" reason:@"Invalid filter type in array!" userInfo:nil];
    }
  }  
  return [[[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:Or filterValues:rowFilters] autorelease];
}

+(FactualRowFilter*) andFilterWithArray:(NSArray*)rowFilters {
  
  for (NSObject* object in  rowFilters) {
    if (object == nil || ![object isKindOfClass:[FactualRowFilter class]]) {
      @throw [NSException exceptionWithName:@"Invalid Arguement" reason:@"Invalid filter type in array!" userInfo:nil];
    }
  }  
  return [[[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:And filterValues:rowFilters] autorelease];
}


+(FactualRowFilter*) andFilter:(FactualRowFilter*)rowFilter,... {
  NSMutableArray* rowFilters = [NSMutableArray arrayWithCapacity:0];
  
  va_list ap;
  va_start(ap, rowFilter);
  
  while (rowFilter) {
    [rowFilters addObject:rowFilter];
    rowFilter = va_arg(ap, FactualRowFilter*);
  }
  va_end(ap);
  
  return [[[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:And filterValues:rowFilters] autorelease];
}


@end


/* -----------------------------------------------------------------------------
 FactualQuery IMPLEMENTATION
 ------------------------------------------------------------------------------*/

@implementation FactualQuery

@dynamic rowId,offset,limit,primarySortCriteria,secondarySortCriteria,rowFilters,fullTextTerms;

+(FactualQuery*) query {
  return [[[FactualQueryImplementation alloc] init] autorelease];
}

@end

/* -----------------------------------------------------------------------------
 FactualQueryImplementation IMPLEMENTATION
------------------------------------------------------------------------------*/
@implementation FactualQueryImplementation

@synthesize rowId=_rowId;
@synthesize offset=_offset;
@synthesize limit=_limit;
@synthesize primarySortCriteria=_primarySortCriteria;
@synthesize secondarySortCriteria=_secondarySortCriteria;
@synthesize fullTextTerms=_textTerms;
@synthesize rowFilters=_rowFilters;
@synthesize geoFilter=_geoFilter;



-(id) init {
  if (self = [super init]) {
    _rowFilters = [[NSMutableArray arrayWithCapacity:0] retain];
    _textTerms  = [[NSMutableArray arrayWithCapacity:0] retain];
    _offset = 0;
    _limit  = 0;
  }
  return self;
}

-(void) dealloc {
  
  [_rowId release];
  [_primarySortCriteria release];
  [_secondarySortCriteria release];
  [_rowFilters release];
  [_textTerms release];
  [_geoFilter release];
  
  [super dealloc];
}

-(void) addFullTextQueryTerm:(NSString*) textTerm {
  if ([textTerm length] != 0) {
    [_textTerms addObject:textTerm];    
  }
}

-(void) addFullTextQueryTerms:(NSString*) textTerm,... {
  va_list args;
  va_start(args, textTerm);
  
  for (NSString *arg = textTerm; arg != nil; arg = va_arg(args, NSString*)) {
    [_textTerms addObject:arg];
  }
  va_end(args);
}

-(void) addFullTextQueryTermsFromArray:(NSArray*) termArray {
  for (NSString* term in termArray) {
    if ([term length] >0) {
      [_textTerms addObject:term];
    }
  }
}

-(void) clearFullTextFilter {
  [_textTerms removeAllObjects];
}

-(void) setGeoFilter:(CLLocationCoordinate2D)location radiusInMeters:(double)radius {
  self.geoFilter = [FactualGeoFilter createDistanceFromPointGeoFilter:location distance:radius];
}

-(void) clearGeoFilter {
  self.geoFilter = nil;
}

-(void) addRowFilter:(FactualRowFilter*) rowFilter {
  [_rowFilters addObject:rowFilter];
}

-(void) clearRowFilters {
  [_rowFilters removeAllObjects];
}

-(void) generateQueryString:(NSMutableString*)qryString {
  NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:10]autorelease];
  
  [array addObject:@"include_count=t"];
  
  //[qryString appendString:@"include_count=t&"];
  
  if (self.rowId != nil) {
    [array addObject:[NSString stringWithFormat:@"subjectKey=%@",
                      [self.rowId stringWithPercentEscape]]];
    /*
		[qryString appendFormat:@"subjectKey=%@&",
		 [self.rowId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     */
  }
  else {
    if (self.limit > 0) {
      [array addObject:[NSString stringWithFormat:@"limit=%d", self.limit]];
      //[qryString appendFormat:@"limit=%d&", self.limit];
    }
    
    if (self.offset > 0) {
      [array addObject:[NSString stringWithFormat:@"offset=%d", self.offset]];
      //[qryString appendFormat:@"offset=%d&", self.offset];
    }
    
    if (self.primarySortCriteria != nil || self.secondarySortCriteria != nil) {
      NSMutableString* sortStr = [[[NSMutableString alloc]init ]autorelease];
      [sortStr appendString:@"sort="];
      if (self.primarySortCriteria != nil) {
        [self.primarySortCriteria generateQueryString:sortStr];
        if (self.secondarySortCriteria != nil) {
          [sortStr appendString:@","];
        }
      }
      if (self.secondarySortCriteria != nil) {
        [self.secondarySortCriteria generateQueryString:sortStr];
      }
      [array addObject:sortStr];
      //[qryString appendString:sortStr];
      //[qryString appendString:@"&"];
    }
    
            
    if ([self.rowFilters count] != 0) {
      NSMutableDictionary* filterDictionary = [[[NSMutableDictionary alloc] initWithCapacity:0]autorelease];
      
      for (FactualRowFilter* filter in self.rowFilters) {
        [filter appendToDictionary:filterDictionary];
      }
      NSMutableString* filterStr = [[[NSMutableString alloc]init ]autorelease];
      [filterStr appendFormat:@"filters=%@",
       [[[CJSONSerializer serializer] serializeDictionary:filterDictionary]
        stringWithPercentEscape]];
      
      [array addObject:filterStr];
      //[qryString appendString:filterStr];
      //[qryString appendString:@"&"];
    }
    
    if ([self.fullTextTerms count] != 0) {
      NSMutableString* qString = [[[NSMutableString alloc] init] autorelease];
      int termNumber=0;
      for (NSString* term in self.fullTextTerms) {
        if(termNumber++ != 0) 
          [qString appendString:@","];
        [qString appendString:term];
      }
      
      [array addObject:[NSString stringWithFormat:@"q=%@",[qString stringWithPercentEscape]]];
      
      //[qryString appendFormat:@"q=%@&",[qString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (self.geoFilter != nil) {
      NSMutableDictionary* geoDictionary = [[[NSMutableDictionary alloc] initWithCapacity:0]autorelease];
      [self.geoFilter appendToDictionary:geoDictionary];

      [array addObject:[NSString stringWithFormat:@"geo=%@",
                      [[[CJSONSerializer serializer] serializeDictionary:geoDictionary] stringWithPercentEscape]]];
      
      /*[qryString appendFormat:@"geo=%@",
       [[[[CJSONSerializer serializer] serializeDictionary:geoDictionary] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] ];    
       */
      
    }
  }
  
  int paramCount=0;
  for (NSString* str in array) {
    if (paramCount++ != 0) 
      [qryString appendString:@"&"];
    [qryString appendString:str];
  }
}


@end

/* -----------------------------------------------------------------------------
 FactualSortCriteria IMPLEMENTATION
 ------------------------------------------------------------------------------*/
@implementation FactualSortCriteria 

@synthesize fieldName=_fieldName;
@synthesize sortOrder=_sortOrder;

-(id) initWithFieldName:(NSString*) fieldName sortOrder:(FactualSortOrder) sortOrder {
  if (self = [super init]) {
    self.fieldName = fieldName;
    self.sortOrder = sortOrder;
  }
  return self;
}

-(void) dealloc {
  [_fieldName release];
  [super dealloc];
}

@end


/* -----------------------------------------------------------------------------
FactualSortCriteria(PrivateMethods) IMPLEMENTATION
------------------------------------------------------------------------------*/
    
@implementation FactualSortCriteria(PrivateMethods)

-(void) generateQueryString:(NSMutableString*) intoString {
  [intoString appendFormat:@"%@:%@",
   [self.fieldName stringWithPercentEscape],
   (self.sortOrder == FactualSortOrder_Ascending) ? @"asc":@"desc"];
}
  

@end

  
/* -----------------------------------------------------------------------------
 FactualGeoFilter IMPLEMENTATION
------------------------------------------------------------------------------*/


@implementation FactualGeoFilter

+(FactualGeoFilter*) createDistanceFromPointGeoFilter:(CLLocationCoordinate2D) location distance:(double)distance {
  return [[[FactualDistanceFromPointGeoFilter alloc] initWithLocation:location distance:distance]autorelease];
}

@end

/* -----------------------------------------------------------------------------
 FactualDistanceFromPointGeoFilter IMPLEMENTATION
------------------------------------------------------------------------------*/

@implementation FactualDistanceFromPointGeoFilter
@synthesize location=_location;
@synthesize radius=_radiusInMeters;

-(id) initWithLocation:(CLLocationCoordinate2D)location distance:(double)distance {
  if (self = [super init]) {
    _location = location;
    _radiusInMeters = distance;
  }
  return self;
}

-(void) appendToDictionary:(NSMutableDictionary*) dictionary {

  NSNumber* latValue = [NSNumber numberWithDouble:_location.latitude];
  NSNumber* longValue = [NSNumber numberWithDouble:_location.longitude];
  NSArray* latLonValue = [NSArray arrayWithObjects:latValue, longValue, nil];
  NSNumber* distanceValue = [NSNumber numberWithDouble:_radiusInMeters];  
  //NSArray* values = [NSArray arrayWithObjects:latLonValue, distanceValue, nil];

  NSDictionary* center = [NSDictionary dictionaryWithObjectsAndKeys:latLonValue,@"$center",distanceValue,@"$meters",nil];
  
  [dictionary setObject:center forKey: @"$circle"];
}

@end





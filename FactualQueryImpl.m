//
//  FactualQueryImpl.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualQuery.h"
#import "FactualQueryImpl.h"
#import "FactualFacetQuery.h"
#import "FactualFacetQueryImpl.h"
#import "CJSONSerializer.h"
#import "NSString (Escaping).h"
#import "FactualUrlUtil.h"

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
    @"$bw",
    @"$search"
    @"$nbw",
    @"$blank",
};

static NSString* compoundValuePredicateStrings[] = {
    @"$in",
    @"$nin",
    @"$bwin",
    @"$nbwin",
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
        _filters = (NSMutableArray*)filterValues;
    }
    return self;
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
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Eq fieldName:fieldName value:value];
}

+(FactualRowFilter*) fieldName:(NSString*)  fieldName notEqualTo:(id) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:NEq fieldName:fieldName value:value];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName greaterThan:(id) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Gt fieldName:fieldName value:value];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName lessThan:(id) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Lt fieldName:fieldName value:value];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName greaterThanOrEqualTo:(id) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:GtEq fieldName:fieldName value:value];  
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName lessThanOrEqualTo:(id) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:LtEq fieldName:fieldName value:value];  
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
    
    return [[FactualCompoundValueFilterPredicate alloc] initWithPredicateType:In fieldName:fieldName values:values];
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName InArray:(NSArray*) values {
    return [[FactualCompoundValueFilterPredicate alloc] initWithPredicateType:In fieldName:fieldName values:values];
}


+(FactualRowFilter*) fieldName:(NSString*) fieldName beginsWith:(NSString*) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:BeginsWith fieldName:fieldName value:value];
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName search:(NSString*) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Search fieldName:fieldName value:value];
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName notBeginsWith:(NSString*) value {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:NotBeginsWith fieldName:fieldName value:value];
}

+(FactualRowFilter*) fieldBlank:(NSString*) fieldName {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Blank fieldName:fieldName value:[NSNumber numberWithBool:TRUE]];
}

+(FactualRowFilter*) fieldNotBlank:(NSString*) fieldName {
    return [[FactualSimpleValueFilterPredicate alloc] initWithPredicateType:Blank fieldName:fieldName value:[NSNumber numberWithBool:FALSE]];
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName notInArray:(NSArray*) values {
    return [[FactualCompoundValueFilterPredicate alloc] initWithPredicateType:NotIn fieldName:fieldName values:values];
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName beginsWithAnyArray:(NSArray*) values {
    return [[FactualCompoundValueFilterPredicate alloc] initWithPredicateType:BeginsWithAny fieldName:fieldName values:values];
}

+(FactualRowFilter*) fieldName:(NSString*) fieldName notBeginsWithAnyArray:(NSArray*) values {
    return [[FactualCompoundValueFilterPredicate alloc] initWithPredicateType:NotBeginsWithAny fieldName:fieldName values:values];
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
    
    return [[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:Or filterValues:rowFilters ];
}

+(FactualRowFilter*) orFilterWithArray:(NSArray*)rowFilters {
    
    for (NSObject* object in  rowFilters) {
        if (object == nil || ![object isKindOfClass:[FactualRowFilter class]]) {
            @throw [NSException exceptionWithName:@"Invalid Arguement" reason:@"Invalid filter type in array!" userInfo:nil];
        }
    }  
    return [[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:Or filterValues:rowFilters];
}

+(FactualRowFilter*) andFilterWithArray:(NSArray*)rowFilters {
    
    for (NSObject* object in  rowFilters) {
        if (object == nil || ![object isKindOfClass:[FactualRowFilter class]]) {
            @throw [NSException exceptionWithName:@"Invalid Arguement" reason:@"Invalid filter type in array!" userInfo:nil];
        }
    }  
    return [[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:And filterValues:rowFilters];
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
    
    return [[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:And filterValues:rowFilters];
}


@end


/* -----------------------------------------------------------------------------
 FactualQuery IMPLEMENTATION
 ------------------------------------------------------------------------------*/

@implementation FactualQuery

@dynamic offset,limit,primarySortCriteria,secondarySortCriteria,rowFilters,fullTextTerms,includeRowCount,selectTerms;

+(FactualQuery*) query {
    return [[FactualQueryImplementation alloc] init];
}

@end

/* -----------------------------------------------------------------------------
 FactualQueryImplementation IMPLEMENTATION
 ------------------------------------------------------------------------------*/
@implementation FactualQueryImplementation

@synthesize offset=_offset;
@synthesize limit=_limit;
@synthesize primarySortCriteria=_primarySortCriteria;
@synthesize secondarySortCriteria=_secondarySortCriteria;
@synthesize fullTextTerms=_textTerms;
@synthesize rowFilters=_rowFilters;
@synthesize geoFilter=_geoFilter;
@synthesize includeRowCount=_includeRowCount;
@synthesize selectTerms=_selectTerms;

-(id) init {
    if (self = [super init]) {
        _rowFilters = [NSMutableArray arrayWithCapacity:0];
        _textTerms  = [NSMutableArray arrayWithCapacity:0];
        _selectTerms  = [NSMutableArray arrayWithCapacity:0];
        _offset = 0;
        _limit  = 0;
        _includeRowCount = false;
    }
    return self;
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

-(void) addSelectTerm:(NSString*) selectTerm {
    if ([selectTerm length] != 0) {
        [_selectTerms addObject:selectTerm];    
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
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (_includeRowCount) {
        [array addObject:[NSString stringWithFormat:@"include_count=true"]];
    }
    
    if (_limit > 0) {
        [array addObject:[NSString stringWithFormat:@"limit=%d", _limit]];
    }
    
    if (_offset > 0) {
        [array addObject:[NSString stringWithFormat:@"offset=%d", _offset]];
    }
    
    if (_primarySortCriteria != nil || _secondarySortCriteria != nil) {
        NSMutableString* sortStr = [[NSMutableString alloc]init ];
        [sortStr appendString:@"sort="];
        if (_primarySortCriteria != nil) {
            [_primarySortCriteria generateQueryString:sortStr];
            if (_secondarySortCriteria != nil) {
                [sortStr appendString:@","];
            }
        }
        if (_secondarySortCriteria != nil) {
            [_secondarySortCriteria generateQueryString:sortStr];
        }
        [array addObject:sortStr];
    }
    
    if ([_rowFilters count] != 0) {
        NSMutableDictionary* filterDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        if ([_rowFilters count] == 1) {
            [[_rowFilters objectAtIndex: 0] appendToDictionary:filterDictionary];
        } else {
            FactualCompoundRowFilterPredicate* andFilter = [[FactualCompoundRowFilterPredicate alloc] initWithPredicateType:And filterValues:_rowFilters];
            [andFilter appendToDictionary:filterDictionary];
        }
        NSError *error = nil;
        NSMutableString* filterStr = [[NSMutableString alloc]init ];
        [filterStr appendFormat:@"filters=%@",
         [[[NSString alloc] initWithData:
           [[CJSONSerializer serializer] serializeDictionary:filterDictionary  error:&error] 
                                encoding:NSUTF8StringEncoding]
          stringWithPercentEscape]];
        [array addObject:filterStr];
    }
    
    if ([_textTerms count] != 0) {
        NSMutableString* qString = [[NSMutableString alloc] init];
        int termNumber=0;
        for (NSString* term in _textTerms) {
            if(termNumber++ != 0) 
                [qString appendString:@","];
            [qString appendString:term];
        }
        
        [array addObject:[NSString stringWithFormat:@"q=%@",[qString stringWithPercentEscape]]];
        
    }
    if ([_selectTerms count] != 0) {
        NSMutableString* qString = [[NSMutableString alloc] init];
        int termNumber=0;
        for (NSString* term in _selectTerms) {
            if(termNumber++ != 0) 
                [qString appendString:@","];
            [qString appendString:term];
        }
        
        [array addObject:[NSString stringWithFormat:@"select=%@",[qString stringWithPercentEscape]]];
        
    }
    
    if (_geoFilter != nil) {
        NSMutableDictionary* geoDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [_geoFilter appendToDictionary:geoDictionary];
        
        NSError *error = nil;
        [array addObject:[NSString stringWithFormat:@"geo=%@",
                          [[[NSString alloc] initWithData:
                            [[CJSONSerializer serializer] serializeDictionary:geoDictionary error:&error] 
                                                 encoding:NSUTF8StringEncoding] stringWithPercentEscape]]];
    }
    
    [FactualUrlUtil appendParams:array to:qryString];
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
    return [[FactualDistanceFromPointGeoFilter alloc] initWithLocation:location distance:distance];
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





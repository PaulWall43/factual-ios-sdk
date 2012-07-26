//
//  FactualSchemaResultImpl.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualSchemaResultImpl.h"
#import "FactualFieldMetadataImpl.h"

@implementation FactualSchemaResultImpl

@synthesize tableId=_tableId;
@synthesize tableName=_tableName;
@synthesize tableDescription=_tableDescription;
@synthesize creator=_creator;
@synthesize createdAt=_createDateAndTime;
@synthesize updatedAt=_updateDateAndTime;
@synthesize isGeoEnabled=_isGeoEnabled;
@synthesize isDownloadable=_isDownloadable;
@synthesize source=_source;
@synthesize totalRowCount=_totalRowCount;
@synthesize fieldMetadata=_fieldMetadata;


-(id) initFromJSON:(NSDictionary *)jsonResponse
           tableId:(NSString*) tableId{
  if (self = [super init]) {
    _tableId = tableId;
    _tableName = [jsonResponse objectForKey:@"name"];
    _tableDescription = [jsonResponse objectForKey:@"description"]; 
    _creator = [jsonResponse objectForKey:@"creator"]; 
    _createDateAndTime = [jsonResponse objectForKey:@"createdAt"]; 
    _updateDateAndTime = [jsonResponse objectForKey:@"updatedAt"]; 
    _isGeoEnabled = [((NSNumber*) [jsonResponse objectForKey:@"geoEnabled"]) boolValue]; 
    _isDownloadable = [((NSNumber*) [jsonResponse objectForKey:@"isDownloadable"]) boolValue];  
    _source = [jsonResponse objectForKey:@"source"]; 
    _totalRowCount = [((NSNumber*) [jsonResponse objectForKey:@"totalRowCount"]) unsignedIntValue];
    NSArray* fields = [jsonResponse objectForKey:@"fields"];
    if (fields == nil) {
      _fieldMetadata = [NSArray array];
    }
    else {
      _fieldMetadata = [NSMutableArray arrayWithCapacity:([fields count]-1)];
      for (NSDictionary* fieldData in fields) {
        if ([((NSString*)[fieldData objectForKey:@"name"]) compare: @"subject_key"] != NSOrderedSame) {
          FactualFieldMetadataImpl* fieldObject = [[FactualFieldMetadataImpl alloc] initFromJSON:fieldData];
          [((NSMutableArray*)_fieldMetadata) addObject:fieldObject];
        }
      }
    }
  }
  return self;
}

-(NSString*) description {
  NSMutableString* mutableString = [NSMutableString stringWithCapacity:[_fieldMetadata count]];
 
  [mutableString appendString:[NSString stringWithFormat:@"FactualSchemaResult"\
                               " tableId:%@"\
                               " tableName:%@"\
                               " tableDescription:%@"\
                               " creator:%@ createdAt:%@ updatedAt:%@ isGeoEnabled:%d isDownloadable:%d"\
                               " source:%@ totalRowCount:%d\n",
        [self tableId],
        [self tableName],
        [self tableDescription],
        [self creator],
        [self createdAt],
        [self updatedAt],
        [self isGeoEnabled],
        [self isDownloadable],
        [self source],
        [self totalRowCount]]];
  
  for (FactualFieldMetadata* metadata in _fieldMetadata) {
    [mutableString appendFormat:@"\t%@\n",[metadata description]];
  }
  
  return mutableString;
}

@end

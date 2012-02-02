//
//  FactualUpdateResult.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualUpdateResult.h"


@implementation FactualUpdateResult

@synthesize affectedRowId=_affectedRowId,exists=_exists,tableId=_tableId;

-(id) initWithRowId:(NSString*) rowIdValue
             exists:(BOOL) existsValue
            tableId:(NSString*)tableId {

  if (self = [super init]) {
    _affectedRowId = [rowIdValue retain];
    _exists = existsValue;
    _tableId = [tableId retain];
  }
  return self;
}

-(void) dealloc {
  [_affectedRowId release];
  [_tableId release];
  [super dealloc];
}

-(NSString*) description {
  return [NSString stringWithFormat:@"FactualUpdateResult affectedRowId:%@\
          exists:%d",_affectedRowId,_exists];
}

@end

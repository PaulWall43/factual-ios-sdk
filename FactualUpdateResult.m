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
    _affectedRowId = rowIdValue;
    _exists = existsValue;
    _tableId = tableId;
  }
  return self;
}

-(NSString*) description {
  return [NSString stringWithFormat:@"FactualUpdateResult affectedRowId:%@\
          exists:%d",_affectedRowId,_exists];
}

@end

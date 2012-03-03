//
//  FactualAPIHelper.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualAPIHelper.h"
#import "CJSONSerializer.h"
#import "FactualQueryImpl.h"


@implementation FactualAPIHelper

+(NSString*) buildAPIRequestURL:(NSString*) hostName 
                  apiVersion:(NSInteger) apiVersion
                    queryStr:(NSString*) queryStr {
  
  if (apiVersion == 2) { 
    NSString *url = [NSString stringWithFormat:@"http://%@/v%d/%@",
                     hostName, apiVersion,queryStr];
    return [url autorelease];

  }
  else if (apiVersion == 3) { 
    NSString *url = [NSString stringWithFormat:@"http://api.v3.factual.com/%@",queryStr];

    return [url autorelease];
  }
  return nil;
}


+(NSString*) buildTableQueryString:(NSString*) apiKey tableId:(NSString*) tableId queryParams:(FactualQuery*) tableQuery{
  
	NSMutableString *qry = [[[NSMutableString alloc] initWithFormat:@"tables/%@/read", tableId] autorelease];

  
  if (tableQuery != nil) {
    [qry appendString:@"?api_key="];
    [qry appendString:apiKey];
    [qry appendString:@"&"];
    FactualQueryImplementation* queryImpl = (FactualQueryImplementation*)tableQuery;
    [queryImpl generateQueryString:qry]; 
  }
#ifdef TARGET_IPHONE_SIMULATOR    
  NSLog(@"Filter Query%@",qry);
#endif  
	// [qry deleteCharactersInRange:NSMakeRange([qry length] - 1, 1)];
	return qry;
  
} 


  //NEW API!!!
+(NSString*) buildPlacesQueryString:(NSString*) apiKey tableId:(NSString*) tableId queryParams:(FactualQuery*) tableQuery{
  
	NSMutableString *qry = [[[NSMutableString alloc] initWithFormat:@"t/%@?", tableId] autorelease];

  if (tableQuery != nil) {  
    FactualQueryImplementation* queryImpl = (FactualQueryImplementation*)tableQuery;
    [queryImpl generateQueryString:qry];
  }
  if (apiKey != nil) { 
    [qry appendString:@"&"];
    [qry appendString:@"KEY="];
    [qry appendString:apiKey];
  }
#ifdef TARGET_IPHONE_SIMULATOR    
  NSLog(@"Filter Query%@",qry);
#endif  
    // [qry deleteCharactersInRange:NSMakeRange([qry length] - 1, 1)];
	return qry;
} 


+(NSString*) buildUpdateQueryString:(NSString*) tableId {
  return [NSString stringWithFormat:@"tables/%@/input", tableId];
}

+(NSString*) buildSchemaQueryString:(NSString*) apiKey tableId:(NSString*) tableId {
  return [NSString stringWithFormat:@"tables/%@/schema?api_key=%@", tableId,apiKey];
}

+(NSString*) buildTableUpdatePostBody:(NSString*) apiKey
                                facts:(NSDictionary*) facts
                       optionalRowId:(NSString*) rowId  
                       optionalSource:(NSString*) source 
             optionalUserTokenId:(NSString*) tokenId 
                      optionalComment:(NSString*) comment {
  
  // create a mutable string ... 
  NSMutableString* postBodyStr = [NSMutableString stringWithCapacity:2048];
  
  [postBodyStr appendFormat:@"api_key=%@&",apiKey];
  if (rowId != nil) {
    [postBodyStr appendFormat:@"subjectKey=%@&",rowId];
  }
  if (source != nil){
    [postBodyStr appendFormat:@"source=%@&",source];
  }
  if (comment != nil) {
    [postBodyStr appendFormat:@"comments=%@&",comment];
  }
  if (tokenId != nil) {
    [postBodyStr appendFormat:@"token=%@&",tokenId];
  }
  // ok now create a serialized representation of facts ... 
  NSString* serializedFacts = [[CJSONSerializer serializer] serializeDictionary:facts];
  // and then encode them properly ... 
  NSString* escapedFacts = (NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)serializedFacts,NULL,CFSTR("?=&+"),kCFStringEncodingUTF8);
  // auto release it 
  [escapedFacts autorelease];
  // append to final string 
  [postBodyStr appendFormat:@"values=%@",escapedFacts];
  
  return postBodyStr;
}

+(NSString*) buildRateQueryString:(NSString*)apiKey 
                          tableId:(NSString*)tableId
                            rowId:(NSString*)rowId
                           source:(NSString*)source
                          comment:(NSString*)comment {
  
	NSMutableString *qry = [[[NSMutableString alloc] initWithFormat:@"tables/%@/rate?api_key=%@&rowId=%@&rating=-1", 
                           tableId,
                           apiKey,
                           rowId] autorelease];
  if (source != nil) {
    [qry appendFormat:@"&source=%@",
     [((NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)source,NULL,CFSTR("?=&+"),kCFStringEncodingUTF8)) autorelease]
     ];
  }
  if (comment != nil) {
    [qry appendFormat:@"&comments=%@",
     [((NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)comment,NULL,CFSTR("?=&+"),kCFStringEncodingUTF8)) autorelease]
     ];
  }
  
  return qry;
}



@end

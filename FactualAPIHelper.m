//
//  FactualAPIHelper.m
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import "FactualAPIHelper.h"
#import "CJSONSerializer.h"
#import "FactualQueryImpl.h"
#import "FactualFacetQueryImpl.h"


@implementation FactualAPIHelper

+(NSString*) buildAPIRequestURL:(NSString*) hostName 
                       queryStr:(NSString*) queryStr {
    
    NSString *url = [NSString stringWithFormat:@"http://api.v3.factual.com/%@",queryStr];
    return url;
}


+(NSString*) buildTableQueryString:(NSString*) apiKey tableId:(NSString*) tableId queryParams:(FactualQuery*) tableQuery{
    
	NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"tables/%@/read", tableId];
    
    
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

+(NSString*) buildQueryString:(NSString*) apiKey path:(NSString*) path queryParams:(FactualQuery*) tableQuery{
    NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"%@?", path];
    
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

//NEW API!!!
+(NSString*) buildPlacesQueryString:(NSString*) apiKey tableId:(NSString*) tableId queryParams:(FactualQuery*) tableQuery{
    NSString *qry = [[NSString alloc] initWithFormat:@"t/%@", tableId];
	return [self buildQueryString:apiKey path:qry queryParams:tableQuery];
} 


+(NSString*) buildUpdateQueryString:(NSString*) tableId {
    return [NSString stringWithFormat:@"tables/%@/input", tableId];
}

+(NSString*) buildSchemaQueryString:(NSString*) apiKey tableId:(NSString*) tableId {
    NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"t/%@/schema?", tableId];
    if (apiKey != nil) { 
        [qry appendString:@"&"];
        [qry appendString:@"KEY="];
        [qry appendString:apiKey];
    }
    return qry;
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
    
    NSError *error = NULL;
    
    // ok now create a serialized representation of facts ... 
    NSString* serializedFacts = [[NSString alloc] initWithData: [[CJSONSerializer serializer] serializeDictionary:facts  error:&error] encoding: NSUTF8StringEncoding];
    // and then encode them properly ... 
    NSString* escapedFacts = (__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)serializedFacts,NULL,CFSTR("?=&+"),kCFStringEncodingUTF8);
    // auto release it 
    // append to final string 
    [postBodyStr appendFormat:@"values=%@",escapedFacts];
    
    return postBodyStr;
}

+(NSString*) buildRateQueryString:(NSString*)apiKey 
                          tableId:(NSString*)tableId
                            rowId:(NSString*)rowId
                           source:(NSString*)source
                          comment:(NSString*)comment {
    
	NSMutableString *qry = [[NSMutableString alloc] initWithFormat:@"tables/%@/rate?api_key=%@&rowId=%@&rating=-1", 
                            tableId,
                            apiKey,
                            rowId];
    if (source != nil) {
        [qry appendFormat:@"&source=%@",
         ((__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)source,NULL,CFSTR("?=&+"),kCFStringEncodingUTF8))
         ];
    }
    if (comment != nil) {
        [qry appendFormat:@"&comments=%@",
         ((__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)comment,NULL,CFSTR("?=&+"),kCFStringEncodingUTF8))
         ];
    }
    
    return qry;
}



@end

//
//  FactualAPIHelper.h
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FactualQuery.h"

@interface FactualAPIHelper : NSObject {
  
}

+(NSString*) buildAPIRequestURL:(NSString*) host 
                  apiVersion:(NSInteger) apiVersion
                  queryStr:(NSString*) queryStr;

+(NSString*) buildTableQueryString:(NSString*) apiKey tableId:(NSString*) tableId queryParams:(FactualQuery*) queryParams;
+(NSString*) buildPlacesQueryString:(NSString*) apiKey tableId:(NSString*) tableId queryParams:(FactualQuery*) tableQuery;
+(NSString*) buildUpdateQueryString:(NSString*) tableId;
+(NSString*) buildTableUpdatePostBody:(NSString*) apiKey
                                facts:(NSDictionary*) facts
                        optionalRowId:(NSString*) rowId  
                       optionalSource:(NSString*) source 
             optionalUserTokenId:(NSString*) tokenId 
                      optionalComment:(NSString*) comment;
+(NSString*) buildSchemaQueryString:(NSString*) apiKey tableId:(NSString*) tableId;
+(NSString*) buildRateQueryString:(NSString*)apiKey 
                          tableId:(NSString*)tableId
                            rowId:(NSString*)rowId
                           source:(NSString*)source
                          comment:(NSString*)comment;

@end

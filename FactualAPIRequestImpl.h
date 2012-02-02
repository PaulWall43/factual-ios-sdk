//
//  FactualAPIRequest.h
//  FactualSDK
//
//  Copyright 2010 Factual Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FactualAPIRequest.h"
#import <Foundation/NSURLConnection.h>

@protocol FactualAPIDelegate;

@interface FactualAPIRequestImpl : FactualAPIRequest {
  
@private  
  NSString*               _requestId;
  NSString*               _tableId;
  FactualRequestType      _requestType;
  id<FactualAPIDelegate>  _delegate;
  NSURLConnection*        _connection;
  NSString*               _url;
  NSString*               _httpMethod;
  NSMutableData*          _responseText;
  id                      _apiObject;
}

@property (nonatomic,readonly) NSString* url;



-(id) initWithURL:(NSString *) url
          requestType:(NSInteger) requestType
          optionalTableId:(NSString*) tableId
          withDelegate:(id<FactualAPIDelegate>) delegate
          withAPIObject:(id) theAPIObject
          optionalPayload:(NSString*) payload;

-(id) initOAuthRequestWithURL:(NSString *) url
      requestType:(NSInteger) requestType
  optionalTableId:(NSString*) tableId
     withDelegate:(id<FactualAPIDelegate>) delegate
    withAPIObject:(id) theAPIObject
  optionalPayload:(NSString*) payload
  consumerKey:(NSString*) consumerKey
  consumerSecret:(NSString*) consumerSecret;




@end

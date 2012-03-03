//
//  NSString (Escaping).m
//  FactualSDK
//
//  Created by Ahad Rana on 2/2/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import "NSString (Escaping).h"

@implementation NSString (Escaping)
- (NSString*)stringWithPercentEscape {            
  return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8) autorelease];
}
@end

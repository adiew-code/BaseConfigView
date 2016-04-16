//
//  NSString+Util.m
//  WinCore
//
//  Created by Nemo on 14-1-22.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "NSString+Util.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Util)

+ (NSString *)stringWithValue:(id) value{
    
    @try {
        return [[self class] stringWithValue:value byDefault:nil];
    }
    @catch (NSException *exception) {
        return nil;
    }
    return nil;
}

+ (NSString *)stringNotNilWithValue:(id) value{
    @try {
        return [[self class] stringWithValue:value byDefault:@""];
    }
    @catch (NSException *exception) {
        return @"";
    }
    return @"";
}

+(NSString *)stringWithValue:(id) value byDefault:(NSString *) defaultValue{

    @try {
        if(value == defaultValue ||(defaultValue != nil && [value isKindOfClass:[NSString class]] && [value isEqualToString:defaultValue])){
            return value;
        }
        if(value != nil){
            if([value isKindOfClass:[NSString class]]){
                return value;
            }
            if([value isKindOfClass:[NSNull class]]){
                return defaultValue;
            }
            if([value isKindOfClass:[NSNumber class]]){
                return [value stringValue];
            }
            if([value isKindOfClass:[NSObject class]]){
//                LogWarn(@"Wrong Value Type:%@, you want string!",value);
                return [value description];
            }
        }
    }
    @catch (NSException *exception) {
        return defaultValue;
    }
    
    return defaultValue;

}

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString*) uniqueString
{
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

-(NSString *)reserveChineseOnly
{
    for (NSInteger i=0; i<self.length; i++)
    {
        const char *Char = [[self substringWithRange:NSMakeRange(i, 1)] UTF8String];
        if (3==strlen(Char))
        {//字符串中含有中文
            return [self substringFromIndex:i];
        }
    }
    return self;
}

- (NSString*) mk_urlEncodedString { // mk_ prefix prevents a clash with a private api
    
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) self,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
    
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
    
    if(!encodedString)
        encodedString = @"";
    
    return encodedString;
}

- (NSString*) urlDecodedString {
    
    CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef) self,
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    
    // We need to replace "+" with " " because the CF method above doesn't do it
    NSString *decodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) decodedCFString];
    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

-(NSInteger) indexOfString:(NSString *)text{
    
    NSRange range = [self rangeOfString:text];
    
    if (range.length>0) {
        
        return range.location;
    }else{
    
        return -1;
    }
    
    
}

+ (NSString * )gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    
    return uuid;
}

@end

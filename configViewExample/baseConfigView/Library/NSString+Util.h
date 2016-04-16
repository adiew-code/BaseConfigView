//
//  NSString+Util.h
//  WinCore
//
//  Created by Nemo on 14-1-22.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)
/*
 *如果string为nil或不合法，返回 nil,否则返回本身，一般是取数据的时候用（主要是NSNull的问题）
 */
+ (NSString *)stringWithValue:(id) value;

/*
 *如果string为nil或不合法，返回 @"",否则返回本身，一般是set数据的时候用，有的时候set某个key会崩溃
 */
+ (NSString *)stringNotNilWithValue:(id) value;

/*
 * 如果string为nil或不合法，返回 @defaultValue，否则返回本身
 */
+(NSString *)stringWithValue:(NSString *) string byDefault:(NSString *) defaultValue;

-(NSString*)reserveChineseOnly;

- (NSString *) md5;
+ (NSString*) uniqueString;
- (NSString*) mk_urlEncodedString;
- (NSString*) urlDecodedString;

- (NSInteger) indexOfString:(NSString *)text;

+ (NSString *)gen_uuid;

@end

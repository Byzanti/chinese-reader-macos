//
//  SKPinyinConverter.h
//  Chinese Reader
//
//  Created by Peter on 14/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKPinyinConverter : NSObject {
    NSMutableDictionary *toneMarks;
    NSMutableDictionary *reverseToneMarks;
}

+ (BOOL)canUseRegex; //So can still support 10.6
+ (NSString *)addToneMarksToWord:(NSString *)word;
+ (NSString *)addToneMark:(NSString *)syl;  /// @"xiao3" -> @"xiǎo". If it's not a valid pinyin, it will return nil.
+ (NSString *)stripToneMarks:(NSString *)p;   /// @"xiǎo lǎo" -> @"xiao lao"
+ (ushort)toneNumberFromSyllable:(NSString *)syl; /// @"xiao3" -> 3

@end

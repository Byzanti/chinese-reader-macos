//
//  CRAddWords.h
//  Chinese Reader
//
//  Created by Peter on 12/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRAddWords : NSObject

+(void)addWordToKnownWords:(NSString *)word;
+(void)addWordsToKnownWords:(NSArray *)wordArray;


+(void)addWordToSkritter:(NSString *)word withPinyin:(NSString *)pinyin withDefinition:(NSString *)definition;
+(void)addWordsToSkritter:(NSArray *)wordArray;

//Used for selected words only that we don't have details for in the internal dictionary - added Dec 2015
+(void)addSelectedWordsToSkritter:(NSArray *)wordArray;

@end

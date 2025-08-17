//
//  CRAddWords.m
//  Chinese Reader
//
//  Created by Peter on 12/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRAddWords.h"

@implementation CRAddWords

+(void)addWordToKnownWords:(NSString *)word {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSArray *items = [NSArray arrayWithObject:word];
    NSDictionary *itemsDict = [NSDictionary dictionaryWithObjectsAndKeys:items,@"items",nil];
	[center postNotificationName:@"AddToKnownItems" object:self userInfo:itemsDict];
}

+(void)addWordsToKnownWords:(NSArray *)wordArray {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *itemsDict = [NSDictionary dictionaryWithObjectsAndKeys:wordArray,@"items",nil];
	[center postNotificationName:@"AddToKnownItems" object:self userInfo:itemsDict];
}

+(void)addWordToSkritter:(NSString *)word withPinyin:(NSString *)pinyin withDefinition:(NSString *)definition {
    NSString *skritURL = [NSString stringWithFormat:@"http://www.skritter.com/vocab/api/add?lang=zh&from=bycr&word=%@&rdng=%@&defn=%@",word,pinyin,definition];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[skritURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

+(void)addWordsToSkritter:(NSArray *)wordArray {
    [wordArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *characters = [obj objectForKey:@"characters"];
        NSString *pinyin = [obj objectForKey:@"pinyin"];
        NSString *definition = [obj objectForKey:@"definition"];
        
        NSString *skritURL = [NSString stringWithFormat:@"http://www.skritter.com/vocab/api/add?lang=zh&from=bycr&word=%@&rdng=%@&defn=%@",characters,pinyin,definition];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[skritURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }];
}

//This is used where we don't have a definition or pinyin -- need to test Skritter accepts this
+(void)addSelectedWordsToSkritter:(NSArray *)wordArray {
    [wordArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *skritURL = [NSString stringWithFormat:@"http://www.skritter.com/vocab/api/add?lang=zh&from=bycr&word=%@",obj];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[skritURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }];
}


@end

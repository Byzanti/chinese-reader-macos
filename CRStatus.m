//
//  CRAddingBookmarkStatus.m
//  Chinese Reader
//
//  Created by Peter Wood on 03/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRStatus.h"

@implementation CRStatus


+(BOOL)addingBookmark {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings boolForKey:@"addingBookmark"];
}

+(void)setAddingBookmark:(BOOL)value {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:value forKey:@"addingBookmark"];
    [settings synchronize];
}

+(BOOL)textChanged {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings boolForKey:@"textChanged"];
}

+(void)setTextChanged:(BOOL)value {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:value forKey:@"textChanged"];
}

+(BOOL)checkedText {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings boolForKey:@"checkedText"];
}

+(void)setCheckedText:(BOOL)value {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:value forKey:@"checkedText"];
}

+(BOOL)firstTime {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings boolForKey:@"firstTime"];
}

+(void)setFirstTime:(BOOL)value {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:value forKey:@"firstTime"];
}

+(NSString *)currentDocument {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *currentDocument = [settings objectForKey:@"currentDocument"];
    if (!currentDocument || [currentDocument isEqualToString:@"(null)"]) currentDocument = @"Unsaved document";
    return currentDocument;
}

+(NSString *)currentArea {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings stringForKey:@"currentArea"];
}

+(void)setCurrentArea:(NSString *)bookEditorSummary {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:bookEditorSummary forKey:@"currentArea"];
}


//Setting status text
+(void)setEditorStatusText:(NSString *)string {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *newStatusDict = [NSDictionary dictionaryWithObject:string forKey:@"Editor"];
    [center postNotificationName:@"newStatusText" object:self userInfo:newStatusDict];
}

+(void)setBookStatusText:(NSString *)string {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *newStatusDict = [NSDictionary dictionaryWithObject:string forKey:@"Book"];
    [center postNotificationName:@"newStatusText" object:self userInfo:newStatusDict];
    
}
+(void)setSummaryStatusText:(NSString *)string {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *newStatusDict = [NSDictionary dictionaryWithObject:string forKey:@"Summary"];
    [center postNotificationName:@"newStatusText" object:self userInfo:newStatusDict];
    
}
+(void)setAllStatusTexts:(NSString *)string {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *newStatusDict = [NSDictionary dictionaryWithObject:string forKey:@"All"];
    [center postNotificationName:@"newStatusText" object:self userInfo:newStatusDict];
}

@end

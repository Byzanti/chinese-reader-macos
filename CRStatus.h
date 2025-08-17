//
//  CRAddingBookmarkStatus.h
//  Chinese Reader
//
//  Created by Peter Wood on 03/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRStatus : NSObject

+(BOOL)addingBookmark;
+(void)setAddingBookmark:(BOOL)value;

+(BOOL)textChanged;
+(void)setTextChanged:(BOOL)value;

+(BOOL)checkedText;
+(void)setCheckedText:(BOOL)value;

+(BOOL)firstTime;
+(void)setFirstTime:(BOOL)value;

+(NSString *)currentDocument;

/*This is currently unenabled, but if I want to add itI need to use add a NSTabViewDelegate for main windows and probably this:
 - (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
 and then use this code: NSLog(@"%@",(NSString*)[[tabView selectedTabViewItem] identifier]); to return the current tab
*/
+(NSString *)currentArea;
+(void)setCurrentArea:(NSString *)bookEditorSummary;

//Status bar text

+(void)setEditorStatusText:(NSString *)string;
+(void)setBookStatusText:(NSString *)string;
+(void)setSummaryStatusText:(NSString *)string;
+(void)setAllStatusTexts:(NSString *)string;

@end

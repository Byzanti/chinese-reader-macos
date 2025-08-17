//
//  CRColoursAndAttributes.m
//  Chinese Reader
//
//  Created by Peter Wood on 06/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRColoursAndAttributes.h"

@implementation CRColoursAndAttributes

-(void)awakeFromNib {
    center = [NSNotificationCenter defaultCenter];
    settings = [NSUserDefaults standardUserDefaults];
    editorTextStorage = [editorTextView textStorage];
    
}

-(void)addAttributesForUnknownItem:(NSString *)itemName atRange:(NSRange)rangeInString {
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:itemName,@"Unknown Word",[settings colorForKey:@"editorUnknownVocabColour"],NSForegroundColorAttributeName,nil];
	[editorTextStorage addAttributes:attributes range:rangeInString];
}

-(void)removeAttributesForKnownItem:(NSString *)knownItem {
    
    NSColor *knownColour = [settings colorForKey:@"editorKnownVocabColour"];    
    NSString *unknownWord = @"Unknown Word";
    
    [editorTextStorage enumerateAttribute:unknownWord inRange:NSMakeRange(0, [editorTextStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        if ([value isEqualToString:knownItem]) { 
            [editorTextStorage removeAttribute:unknownWord range:range];
            [editorTextStorage addAttribute:NSForegroundColorAttributeName value:knownColour range:range];
        }
    }];
	
}

-(void)recolourKnownAndUnknownItems {
    NSColor *knownColour = [settings colorForKey:@"editorKnownVocabColour"];
    NSColor *unknownColour = [settings colorForKey:@"editorUnknownVocabColour"];
    NSRange fullRange = NSMakeRange(0, [editorTextStorage length]);
    
    [editorTextStorage beginEditing];
    [editorTextStorage addAttribute:NSForegroundColorAttributeName value:knownColour range:fullRange];
    [editorTextStorage enumerateAttribute:@"Unknown Word" inRange:fullRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) { 
        if (value) [editorTextStorage addAttribute:NSForegroundColorAttributeName value:unknownColour range:range];
    }];
    [editorTextStorage endEditing];
}

-(void)recolourKnownItems {
    NSColor *knownColour = [settings colorForKey:@"editorKnownVocabColour"];
    [editorTextStorage beginEditing];
    [editorTextStorage enumerateAttribute:@"Unknown Word" inRange:NSMakeRange(0, [editorTextStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) { 
        if (!value) [editorTextStorage addAttribute:NSForegroundColorAttributeName value:knownColour range:range];
    }];
    [editorTextStorage endEditing];
}

-(void)recolourUnknownItems {
    NSColor *unknownColour = [settings colorForKey:@"editorUnknownVocabColour"];
    [editorTextStorage beginEditing];
    [editorTextStorage enumerateAttribute:@"Unknown Word" inRange:NSMakeRange(0, [editorTextStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) { 
        if (value) [editorTextStorage addAttribute:NSForegroundColorAttributeName value:unknownColour range:range];
    }];
    [editorTextStorage endEditing];
}

-(void)recolourBookmarks {
    NSColor *bookmarkColour = [settings colorForKey:@"editorBookmarkColour"];
    [editorTextStorage beginEditing];
    [editorTextStorage enumerateAttribute:@"bookmark" inRange:NSMakeRange(0, [editorTextStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) { 
        if (value) [editorTextStorage addAttribute:NSBackgroundColorAttributeName value:bookmarkColour range:range];
    }]; 
    [editorTextStorage endEditing];
    
}



@end

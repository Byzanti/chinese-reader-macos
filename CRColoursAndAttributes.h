//
//  CRColoursAndAttributes.h
//  Chinese Reader
//
//  Created by Peter Wood on 06/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMouseOverTextView.h"

@interface CRColoursAndAttributes : NSObject {
    
    NSNotificationCenter *center;
	NSUserDefaults *settings;

    NSTextStorage *editorTextStorage;
    
    IBOutlet CRMouseOverTextView *editorTextView;
}

-(void)addAttributesForUnknownItem:(NSString *)itemName atRange:(NSRange)rangeInString;
-(void)removeAttributesForKnownItem:(NSString *)knownItem;
-(void)recolourKnownAndUnknownItems;
-(void)recolourKnownItems;
-(void)recolourUnknownItems;
-(void)recolourBookmarks;

@end

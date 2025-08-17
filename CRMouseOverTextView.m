//
//  CRMouseOverTextView.m
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRMouseOverTextView.h"


@implementation CRMouseOverTextView

@synthesize trackingArea;
@synthesize popupForAllWords;

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:[self.superview bounds]]) {

    }
    return self;
}

-(void)awakeFromNib {
	[self setup];
}

-(void)setup {
	
	settings = [NSUserDefaults standardUserDefaults];
	center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(loadSettings:) name:@"LoadSettings" object:nil];
	[center addObserver:self selector:@selector(reloadPopupState:) name:@"ReloadPopupState" object:nil];
    [center addObserver:self selector:@selector(becomeActive) name:@"becomeActive" object:nil];
    [center addObserver:self selector:@selector(sendSelectedWord:) name:@"SendSelectedWord" object:nil];

	puncSetString = @"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ “”·、,{}[]|-+_=ªº•¶§∞¢#€¡!@£$%^&*\n\t。.，;:；：”’\"'()?<>《》！@￥%⋯⋯&×（）";
	[self setPopupForAllWords:[settings boolForKey:@"popupForAllWords"]];
	
    
	//Original - but doesn't work when using spaces
    //[self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:(NSTrackingActiveInActiveApp | NSTrackingMouseMoved) owner:self userInfo:nil]];
    [self createTrackingArea];
}

-(void)createTrackingArea {
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self.superview bounds] options:(NSTrackingActiveInActiveApp | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited) owner:self userInfo:nil]];
    
    [self addTrackingArea:trackingArea];

}

-(void)reloadPopupState:(NSNotification *)notification {
	[self setPopupForAllWords:[settings boolForKey:@"popupForAllWords"]];
}

-(void)loadSettings:(NSNotification *)notification {
	[self setPopupForAllWords:[settings boolForKey:@"popupForAllWords"]];	
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
    //NSLog(@"mouse moved");
    
    if ([self addingBookmark]) {
        [[NSCursor pointingHandCursor] set];
    }
    
	NSLayoutManager *layoutManager = [self layoutManager];
	NSTextContainer *textContainer = [self textContainer];
	NSUInteger glyphIndex,charIndex;
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSPoint originalPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect glyphRect;
    
    [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [[self textStorage] length])];
    
	
	// Convert view coordinates to container coordinates
	point.x -= [self textContainerOrigin].x;
	point.y -= [self textContainerOrigin].y;
	
	// Convert those coordinates to the nearest glyph index
	glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
	
	
	// Check to see whether the mouse actually lies over the glyph it is nearest to
	glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:textContainer];
	if (NSPointInRect(point, glyphRect)) {
		
		// Convert the glyph index to a character index
		charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
			
        //Attributed string for the character in question
        NSAttributedString *articleText = [[NSAttributedString alloc] initWithAttributedString:[layoutManager attributedString]];
        NSAttributedString *theCharacter = [articleText attributedSubstringFromRange:NSMakeRange(charIndex, 1)];
        
        //If it's not Chinese, doesn't display anything
        if ([puncSetString rangeOfString:[theCharacter string]].length > 0) goto displayNothing;
        
        //If adding bookmarks, changes the background, then returns
        if ([self addingBookmark]) { 
            [layoutManager addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor],NSBackgroundColorAttributeName,nil] forCharacterRange:NSMakeRange(charIndex, 1)];
            return;
        }
        
        //If a word we do know, and popups for such words shouldn't be displayed, goes to the end
        NSString *charAttribute = [theCharacter attribute:@"Unknown Word" atIndex:0 effectiveRange:NULL];
        if (![theCharacter attribute:@"Unknown Word" atIndex:0 effectiveRange:NULL] && ![self popupForAllWords]) goto displayNothing;
        
        //Gets a string around the character
        int charactersToCheck = 6;
        int startingIndex = charIndex - charactersToCheck;
        int length = (charactersToCheck *2) -1;
        int subStringCharIndex = 6;
        
        //checks and corrects range issues
        if (startingIndex < 0) { 
            startingIndex = 0;
            subStringCharIndex = charIndex;
        }
        
        if (startingIndex + length > [articleText length]) {
            length = [articleText length] - startingIndex;
            subStringCharIndex = length - ([articleText length] - charIndex);
        }
        
        //Finds the word amidst the string & returns the point at which the word starts
        NSString *findMeAWord = [[articleText string] substringWithRange:NSMakeRange(startingIndex, length)];
        NSRange charRange;
        NSString *word = [CRDictSearch wordOrCharacterFromString:findMeAWord forCharacterAtIndex:subStringCharIndex rangeToIndex:&charRange];
        if (!word) return;
        
        NSRange firstCharRange = NSMakeRange(charIndex - charRange.location, 1);
        NSUInteger rcount;
        NSRectArray rectArray = [layoutManager rectArrayForCharacterRange:firstCharRange withinSelectedCharacterRange:(NSRange){NSNotFound, 0} inTextContainer:textContainer rectCount:&rcount];
        NSPoint firstCharPoint = rectArray[0].origin;
        /*
        //Sometimes the rect doesn't exist, so it crashes... Added if (!word) above, so hopefully wont need this bit
        if (NSStringFromPoint(rectArray[0].origin)) firstCharPoint = rectArray[0].origin;
        else firstCharPoint = NSMakePoint(0, 0); */
        
        //Calculates the point the popup should display at (glyph gets offset when textinset is used, this compensates)
        //However if the start of the character is not on the same line, it just places the popup under the glyph
        NSPoint characterPointInTextView;
        if (firstCharPoint.y == glyphRect.origin.y) {
            characterPointInTextView.x = originalPoint.x - point.x + firstCharPoint.x;
            characterPointInTextView.y = originalPoint.y - point.y + firstCharPoint.y;
        }
        else {
            characterPointInTextView.x = originalPoint.x - point.x + glyphRect.origin.x;
            characterPointInTextView.y = originalPoint.y - point.y + glyphRect.origin.y;
        }
        
        //since textcontainer points are not cartesian, this converts to the main window coordinate system
        characterPointInTextView = [self convertPoint:characterPointInTextView toView:[[self window] contentView]];
        
        //new glyph rect
        NSRect newGlyphRect = NSMakeRect(originalPoint.x - point.x + glyphRect.origin.x, originalPoint.y - point.y + glyphRect.origin.y, glyphRect.size.width, glyphRect.size.height);
        newGlyphRect.origin = [self convertPoint:newGlyphRect.origin toView:[[self window] contentView]];
    
        NSFont *currentFont = [self font];
        CGFloat fontLineHeight = [layoutManager defaultLineHeightForFont:currentFont];
        
        //correcting for fontlineheight
        characterPointInTextView.y = characterPointInTextView.y - fontLineHeight;
        newGlyphRect.origin.y = newGlyphRect.origin.y - fontLineHeight;
        
        NSString *glyphRectString = NSStringFromRect(newGlyphRect);
        NSString *fontLineHeightString = [NSString stringWithFormat:@"%F",fontLineHeight];
        NSString *currentPoint = NSStringFromPoint(characterPointInTextView);

        NSDictionary *notificationDict;
        if (charAttribute) notificationDict = [NSDictionary dictionaryWithObjectsAndKeys:charAttribute,@"itemName",@"NO",@"Known item?",currentPoint,@"currentPoint",glyphRectString,@"glyphRect",currentFont,@"currentFont",@"YES",@"Buttons?",fontLineHeightString,@"fontLineHeight", nil];
        else notificationDict = [NSDictionary dictionaryWithObjectsAndKeys:word,@"itemName",@"YES",@"Known item?",currentPoint,@"currentPoint",glyphRectString,@"glyphRect",currentFont,@"currentFont",@"NO",@"Buttons",fontLineHeightString,@"fontLineHeight",nil];
        
        [center postNotificationName:@"WantPopup" object:self userInfo:notificationDict];

	}
	
	//If the mouse isn't directly on a glyph, makes sure nothing is displayed
	else {
		
		displayNothing:
		[center postNotificationName:@"No item" object:self];
		
	}

}

-(void)paste:(id)sender {
	//stops pasted strings inheriting the previous word's attributes, and makes sure pasted rich text conforms to current font size & default colour
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSString *pasteboardString = [pb stringForType:NSPasteboardTypeString];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[settings colorForKey:@"editorKnownVocabColour"],NSForegroundColorAttributeName,[self font],NSFontAttributeName,[self defaultParagraphStyle],NSParagraphStyleAttributeName,nil];
	NSAttributedString *atString = [[NSAttributedString alloc] initWithString:pasteboardString attributes:attributes];
	[pb clearContents];
	[pb writeObjects:[NSArray arrayWithObject:atString]];
	
	[self pasteAsRichText:nil];
}

-(void)mouseEntered:(NSEvent *)theEvent {
   /* NSLog(@"Mouse entered");
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] makeFirstResponder:self];*/
	[center postNotificationName:@"No item" object:self];
}

-(void)mouseExited:(NSEvent *)theEvent {
   /* NSLog(@"Mouse exited");
    [[self window] setAcceptsMouseMovedEvents:NO]; */
	[center postNotificationName:@"No item" object:self];
}

-(void)changeFont:sender {

    //When the font is changed by the font panel, saves the new setting
    NSFontManager *fontManager = sender;
    NSFont *newFont;
    newFont=[fontManager convertFont:[self font]];    
    [self setFont:newFont];
    
    [settings setObject:[newFont fontName] forKey:@"fontName"];
    [settings setFloat:[newFont pointSize] forKey:@"fontSize"];
    [settings synchronize];
    [center postNotificationName:@"UpdateFontSizeSlider" object:self];
}

-(void)mouseDown:(NSEvent *)theEvent {
    if (![self addingBookmark]) { [super mouseDown:theEvent]; return; }

	NSLayoutManager *layoutManager = [self layoutManager];
	NSTextContainer *textContainer = [self textContainer];
	NSUInteger glyphIndex,charIndex;
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect glyphRect;
	
	// Convert view coordinates to container coordinates
	point.x -= [self textContainerOrigin].x;
	point.y -= [self textContainerOrigin].y;
	
	// Convert those coordinates to the nearest glyph index
	glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
	
	
	// Check to see whether the mouse actually lies over the glyph it is nearest to
	glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:textContainer];
	if (NSPointInRect(point, glyphRect)) {
		
		// Convert the glyph index to a character index
		charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
        
        //Checks to see if the word at the index is unknown
        NSAttributedString *articleText = [[NSAttributedString alloc] initWithAttributedString:[layoutManager attributedString]];
        
        //If it's not Chinese, doesn't display anything
        NSAttributedString *theCharacter = [articleText attributedSubstringFromRange:NSMakeRange(charIndex, 1)];
        if ([puncSetString rangeOfString:[theCharacter string]].length > 0) goto dontAddBookmark;
        
        //Posts the range where the bookmark should be added
        NSRange characterRange = NSMakeRange(charIndex, 1);
        NSDictionary *rangeDict = [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromRange(characterRange),@"range",nil];
        
        [center postNotificationName:@"AddBookmarkAttributes" object:self userInfo:rangeDict];
        
	}

dontAddBookmark:
    [self setAddingBookmark:NO];
    [[NSCursor IBeamCursor] set];
}

-(BOOL)addingBookmark {
    return [settings boolForKey:@"addingBookmark"];
}

-(void)setAddingBookmark:(BOOL)value {
    [settings setBool:value forKey:@"addingBookmark"];
    [settings synchronize];
}

-(void)becomeActive {
   // NSLog(@"become active");
   // [self updateTrackingAreas];
}

- (void)updateTrackingAreas
{
    [self removeTrackingArea:trackingArea];
    [self createTrackingArea];
    [super updateTrackingAreas];
}

@end

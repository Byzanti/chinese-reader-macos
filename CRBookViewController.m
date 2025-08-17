//
//  CRBookViewController.m
//  Chinese Reader
//
//  Created by Peter on 20/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRBookViewController.h"


@implementation CRBookViewController

@synthesize leftColumnTextView;
@synthesize rightColumnTextView;

@synthesize bookTextStorage;

@synthesize leftColumnRect;
@synthesize rightColumnRect;

@synthesize bookViewBounds;

@synthesize articleString;
@synthesize articleStringPortion;
@synthesize articleStringLocation;
@synthesize articleStringLength;

-(void)awakeFromNib {
	center = [NSNotificationCenter defaultCenter];
    settings = [NSUserDefaults standardUserDefaults];
    
    //Position of the text in relation to the book image
	[center addObserver:self selector:@selector(updateBookRectPosition:) name:@"UpdateBookRectPosition" object:nil];
    //Place in the text
    [center addObserver:self selector:@selector(updatePlaceInTextFromNotification:) name:@"UpdatePlaceInText" object:nil];
	[center addObserver:self selector:@selector(updateText) name:@"UpdateBookText" object:nil];
	[center addObserver:self selector:@selector(resetTextPosition:) name:@"ResetTextPosition" object:nil];
	[center addObserver:self selector:@selector(goForwards:) name:@"GoForwards" object:nil];
	[center addObserver:self selector:@selector(goBackwards:) name:@"GoBackwards" object:nil];
   // [center addObserver:self selector:@selector(updateBookColourForPreferences:) name:@"UpdateBookColourForPreferences" object:nil];
	
	[self setBookViewBounds:[bookView bounds]];
	[self setBookRect:NSMakeRect(4, 0, 657, 495)];
	
	[self setupTextViews];
    [self updateRectPositions];
    
	[self setArticleStringLocation:0];
    [self updateText];
    [self updatePlaceInText];
}

//Setup
//////////////////////////////////////////////////////////////////
-(void)setupTextViews {
	
	articleString = [[NSMutableAttributedString alloc] init];
	articleStringPortion = [[NSAttributedString alloc] init];
    
	bookTextStorage = [[NSTextStorage alloc] init];
	bookLayoutManager = [[NSLayoutManager alloc] init];
	[[self bookTextStorage] addLayoutManager:bookLayoutManager];
	
	leftColumnRect = NSZeroRect;
	rightColumnRect = NSZeroRect;
	
	NSDivideRect(bookRect, &leftColumnRect, &rightColumnRect, NSWidth(bookRect) / 2, NSMinXEdge);
	
	// First column
    {
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:leftColumnRect.size];
        leftColumnTextView = [[CRMouseOverTextView alloc] initWithFrame:leftColumnRect textContainer:textContainer];
		[leftColumnTextView setDrawsBackground:NO];
		[leftColumnTextView setEditable:NO];
		[leftColumnTextView setup];
		
        [bookView addSubview:leftColumnTextView];
        
        [bookLayoutManager addTextContainer:textContainer];
        
    }
    
    
    // Second column
    {
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:rightColumnRect.size];
        rightColumnTextView = [[CRMouseOverTextView alloc] initWithFrame:rightColumnRect textContainer:textContainer];
		[rightColumnTextView setDrawsBackground:NO];
		[rightColumnTextView setEditable:NO];
		[rightColumnTextView setup];
		
        [bookView addSubview:rightColumnTextView];
        
        [bookLayoutManager addTextContainer:textContainer];
        
    }
    
	
}

-(void)updateBookRectPosition:(NSNotification *)notification {
	[self setBookRect:NSRectFromString([[notification userInfo] objectForKey:@"bookRect"])];
	[self updateRectPositions];
}

-(void)updateRectPositions {
	NSDivideRect(bookRect, &leftColumnRect, &rightColumnRect, NSWidth(bookRect) / 2, NSMinXEdge);
	[leftColumnTextView setFrame:leftColumnRect];
	[[leftColumnTextView textContainer] setContainerSize:NSMakeSize(leftColumnRect.size.width,leftColumnRect.size.height)];
	
	//adds a small left margin
	rightColumnRect = NSMakeRect(rightColumnRect.origin.x + (bookRect.size.width * 0.05),rightColumnRect.origin.y,rightColumnRect.size.width - (bookRect.size.width * 0.05),rightColumnRect.size.height);
	[rightColumnTextView setFrame:rightColumnRect];
	[[rightColumnTextView textContainer] setContainerSize:NSMakeSize(rightColumnRect.size.width ,rightColumnRect.size.height)];
    
}

-(void)setBookRect:(NSRect)rect {
	bookRect = NSMakeRect(rect.origin.x + (rect.size.width * 0.10) /* half of the actual width */, rect.origin.y + (rect.size.height * 0.05) /*similarly*/, rect.size.width * 0.8, rect.size.height *0.9);
	
}

-(NSRect)bookRect {
    return bookRect;
}



//Updating text
//////////////////////////////////////////////////////////////////

-(void)updateText {
    //sets the string
	[self setArticleString:[[articleView textStorage] mutableCopy]];
	[self setArticleStringLength:[articleString length]];

	//updates known item colours
    [articleString addAttribute:NSForegroundColorAttributeName value:[settings colorForKey:@"bookKnownVocabColour"] range:NSMakeRange(0, articleStringLength)];
    
    //updates the unknown item colours
    NSColor *unknownColour = [settings colorForKey:@"bookUnknownVocabColour"];
    [articleString enumerateAttribute:@"Unknown Word" inRange:NSMakeRange(0, articleStringLength) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) { 
        if (value) [articleString addAttribute:NSForegroundColorAttributeName value:unknownColour range:range];
    }];
    
    //updates the bookmark colours   
    NSColor *bookmarkColour = [settings colorForKey:@"bookBookmarkColour"];
    [articleString enumerateAttribute:@"bookmark" inRange:NSMakeRange(0, articleStringLength) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) { 
        if (value) [articleString addAttribute:NSBackgroundColorAttributeName value:bookmarkColour range:range];
    }];
    
    [[self bookTextStorage] setAttributedString:articleString];
}

-(void)updatePlaceInText {
    //sets the portion
	[self setArticleStringPortion:[[self articleString] attributedSubstringFromRange:NSMakeRange(articleStringLocation, articleStringLength - articleStringLocation)]];
	[[self bookTextStorage] setAttributedString:articleStringPortion];
    
    //does this so there isn't any weirdness going on
    [leftColumnTextView setNeedsDisplay:YES];
    [rightColumnTextView setNeedsDisplay:YES];
    
    [self updatePositionLabel];
}

-(void)updatePlaceInTextFromNotification:(NSNotification *)notification {
    [self setArticleStringLocation:[[[notification userInfo] objectForKey:@"place"] intValue]];
    [self updatePlaceInText];
}


-(void)resetTextPosition:(NSNotification *)notification {
	[self setArticleStringLocation:0];
	[self updatePositionLabel];
}

-(IBAction)goForwards:(id)sender {
	[center postNotificationName:@"KillPopup" object:self];
	
	//Gets the new location for then next bit of text, and saves the place
	NSRange rightRange = [self getViewableRange:rightColumnTextView];
	int newLocation = [self articleStringLocation] + rightRange.location + rightRange.length;
	
	//if at the end, halts
	if (newLocation == [self articleStringLength]) { NSBeep(); return; }
	
    //If not, sets the new location
	[self setArticleStringLocation:newLocation];
    
    [self updatePlaceInText];
}


-(IBAction)goBackwards:(id)sender {
	[center postNotificationName:@"KillPopup" object:self];
	
	if (articleStringLocation == 0) { NSBeep(); return; }
	articleStringLocation--; //minus one, so the last character of the last page is the new location, not the first one of the present page
	
	[bookTextStorage beginEditing];
	
	//Fills the area with text, to see how many characters you can fit in
	NSMutableString *string = [[NSMutableString alloc] init];
	for (int i = 0; i < 30; i++) {
		[string appendString:@"............................................................................................................................................................................................................................................................................................................................................"];
	}
	
	//Add attributes to make the string fit the current font
	NSAttributedString *atString = [[NSAttributedString alloc] initWithString:string attributes:[bookTextStorage attributesAtIndex:1 effectiveRange:NULL]];
	[bookTextStorage setAttributedString:atString];
	
	//Gets the max length possible for the viewable area
	[bookTextStorage endEditing];
	NSRange rightRange = [self getViewableRange:rightColumnTextView];
	[bookTextStorage beginEditing];
	
	int length = rightRange.location + rightRange.length -1;	
	
	//If I simply go back by this length, then it will likely be too much. The initial string will include whitespace this doesn't account for.
	//Creates a substring based on the max possible length
	
	//Gets the starting point of the string
	int startingPoint = articleStringLocation - length;
	if (startingPoint < 0) { 
		startingPoint = 0;
		length = articleStringLocation;
	}
	
	//Creating the substring, with numbers at attributes, with number 0 being the final character in the string.
	NSRange subStringRange = NSMakeRange(startingPoint,length);
	NSMutableAttributedString *subStringWithStop = [[NSMutableAttributedString alloc] initWithAttributedString:[articleString attributedSubstringFromRange:subStringRange]];

	NSString *value;
	for (int i = 0; i < length; i++) {
		value = [NSString stringWithFormat:@"%i",i];
		[subStringWithStop addAttribute:@"Stop!" value:value range:NSMakeRange(length -1 -i, 1)];
	}

	int i;
	int place;
	NSRange leftRange;
	for (i = 0; i < length; i++) {

		subStringRange = NSMakeRange(i,length - i);
		[bookTextStorage setAttributedString:[subStringWithStop attributedSubstringFromRange:subStringRange]];
		
		[bookTextStorage endEditing];
		if (i == 0) leftRange = [self getViewableRange:leftColumnTextView];
		rightRange = [self getViewableRange:rightColumnTextView];
		[bookTextStorage beginEditing];
		
		//first loop checks to see if the all the string is already visible
		if (i == 0 && leftRange.length + rightRange.length == length) break;
		
		place = [[bookTextStorage attribute:@"Stop!" atIndex:(rightRange.location + rightRange.length -1) effectiveRange:NULL] intValue];
		
		//breaks if it's at the end
		if (place == 0) break;
		
		//this skips the majority of the loops, and just checks the part of the string that needs checked
		if (place > 30) i = i + place -30;
	}
    
    [bookTextStorage endEditing];

	//Gets the new location
	articleStringLocation = articleStringLocation - length + i;
	if (articleStringLocation < 0) articleStringLocation = 0;
	
    [self updatePlaceInText];
	
}

-(void)updatePositionLabel {
	float percentage = ((float)articleStringLocation / (float)articleStringLength) * 100;
	if (articleStringLocation == 0) percentage = 0.0;
	[bookPositionLabel setStringValue:[NSString stringWithFormat:@"%i%%",(int)percentage]];
}


-(NSRange)getViewableRange:(NSTextView *)tv {
	NSLayoutManager *lm = [tv layoutManager];
	NSRect visRect = [tv visibleRect];
	
	NSPoint tco = [tv textContainerOrigin];
	visRect.origin.x -= tco.x;
	visRect.origin.y -= tco.y;
	
	NSRange glyphRange = [lm glyphRangeForBoundingRect:visRect inTextContainer:[tv textContainer]];
	NSRange charRange = [lm characterRangeForGlyphRange:glyphRange actualGlyphRange:nil];
	
	return charRange;
}




@end

//
//  CRPopup.m
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRPopup.h"
#import "NS(Attributed)String+Geometrics.h"


@implementation CRPopup

@synthesize itemName;
@synthesize knownItem;
@synthesize definition;
@synthesize pinyin;

@synthesize fontLineHeight;
@synthesize glyphRect;

@synthesize popupFont;
@synthesize popupDefinitionFont;

@synthesize startingPoint;

@synthesize itemAttributes;
@synthesize pinyinAttributes;
@synthesize definitionAttributes;

@synthesize knowButton;
@synthesize skritterButton;

@synthesize border;

@synthesize showButtons;
@synthesize showingPopup;
@synthesize mouseOverPopup;
@synthesize editorColours;

//init

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		settings = [NSUserDefaults standardUserDefaults];
		center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(displayPopupForNotification:) name:@"GiveMeAPopup" object:nil];
		[center addObserver:self selector:@selector(cursorNotOverItem:) name:@"No item" object:nil];
		[center addObserver:self selector:@selector(updateBounds:) name:@"Resized" object:nil];
		[center addObserver:self selector:@selector(killPopup:) name:@"KillPopup" object:nil];
		[center addObserver:self selector:@selector(loadSettings:) name:@"LoadSettings" object:nil];
		[center addObserver:self selector:@selector(inEditor:) name:@"InEditor" object:nil];
		[center addObserver:self selector:@selector(inBook:) name:@"InBook" object:nil];
		[self setShowingPopup:YES];
		[self setMouseOverPopup:NO];
		[self setEditorColours:YES];
		[self setBounds:frame];
    }
    return self;
}

-(void)loadSettings:(NSNotification *)notification {
}

-(void)displayPopupForNotification:(NSNotification *)notification {
	if ([self mouseOverPopupOrWord]) return;
	//if ([self showingPopup]) [self showPopup:NO];
    [self showPopup:NO];
		
    //Fetching info for new popup
    popupInputDictionary = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    
    [self setPopupFont:[popupInputDictionary objectForKey:@"currentFont"]];
    [self setStartingPoint:NSPointFromString([popupInputDictionary objectForKey:@"currentPoint"])];
    [self setItemName:[popupInputDictionary objectForKey:@"itemName"]];
    [self setPinyin:[popupInputDictionary objectForKey:@"itemPinyin"]];
    [self setDefinition:[popupInputDictionary objectForKey:@"itemDefinition"]];
    [self setKnownItem:[popupInputDictionary objectForKey:@"Known item?"]];
    [self setShowButtons:[[popupInputDictionary objectForKey:@"Buttons?"] boolValue]];
    [self setFontLineHeight:[[popupInputDictionary objectForKey:@"fontLineHeight"] floatValue]];
    [self setGlyphRect:NSRectFromString([popupInputDictionary objectForKey:@"glyphRect"])];        
		
    //Setting the popup up, then showing it
    [self setupPopup];
    [self showPopup:YES];
}

//showing popup

-(void)showPopup:(BOOL)yesOrNo {
	
	if (yesOrNo && ![self showingPopup]) {
		[self setShowingPopup:YES];
		[self setMouseOverPopup:NO];
		[self setNeedsDisplay:YES];
        [self setWantsLayer:YES];
		[self display];
		[self setHidden:NO];
	}
	
	else if (!yesOrNo && [self showingPopup]) {
		[self setNeedsDisplay:NO];
		[self setHidden:YES];
		[self removePopupStuff];
		[self setShowingPopup:NO];
		[self setMouseOverPopup:NO];
        [self setWantsLayer:NO];
        [timer invalidate];
	}
}

-(void)cursorNotOverItem:(NSNotification *)notification {
	if (![self mouseOverPopupOrWord]) [self showPopup:NO];
}

-(BOOL)mouseOverPopupOrWord {
    NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint:mouseLocation fromView:nil];
    if (NSPointInRect(mouseLocation, glyphRect) || NSPointInRect(mouseLocation, totalRect)) return YES;
    else return NO;
}

-(void)killPopup:(NSNotification *)notification {
	[self showPopup:NO];
	[[NSCursor IBeamCursor] set];
}

//Other stuff

-(void)updateBounds:(NSNotification *)notification {
	[self setFrame:[[self superview] bounds]];
}

- (IBAction)knowButtonClicked:(id)sender {
    [CRAddWords addWordToKnownWords:itemName];
	[self showPopup:NO];
}

- (IBAction)skritterButtonClicked:(id)sender {
    [CRAddWords addWordToSkritter:itemName withPinyin:pinyin withDefinition:definition];
    
    if ([settings boolForKey:@"addToSkritterAddsToKnownItems"]) [self knowButtonClicked:self];
}


//Setup stuff
////////////////////////////////////////////////////

-(void)setupPopup {
	
	[self setupCurrentFont];
	[self setupAttributes];
	[self setupRectSize];
	[self setupTextViews];
	if (showButtons) [self setupButtons];
	[self setHidden:YES];
}


-(void)setupCurrentFont {
	NSFont *font = [self popupFont];
	CGFloat fontSize = [font pointSize];
	NSString *fontName = [font fontName];
	
    /* //Original -- revised as long definitions went off the page
	[self setPopupFont:[NSFont fontWithName:fontName size:fontSize * 1.5]];
	[self setPopupDefinitionFont:[NSFont fontWithName:fontName size:fontSize * 0.75]];
     */
    
    //Max font size for popups
    if (fontSize > 30) fontSize = 30;
    
    //Set the main popup font size
    [self setPopupFont:[NSFont fontWithName:fontName size:fontSize * 1.5]];
    
    //Set the definition font size. Make allowances for long definitions.

    CGFloat lengthModifier = 1;
    CGFloat definitionLength = [definition length];
    //If the definition is too long for the popup, cut it off after 300 characters
    if (definitionLength > 300) [self setDefinition:[[[self definition] substringToIndex:300] stringByAppendingString:@"..."]];
    
    //If the definition is over X characters, scale it down
    if (definitionLength > 100) lengthModifier = 0.90;
    if (definitionLength > 150) lengthModifier = 0.85;
    if (definitionLength > 200) lengthModifier = 0.80;
    if (definitionLength > 250) lengthModifier = 0.75;
    
    CGFloat revFontSize = fontSize * 0.75 * lengthModifier;
    [self setPopupDefinitionFont:[NSFont fontWithName:fontName size:revFontSize]];
    //NSLog(@"%f",lengthModifier);
}

-(void)setupAttributes {
	
	[self setItemAttributes:[NSMutableDictionary dictionaryWithObjectsAndKeys:[settings colorForKey:@"popupCharactersColour"],NSForegroundColorAttributeName,popupFont,NSFontAttributeName,nil]];
	
	[self setPinyinAttributes:[NSMutableDictionary dictionaryWithObjectsAndKeys:[settings colorForKey:@"popupPinyinColour"],NSForegroundColorAttributeName,popupDefinitionFont,NSFontAttributeName,nil]];
	
	[self setDefinitionAttributes:[NSMutableDictionary dictionaryWithObjectsAndKeys:[settings colorForKey:@"popupDefinitionColour"],NSForegroundColorAttributeName,popupDefinitionFont,NSFontAttributeName,nil]];

}


-(void)setupRectSize {
	
	//Choose border thickness
	[self setBorder:6];
	int fullborder = [self border] * 2;
	
    
    //Set default width of popup
    CGFloat defaultWidthModifier = 16;
    
    //If a long definition, make adjustments
    CGFloat definitionLength = [definition length];
    CGFloat definitionLengthModifier = 1;
    if (definitionLength > 150) definitionLengthModifier = definitionLength/150;
    if (definitionLengthModifier > 1.75) definitionLengthModifier = 1.75;
    //NSLog(@"%f",definitionLengthModifier);
    
	CGFloat defaultWidth = [popupDefinitionFont pointSize] * defaultWidthModifier * definitionLengthModifier;
	//Bases size on item & definition size
	
	itemSize = [itemName sizeForWidth:FLT_MAX height:FLT_MAX attributes:itemAttributes];
	itemSize.height = itemSize.height + 2;
	if (itemSize.width > defaultWidth) defaultWidth = itemSize.width;
	
	pinyinSize = [pinyin sizeForWidth:FLT_MAX height:FLT_MAX attributes:pinyinAttributes];
	pinyinSize.height = pinyinSize.height + 2;
	if (pinyinSize.width > defaultWidth) defaultWidth = pinyinSize.width;
	
	definitionSize = [definition sizeForWidth:defaultWidth height:FLT_MAX attributes:definitionAttributes];
	definitionSize.height = definitionSize.height +2;
	
	buttonSize.width = defaultWidth;
		
	//only showsbuttons if need be
	if ([self showButtons]) buttonSize.height = 42;
	else buttonSize.height = 0;
	
	totalSize.width = defaultWidth + fullborder;
	totalSize.height = itemSize.height + pinyinSize.height + definitionSize.height + buttonSize.height + fullborder;
	
	//Makes sure it doesn't go off the page
	if (startingPoint.x + totalSize.width > [self bounds].origin.x + [self bounds].size.width -10) {
		startingPoint.x = [self bounds].size.width - totalSize.width - 18;	
	}
	
	if (startingPoint.y - totalSize.height < 16) {
		startingPoint.y = startingPoint.y + totalSize.height + fontLineHeight;
	}
	
	totalRect = NSMakeRect(startingPoint.x,startingPoint.y - totalSize.height, totalSize.width, totalSize.height);
	
}

-(void)setupTextViews {
	
	NSColor *currentColor;
	if (editorColours) currentColor = [settings colorForKey:@"popupBackgroundEditorColour"];
	else currentColor = [settings colorForKey:@"popupBackgroundBookColour"];
	
	NSRect frame;
	
	//item
	frame = NSMakeRect(startingPoint.x + border, startingPoint.y - border - itemSize.height, itemSize.width, itemSize.height);
	itemTextView = [[NSTextView alloc] initWithFrame:frame];
	NSAttributedString *itemAttributedString = [[NSAttributedString alloc] initWithString:itemName attributes:itemAttributes];
	[[itemTextView textStorage] setAttributedString:itemAttributedString];
	[itemTextView setEditable:NO];
	[itemTextView setBackgroundColor:currentColor];
	[self addSubview:itemTextView];
	
	//pinyin
	frame = NSMakeRect(startingPoint.x + border, startingPoint.y - border - itemSize.height - pinyinSize.height, pinyinSize.width, pinyinSize.height);
	pinyinTextView = [[NSTextView alloc] initWithFrame:frame];
	NSAttributedString *pinyinAttributedString = [[NSAttributedString alloc] initWithString:pinyin attributes:pinyinAttributes];
	[[pinyinTextView textStorage] setAttributedString:pinyinAttributedString];
	[pinyinTextView setEditable:NO];
	[pinyinTextView setBackgroundColor:currentColor];
	[self addSubview:pinyinTextView];
	
	//definition
	frame = NSMakeRect(startingPoint.x + border, startingPoint.y - border - itemSize.height - pinyinSize.height - definitionSize.height, definitionSize.width, definitionSize.height);
	definitionTextView = [[NSTextView alloc] initWithFrame:frame];
	NSAttributedString *definitionAttributedString = [[NSAttributedString alloc] initWithString:definition attributes:definitionAttributes];
	[[definitionTextView textStorage] setAttributedString:definitionAttributedString];
	[definitionTextView setEditable:NO];
	[definitionTextView setBackgroundColor:currentColor];
	[self addSubview:definitionTextView];
	
}

-(void)setupButtons {
	
	NSRect frame = NSMakeRect(startingPoint.x + border*3, startingPoint.y - totalSize.height + border + 22, totalSize.width - border *6, 20);
    knowButton = [[NSButton alloc] initWithFrame:frame];
    [knowButton setBezelStyle:NSSmallSquareBezelStyle];
	[knowButton setTitle:@"I know this word"];
    [self addSubview: knowButton];
    
    [knowButton setTarget:self];
    [knowButton setAction:@selector(knowButtonClicked:)];
	
	frame = NSMakeRect(startingPoint.x + border*3, startingPoint.y - totalSize.height + border, totalSize.width - border *6, 20);
    skritterButton = [[NSButton alloc] initWithFrame:frame];
    [skritterButton setBezelStyle:NSSmallSquareBezelStyle];
	[skritterButton setTitle:@"Add to Skritter"];
    [self addSubview: skritterButton];
    
    [skritterButton setTarget:self];
    [skritterButton setAction:@selector(skritterButtonClicked:)];
	
}

-(void)removePopupStuff {
	
	if ([self showButtons]) { 
		[knowButton removeFromSuperview];
		[skritterButton removeFromSuperview];
	}
	
	[itemTextView removeFromSuperview];
	[pinyinTextView removeFromSuperview];
	[definitionTextView removeFromSuperview];
	
    totalRect = NSMakeRect(0, 0, 0, 0);
    glyphRect = NSMakeRect(0, 0, 0, 0);
	
}

-(void)inEditor:(NSNotification *)notification {
	[self setEditorColours:YES];
	
}

-(void)inBook:(NSNotification *)notification {
	[self setEditorColours:NO];
	
}

//Drawing related stuff
////////////////////////////////////////////////////


- (void)drawRect:(NSRect)rect {
	
	NSColor *currentColor;
	currentColor = [settings colorForKey:@"popupBorderColour"];
	[currentColor set];
	
	NSRectFill(totalRect);
	
	if (editorColours) currentColor = [settings colorForKey:@"popupBackgroundEditorColour"];
	else currentColor = [settings colorForKey:@"popupBackgroundBookColour"];
	[currentColor set];
	
	//Interior
	NSRect totalRectInterior = NSMakeRect(startingPoint.x + border -2 ,startingPoint.y - totalSize.height + border -2, totalSize.width - (border *2) +4, totalSize.height - (border *2) +4);
	NSRectFill(totalRectInterior);
    
}




@end

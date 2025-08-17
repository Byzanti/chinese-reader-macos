//
//  CRBrains.m
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRBrains.h"
#import "CRSkritterParser.h"
#import "CRArticleParser.h"

@implementation CRBrains

static CRBrains *shared;

@synthesize storageDirectory;
@synthesize skritCharacterArrayFileLocation;
@synthesize skritWordArrayFileLocation;
@synthesize skritcedictDictionaryFileLocation;
@synthesize knownItemsArrayFileLocation;
@synthesize cccedictFileLocation;
@synthesize savedIndexFileLocation;

@synthesize skritData;
@synthesize settingsData;
@synthesize savedData;
@synthesize knownItemsData;
@synthesize newKnownItems;

@synthesize newStuffCount;

@synthesize skritWordArray;
@synthesize skritCharacterArray;

@synthesize textVocabDictPlusRanges;
@synthesize summaryArray;
@synthesize knownItemsArray;

//Initialisation
/////////////////////////////////////////////////////////////////////////
-(id) init {
	if (shared) {
        return shared;
    }
    if (![super init]) return nil;
    
	settings = [NSUserDefaults standardUserDefaults];
    dictionary = [[CRDictionary alloc] init];
	
	queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];
	
	//sets up storage directories
	[self setStorageDirectory:[NSString stringWithString:NSHomeDirectory()]];
	[self setStorageDirectory:[storageDirectory stringByAppendingString:@"/Library/Application Support/Chinese Reader"]];
	
	[self setSkritCharacterArrayFileLocation:[storageDirectory stringByAppendingString:@"/CharactersYouKnow.plist"]];
	[self setSkritWordArrayFileLocation:[storageDirectory stringByAppendingString:@"/WordsYouKnow.plist"]];
	[self setSkritcedictDictionaryFileLocation:[storageDirectory stringByAppendingString:@"/CombinedDictionary.plist"]];
	[self setKnownItemsArrayFileLocation:[storageDirectory stringByAppendingString:@"/NonSkritterKnownItems.plist"]];
    [self setCccedictFileLocation:[storageDirectory stringByAppendingFormat:@"/cc-cedict.plist"]];
	[self setSavedIndexFileLocation:[storageDirectory stringByAppendingFormat:@"/savedIndex.plist"]];
    
    
	//checks to see if files exist
	fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:[self skritCharacterArrayFileLocation]] && [fileManager fileExistsAtPath:[self skritWordArrayFileLocation]] && [fileManager fileExistsAtPath:[self skritcedictDictionaryFileLocation]] && [fileManager fileExistsAtPath:[self cccedictFileLocation]]) [self setSkritData:YES];
	else [self setSkritData:NO];
	if ([fileManager fileExistsAtPath:[self knownItemsArrayFileLocation]]) [self setKnownItemsData:YES];
	else [self setKnownItemsData:NO];
	if ([settings boolForKey:@"settingsExist"]) [self setSettingsData:YES];
    if ([fileManager fileExistsAtPath:[self savedIndexFileLocation]]) [self setSavedData:YES];
    else [self setSavedData:NO];
    
	center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(appWillTerminate:) name:@"WillTerminate" object:nil];
	[center addObserver:self selector:@selector(sendKnownItemsDictForPreferences:) name:@"WantKnownItemsDictForPreferences" object:nil];
	[center addObserver:self selector:@selector(removeKnownItem:) name:@"RemoveKnownItem" object:nil];
	[center addObserver:self selector:@selector(addKnownItemsFromArray:) name:@"AddKnownItemsFromArray" object:nil];
	[center addObserver:self selector:@selector(resetSettingsToDefaults:) name:@"ResetSettingsToDefaults" object:nil];
    
    //Loads frequency info
    frequency = [[CRFrequency alloc] initWithStorageDirectory:storageDirectory];
    [frequency setup];
    
    //Loads the CRSimpTradConverter
    simpTradConversion = [[CRSimpTradConversion alloc] initWithStorageDirectory:storageDirectory];
    [simpTradConversion setup];
    
	shared = self;
	return self;
}

-(void)startup {
	[self loadData];
	[self loadSettings];
    [self loadSavedIndex];
}

+(id)shared {
    return shared;
}


//Settings & Data
/////////////////////////////////////////////////////////////////////////

-(void)loadData {
	if ([self knownItemsData]) [self setKnownItemsArray:[NSMutableArray arrayWithContentsOfFile:[self knownItemsArrayFileLocation]]];
	else {
		[self setKnownItemsArray:[NSMutableArray array]];
		[[self knownItemsArray] writeToFile:knownItemsArrayFileLocation atomically:YES];
		[self setKnownItemsData:YES];
	}
	
	//This checks to see if there are any new items the user has chosen to ignore, so it remembers them on quit
	[self setNewKnownItems:NO];
    
    if ([self skritData]) {
		[self setSkritCharacterArray:[NSMutableArray arrayWithContentsOfFile:[self skritCharacterArrayFileLocation]]];
		[self setSkritWordArray:[NSMutableArray arrayWithContentsOfFile:[self skritWordArrayFileLocation]]];
        [dictionary setDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:[self skritcedictDictionaryFileLocation]]];
        [self reloadSharedDict];
        
		
	}
	else {
		[fileManager createDirectoryAtPath:[self storageDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];
        
        //Unzips the cc-cedict dictionary
        NSString *ccedictPath = [[NSBundle mainBundle] pathForResource:@"cc-cedict" ofType:@"zip"];
        [SSZipArchive unzipFileAtPath:ccedictPath toDestination:storageDirectory delegate:self];
	}
    
}

-(void)loadSettings {
	//if settings don't exist, writes the defaults
	if (![self settingsData]) {

        [settings setBool:YES forKey:@"firstTime"];
        [settings setFloat:0.2 forKey:@"version"];
        
        [settings setObject:storageDirectory forKey:@"storageDirectory"];
        [settings setObject:[storageDirectory stringByAppendingString:@"/saved"] forKey:@"savedDirectory"];
        [settings setObject:savedIndexFileLocation forKey:@"savedIndexFileLocation"];
		[settings setBool:YES forKey:@"settingsExist"];
		[settings setFloat:20.0 forKey:@"fontSize"];
		[settings setObject:@"STHeitiSC-Light" forKey:@"fontName"];
		[settings setFloat:5.0 forKey:@"lineSpace"];
		[settings setFloat:12.0 forKey:@"margin"];
		[settings setBool:YES forKey:@"popupForAllWords"];
		[settings setBool:YES forKey:@"useWithSkritter"];
		
		[settings setColor:[NSColor blackColor] forKey:@"editorKnownVocabColour"];
		[settings setColor:[NSColor grayColor] forKey:@"editorUnknownVocabColour"];
		[settings setColor:[NSColor whiteColor] forKey:@"editorBackgroundColour"];
        [settings setColor:[NSColor blackColor] forKey:@"bookKnownVocabColour"];
        [settings setColor:[NSColor grayColor] forKey:@"bookUnknownVocabColour"];
		[settings setColor:[NSColor blackColor] forKey:@"popupCharactersColour"];
		[settings setColor:[NSColor blackColor] forKey:@"popupPinyinColour"];
		[settings setColor:[NSColor blackColor] forKey:@"popupDefinitionColour"];
		[settings setColor:[NSColor whiteColor] forKey:@"popupBackgroundEditorColour"];
		[settings setColor:[NSColor colorWithDeviceRed:1.0	green:0.969 blue:0.953 alpha:1.0] forKey:@"popupBackgroundBookColour"];
		[settings setColor:[NSColor colorWithDeviceRed:0.792 green:0.854 blue:0.956 alpha:1.0] forKey:@"popupBorderColour"];
		
		[settings synchronize];
	}
    
    //extra stuff added for 0.2
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.2 || ![self settingsData]) {
        [settings setFloat:0.2 forKey:@"version"];
        [settings setObject:[storageDirectory stringByAppendingString:@"/saved"] forKey:@"savedDirectory"];
        [settings setObject:savedIndexFileLocation forKey:@"savedIndexFileLocation"];
        [settings setObject:nil forKey:@"currentDocument"];
        [settings setObject:@"creation" forKey:@"saveLoadStyle"]; //This or @"lastViewed"
        [settings setBool:NO forKey:@"loadLastViewed"];
        [settings setBool:NO forKey:@"addToSkritterAddsToKnownItems"];
        [settings setBool:NO forKey:@"checkedText"];
        
        [settings synchronize];
    }
    
    
    //0.2.5
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.25 || ![self settingsData]) { 
        [settings setFloat:0.25 forKey:@"version"];
        [settings setColor:[NSColor orangeColor] forKey:@"editorBookmarkColour"];
        [settings setColor:[NSColor orangeColor] forKey:@"bookBookmarkColour"];
        [settings setObject:@"book" forKey:@"currentArea"];
    }
    
    
    //0.3
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.3 || ![self settingsData]) {
        [settings setFloat:0.3 forKey:@"version"];
        
        if (![settings boolForKey:@"firstTime"]) {
            if ([settings boolForKey:@"useWithSkritter"] == NO) [self setSkritData:NO]; //So non-Skritter users get the new dictionary
            NSString *ccedictPath = [[NSBundle mainBundle] pathForResource:@"cc-cedict" ofType:@"zip"];
            [SSZipArchive unzipFileAtPath:ccedictPath toDestination:storageDirectory delegate:self];
            
        }
    }
    
    //0.3.5
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.35 || ![self settingsData]) {
        [settings setFloat:0.35 forKey:@"version"];            
        }
    
    //0.3.6
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.36 || ![self settingsData]) {
        [settings setFloat:0.36 forKey:@"version"];
    }
    
    //0.3.7 
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.37 || ![self settingsData]) {
        [settings setFloat:0.37 forKey:@"version"];
    }
    
    //0.3.8
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.38 || ![self settingsData]) {
        [settings setFloat:0.38 forKey:@"version"];
    }
    
    //0.4
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.4 || ![self settingsData]) {
        [settings setFloat:0.4 forKey:@"version"];
    }
    
    //0.45
    if (![settings floatForKey:@"version"] || [settings floatForKey:@"version"] < 0.45 || ![self settingsData]) {
        [settings setFloat:0.45 forKey:@"version"];
    }
    
    //These should be reset each time the app is started:
    [settings setBool:NO forKey:@"addingBookmark"];
    [settings setBool:NO forKey:@"textChanged"];
    
    //Once summary work has been done, make sure this updates fine
    [settings setBool:NO forKey:@"checkedText"];
    
	[self loadSettingsNotification];
}

-(void)loadSavedIndex {

    if (!savedData) {
        [fileManager createDirectoryAtPath:[settings objectForKey:@"savedDirectory"] withIntermediateDirectories:YES attributes:nil error:NULL];
        NSDictionary *savedIndexDict = [NSDictionary dictionary];
        [savedIndexDict writeToFile:[self savedIndexFileLocation] atomically:YES];
    }
    
}

-(void)rememberData {
	if ([self newKnownItems]) {
		[[self knownItemsArray] writeToFile:knownItemsArrayFileLocation atomically:YES];
		[[self skritWordArray] writeToFile:skritWordArrayFileLocation atomically:YES];
		[[self skritCharacterArray] writeToFile:skritCharacterArrayFileLocation atomically:YES];
        [[dictionary dictionary] writeToFile:skritcedictDictionaryFileLocation atomically:YES];
	}
	
}

-(void)resetSettingsToDefaults:(NSNotification *)notification {
	[self setSettingsData:NO];
	[self loadSettings];
}

-(void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    //This happens on the first run (or when the settings file is deleted, which appears to be a first run), or when there's an update to CC-CEDICT
    //When there's an update, Skritter users will have to reuse the Skritter Parser. For non-Skritter users, it is automatic.
    if (!skritData) {
        [dictionary setDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:cccedictFileLocation]];
        skritCharacterArray = [NSMutableArray array];
        skritWordArray = [NSMutableArray array];
    }
    
    [self setSkritData:YES]; //Basic data gets added below for first time users.
    
    //In case of an update to CC-CEDICT, users do not go past this point
    if (![settings boolForKey:@"firstTime"]) return;
    
    //In case known words exists, adds these words
    [knownItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addItemToWordAndCharacterArray:obj];
    }];
    
    [[dictionary dictionary] writeToFile:skritcedictDictionaryFileLocation atomically:YES];
    [[self skritCharacterArray] writeToFile:skritCharacterArrayFileLocation atomically:YES];
    [[self skritWordArray] writeToFile:skritWordArrayFileLocation atomically:YES];
 
}

-(void)reloadSharedDict {
    [center postNotificationName:@"LoadDictionary" object:self];
}

//Housekeeping
////////////////////////////////////////////////////////////////////////

-(void)addKnownItemsFromArray:(NSNotification *)notification {
	NSMutableArray *array = [[notification userInfo] objectForKey:@"array"];
	
	for (int i = 0; i < [array count]; i++) {
	
		[self addKnownItem:[array objectAtIndex:i]];
		
	}
	
	[center postNotificationName:@"KnownItemsFromArrayAdded" object:self];
	
}

-(void)addKnownItem:(NSString *)knownItem {
	
	if (![knownItemsArray containsObject:knownItem] && [dictionary itemInDictionary:knownItem]) {
	
	[self setNewKnownItems:YES];
	[knownItemsArray addObject:knownItem];
	[self addItemToWordAndCharacterArray:knownItem];	
	
	}
}

-(void)addKnownItemWithOverride:(NSString *)knownItem {
    //Overrides dictionary check
    //Used for CMD-G shortcut only to add selected items in the text.
    if (![knownItemsArray containsObject:knownItem]) {
        
        [self setNewKnownItems:YES];
        [knownItemsArray addObject:knownItem];
        [self addItemToWordAndCharacterArray:knownItem];
        
        //When using override we also need to add the word to the dictionary (CRDictionary), as
        //addItemToWordAndCharacterArray just records the words that are known, but it expects all words to
        //already exist in the ccedict dictionary, or have been imported into the skritcedict dictionary
        if(![[dictionary dictionary] objectForKey:knownItem]) {
            NSMutableDictionary *tempDict = [dictionary dictionary];
            [tempDict setObject:[NSArray array] forKey:knownItem]; //blank item being added
            [dictionary setDictionary:tempDict];
            [self reloadSharedDict];

        }
        
    }
}

-(void)sendKnownItemsDictForPreferences:(NSNotification *)notification {
	NSMutableArray *knownItemsArrayWithPinyinAndDefinitions = [NSMutableArray array];
	
	for (int i = 0; i < [knownItemsArray count]; i++) {
		
		NSString *currentItem = [knownItemsArray objectAtIndex:i];
		
		NSMutableArray *tempArray = [NSMutableArray array];
		[tempArray addObject:currentItem];
		[tempArray addObject:[dictionary pinyinFor:currentItem]];
		[tempArray addObject:[dictionary definitionFor:currentItem]];
		
		[knownItemsArrayWithPinyinAndDefinitions addObject:tempArray];
	}
	
	NSDictionary *knownItemsDict = [NSDictionary dictionaryWithObject:knownItemsArrayWithPinyinAndDefinitions forKey:@"array"];
	[center postNotificationName:@"KnownItemsDictForPreferences" object:self userInfo:knownItemsDict];
}

-(void)removeKnownItem:(NSNotification *)notification {
    NSString *item = [[notification userInfo] objectForKey:@"knownItem"];
	[knownItemsArray removeObject:item];
    [self removeItemFromWordAndCharacterArray:item];
	[self setNewKnownItems:YES];
}

//Notifications to main window
/////////////////////////////////////////////////////////////////////////


-(void)loadSettingsNotification {
	[center postNotificationName:@"LoadSettings" object:self];
}


//Skritter Parser
//////////////////////////////////////////////

-(void)parseSkritterVocab:(NSString *)skritterVocab {
	
	CRSkritterParser *skritParser = [[CRSkritterParser alloc] init];
	[skritParser setSkritterVocab:skritterVocab];
	[skritParser setKnownItemsArray:[self knownItemsArray]];
    [skritParser setCccedictFileLocation:cccedictFileLocation];
	
	[queue addOperation:skritParser];
	
}

-(void)updateSkritterParserView:(NSDictionary *)noteDict {
	[center postNotificationName:@"UpdateSkritterParserView" object:self userInfo:noteDict];
}

-(void)parserDone:(NSArray *)charWordDict {
	//Saves the output into arrays
	[self setSkritCharacterArray:[charWordDict objectAtIndex:0]];
	[self setSkritWordArray:[charWordDict objectAtIndex:1]];
	[dictionary setDictionary:[charWordDict objectAtIndex:2]];
    [self reloadSharedDict];
	

	//Writes to disk, and notify Main Windows whether the it is successful or not
	NSDictionary *done;
	if ([[self skritCharacterArray] writeToFile:skritCharacterArrayFileLocation atomically:YES] && [[self skritWordArray] writeToFile:skritWordArrayFileLocation atomically:YES] && [[dictionary dictionary] writeToFile:skritcedictDictionaryFileLocation atomically:YES]) {
		[self setSkritData:YES];
		done = [NSDictionary dictionaryWithObject:@"YES" forKey:@"doneOK"];
	}
	else done = [NSDictionary dictionaryWithObject:@"NO" forKey:@"doneOK"];

	[center postNotificationName:@"SkritterParserDone" object:self userInfo:done];
}

-(void)parserDoneWithError {
    [center postNotificationName:@"SkritterParserDoneWithError" object:self userInfo:nil];
}

//Article parser
/////////////////////////////////////////////////////////////////////////

-(void)parseArticle:(NSString *)article {

    
    NSMutableArray *knownCharArray = [NSMutableArray array];
    NSMutableArray *knownWordArray = [NSMutableArray array];
    
    //The problem is that known items aren't added to the parser (now fixed)
    //To do this the known items had to be split between words and characters
    //Doing this here is slow; the characters and words should be stored individually when added. Huge optimisation possible here.
    
    [knownItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int len = [obj length];
        if (len == 1) [knownCharArray addObject:obj];
        else [knownWordArray addObject:obj];
    }];

    
    //Combine known words and skritter words
    NSArray *combinedWordArray = [skritWordArray arrayByAddingObjectsFromArray:knownWordArray];
    NSArray *combinedCharArray = [skritCharacterArray arrayByAddingObjectsFromArray:knownCharArray];
    
	CRArticleParser *articleParser = [[CRArticleParser alloc] init];
	[articleParser setArticleString:article];
	[articleParser setSkritCharacterArray:combinedCharArray];
	[articleParser setSkritWordArray:combinedWordArray];
	[articleParser setSkritcedictDictionary:[dictionary dictionary]];
	
	[queue addOperation:articleParser];

}

-(void)articleParsed:(NSArray *)oneDictOneArray {
	
	[self setTextVocabDictPlusRanges:[oneDictOneArray objectAtIndex:0]];

	[self setSummaryArray:[oneDictOneArray objectAtIndex:1]];
	
	[CRStatus setCheckedText:YES];
	[self setNewStuffCount:[textVocabDictPlusRanges count]];
    
    NSString *editorStatusText,*bookStatusText = @"unknown items highlighted";
    NSString *summaryStatusText = @"Some number of items...";
    
    NSDictionary *newStatusDict = [NSDictionary dictionaryWithObjectsAndKeys:editorStatusText,@"Editor",bookStatusText,@"Book",summaryStatusText,@"Summary", nil];
    [center postNotificationName:@"newStatusText" object:self userInfo:newStatusDict];

	[center postNotificationName:@"ArticleParserDone" object:self];
}

//Other parsing
/////////////////////////////////////////////////////////////////////////


-(void)addItemToWordAndCharacterArray:(NSString *)knownItem {
	
	//If it's a character adds it to the character array
	if ([knownItem length] == 1) {
		if (![skritCharacterArray containsObject:knownItem]) [skritCharacterArray addObject:knownItem];
		return;
	}
	
	//If it's a word, adds it to the word array
	if (![skritWordArray containsObject:knownItem]) [skritWordArray addObject:knownItem];
	
	//adds all unique characters to the character array
	for (int i = 0; i > [knownItem length]; i++) {
		
		NSString *knownItemCharacter = [knownItem substringWithRange:NSMakeRange(i, 1)];
		
		if (![skritCharacterArray containsObject:knownItemCharacter]) [skritCharacterArray addObject:knownItemCharacter];
		
	}
}

-(void)removeItemFromWordAndCharacterArray:(NSString *)item {
    if ([skritCharacterArray containsObject:item]) [skritCharacterArray removeObject:item];
    if ([skritWordArray containsObject:item]) [skritWordArray removeObject:item];
}

//Termination
/////////////////////////////////////////////////////////////////////////

-(void)appWillTerminate:(NSNotification *)someNotification {
    
	[settings synchronize];
	[self rememberData];
	
}

@end

//
//  CRBrains.h
//  Chinese Reader
//
//  Created by Peter on 14/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CRSkritterParser.h"
#import "CRArticleParser.h"
#import "NSUserDefaults (MoreTypes).h"
#import "SSZipArchive.h"
#import "CRStatus.h"
#import "CRDictionary.h"
#import "CRSimpTradConversion.h"
#import "CRFrequency.h"

@interface CRBrains : NSObject <SSZipArchiveDelegate> {
	NSNotificationCenter *center;
	NSFileManager *fileManager;
	NSUserDefaults *settings;
    
    CRDictionary *dictionary;
    CRSimpTradConversion *simpTradConversion;
    CRFrequency *frequency;
    
	//Initialisation
    NSString *storageDirectory;
	NSString *skritCharacterArrayFileLocation;
	NSString *skritWordArrayFileLocation;
	NSString *skritcedictDictionaryFileLocation;
	NSString *knownItemsArrayFileLocation;
    NSString *cccedictFileLocation;
    NSString *savedIndexFileLocation;
	
	//Internal
	BOOL skritData;
	BOOL knownItemsData;
    BOOL savedData;
	BOOL newKnownItems;
	BOOL settingsData;
	
	int newStuffCount;
	
	NSOperationQueue *queue;
	
	//Skritter parser
	NSMutableArray *skritWordArray;
	NSMutableArray *skritCharacterArray;

	//Article parser
	NSDictionary *textVocabDictPlusRanges;
	NSArray *summaryArray;
	
	
	NSMutableArray *knownItemsArray;
	
}

@property (strong) NSString *storageDirectory;
@property (strong) NSString *skritCharacterArrayFileLocation;
@property (strong) NSString *skritWordArrayFileLocation;
@property (strong) NSString *skritcedictDictionaryFileLocation;
@property (strong) NSString *knownItemsArrayFileLocation;
@property (strong) NSString *cccedictFileLocation;
@property (strong) NSString *savedIndexFileLocation;

@property (assign) BOOL skritData;
@property (assign) BOOL knownItemsData;
@property (assign) BOOL savedData;
@property (assign) BOOL newKnownItems;
@property (assign) BOOL settingsData;

@property (assign) int newStuffCount;

@property (strong) NSMutableArray *skritWordArray;
@property (strong) NSMutableArray *skritCharacterArray;

@property (strong) NSDictionary *textVocabDictPlusRanges;
@property (strong) NSArray *summaryArray;
@property (strong) NSMutableArray *knownItemsArray;

//Initialisation
-(void)startup;

//Settings & Data
-(void)loadData;
-(void)loadSettings;
-(void)loadSavedIndex;
-(void)rememberData;
-(void)resetSettingsToDefaults:(NSNotification *)notification;
-(void)reloadSharedDict;

//Housekeeping
-(void)addKnownItem:(NSString *)knownItem;
-(void)addKnownItemWithOverride:(NSString *)knownItem; //Used as part of the CMD-G add selected objects to Skritter only
-(void)sendKnownItemsDictForPreferences:(NSNotification *)notification;
-(void)removeKnownItem:(NSNotification *)notification;

//Notifications to main windows
-(void)loadSettingsNotification;

//Skritter Parser
-(void)parseSkritterVocab:(NSString *)skritterVocab;
+(id)shared;
-(void)parserDone:(NSArray *)charWordDict;

//Article Parser
-(void)parseArticle:(NSString *)article;
-(void)articleParsed:(NSArray *)twoArrays;

//Other Parser
-(void)addItemToWordAndCharacterArray:(NSString *)knownItem;
-(void)removeItemFromWordAndCharacterArray:(NSString *)item;

//Termination
-(void)appWillTerminate:(NSNotification *)someNotification;




@end

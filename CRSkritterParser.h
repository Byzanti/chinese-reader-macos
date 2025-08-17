//
//  CRSkritterParser.h
//  Chinese Reader
//
//  Created by Peter on 15/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CRSkritterParser : NSOperation {
	
	NSMutableDictionary *skritcedictDictionary;
	NSMutableDictionary *skritDictionary;
	NSMutableArray *skritWordArray;
	NSMutableArray *skritCharacterArray;
    
    NSString *cccedictFileLocation;
	
	NSArray *knownItemsArray;
	NSString *skritterVocab;
}

@property (strong) NSMutableDictionary *skritcedictDictionary;
@property (strong) NSMutableArray *skritWordArray;
@property (strong) NSMutableArray *skritCharacterArray;
@property (strong) NSMutableDictionary *skritDictionary;

@property (strong) NSString *cccedictFileLocation;

@property (strong) NSArray *knownItemsArray;
@property (strong) NSString *skritterVocab;


-(NSMutableDictionary *)createSkritterDictionaryFromString;
-(NSMutableArray *)arrayOfCharactersOnly:(NSMutableDictionary *)skritdict;
-(NSMutableArray *)arrayOfWordsOnly:(NSMutableDictionary *)skritdict;

-(void)addItemToWordAndCharacterArray:(NSString *)knownItem;
-(NSMutableDictionary *)addSkritDictToCEDICT:(NSMutableDictionary *)skritDict;
-(NSString *)removeURLsFromSkritterDefinitions:(NSString *)def;

-(void)updateSkritterParserView:(NSString *)text;

@end

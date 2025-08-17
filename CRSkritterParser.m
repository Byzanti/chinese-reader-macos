//
//  CRSkritterParser.m
//  Chinese Reader
//
//  Created by Peter on 15/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRSkritterParser.h"
#import "CRBrains.h"


@implementation CRSkritterParser

@synthesize skritcedictDictionary;
@synthesize skritWordArray;
@synthesize skritCharacterArray;
@synthesize skritDictionary;

@synthesize cccedictFileLocation;

@synthesize knownItemsArray;
@synthesize skritterVocab;

-(id)init {
	if (![super init]) return nil;

	skritcedictDictionary = [[NSMutableDictionary alloc] init];
	skritDictionary = [[NSMutableDictionary alloc] init];
	skritWordArray = [[NSMutableArray alloc] init];
	skritCharacterArray = [[NSMutableArray alloc] init];
	
	knownItemsArray = [[NSArray alloc] init];
	skritterVocab = [[NSString alloc] init];
	
	return self;
}

-(void)main {
    
    //This returns a dictionary comprised of your skritter vocab & cc-cedict
    //It also returns two arrays, one of words and one of characters, which is
    //derived one's Skritter words, and additionally 'words you know'.
    //Words you know should be added after the dictionaries are combined,
    //since when updating cc-edict sometimes words are removed.
    //If it is situated before, you get a crash!
    //CRDictionary otherwise returns data for such words, and that is written to not crash. So says the testing.
	
	[self updateSkritterParserView:@"Processing your Skritter vocab...\n"];
    
	//Makes a dictionary of the Skritter vocab
	[self setSkritDictionary:[self createSkritterDictionaryFromString]];
    
    //ERROR CHECKING + EXIT
    if ([skritDictionary objectForKey:@"Error"]) {
        [self updateSkritterParserView:@"\nThere is a problem with the vocab taken from Skritter. "];
        [self updateSkritterParserView:[NSString stringWithFormat:@"It is likely that there is a surplus tab character in the definition for \"%@\".\n\n",[skritDictionary objectForKey:@"Error"]]];
        [self updateSkritterParserView:@"Please edit the definition to remove the extra tab and try again. \n"];
        [self updateSkritterParserView:@"The format is: <word>(tab)<pinyin>(tab)<definition>(tab)(newline) \n\n"];
        [self updateSkritterParserView:@"If this does not resolve the issue, please email your Skritter vocab in an attached .txt file to peter@byzanti.co.uk.\n"];
        
        [[CRBrains shared] performSelectorOnMainThread:@selector(parserDoneWithError) withObject:nil waitUntilDone:YES];
        return;
    }
	
	[self updateSkritterParserView:@"Making a list of all the characters you know...\n"];
	//Makes two arrays with stuff you know
	[self setSkritCharacterArray:[self arrayOfCharactersOnly:skritDictionary]];
	
	[self updateSkritterParserView:@"Making a list of all the words you know...\n"];
	[self setSkritWordArray:[self arrayOfWordsOnly:skritDictionary]];

	//Creates a dictionary combining CEDICT dictionary with any extra words that Skritter has, but it doesn't
	[self setSkritcedictDictionary:[self addSkritDictToCEDICT:skritDictionary]];
    
    //If there are any extra words/characters you don't know, adds them
	int knownItemsArrayCount = [knownItemsArray count];
    
	if (knownItemsArrayCount > 0) {
		[self updateSkritterParserView:@"Restoring known words & characters...\n"];
		
		//Starts at 1 as the first entry is to be ignored
		for (int i = 0; i < knownItemsArrayCount; i++) {
			[self addItemToWordAndCharacterArray:[knownItemsArray objectAtIndex:i]];
		}
	}
	
	[self updateSkritterParserView:@"Saving...\n"];
	
	NSArray *charWordDict = [NSArray arrayWithObjects:[self skritCharacterArray],[self skritWordArray],[self skritcedictDictionary],nil];
	
	[[CRBrains shared] performSelectorOnMainThread:@selector(parserDone:) withObject:charWordDict waitUntilDone:YES];

    return;
}

-(NSMutableDictionary *)createSkritterDictionaryFromString {
    
    NSMutableDictionary *tempSkritDictionary = [NSMutableDictionary dictionary];
    NSArray *vocabArray = [[NSString stringWithFormat:@"\n%@",[skritterVocab copy]] componentsSeparatedByString:@"\t"];

    for (int i = 0; i < [vocabArray count]-1; i = i +3) {
        
        //Set the item (also removes the new line)
        NSString *item = [vocabArray objectAtIndex:i];
        if ([item length] == 0 || [[item substringWithRange:NSMakeRange(0, 1)] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
            NSString *errorItem = [[vocabArray objectAtIndex:i-3] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            [tempSkritDictionary setObject:errorItem forKey:@"Error"];
            return tempSkritDictionary;
        }
        item = [item stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        //Set the pinyin
        NSString *pinyin = [vocabArray objectAtIndex:i+1];
        
        //Set the definition (also removes " from either side)
        NSString *definition = [[vocabArray objectAtIndex:i+2] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
        
        definition = [self removeURLsFromSkritterDefinitions:definition];
        //Adds pinyin & definition to an array, with a blank entry for opposite trad/simp that cc-cedict has, and source
        NSArray *pinyinAndDefinitionArray = [NSArray arrayWithObjects:pinyin,definition,@"",@"skritter",nil];
        
        //Adds to dictionary
        [tempSkritDictionary setObject:pinyinAndDefinitionArray forKey:item];
    }
    
    return tempSkritDictionary;
}

/*
 -(NSMutableDictionary *)createSkritterDictionaryFromString {
 
 NSMutableDictionary *tempSkritDictionary = [NSMutableDictionary dictionary];
 NSArray *arrayOfSkritterVocab = [[[self skritterVocab] copy] componentsSeparatedByString:@"\t"];
 
 NSString *item;
 NSString *pinyin;
 NSString *definition;
 NSArray *pinyinAndDefinitionArray;
 
 for (int i = 0; i < [arrayOfSkritterVocab count]-1; i = i +3) {
 
 //Set the item (also removes the new line)
 item = [[arrayOfSkritterVocab objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
 
 //Set the pinyin
 pinyin = [arrayOfSkritterVocab objectAtIndex:i+1];
 
 //Set the definition (also removes " from either side)
 definition = [[arrayOfSkritterVocab objectAtIndex:i+2] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
 
 definition = [self removeURLsFromSkritterDefinitions:definition];
 //Adds pinyin & definition to an array, with a blank entry for opposite trad/simp that cc-cedict has, and source
 pinyinAndDefinitionArray = [NSArray arrayWithObjects:pinyin,definition,@"",@"skritter",nil];
 
 //Adds to dictionary
 [tempSkritDictionary setObject:pinyinAndDefinitionArray forKey:item];
 }
 
 return tempSkritDictionary;
 }
 */

-(NSMutableArray *)arrayOfCharactersOnly:(NSMutableDictionary *)skritdict {
	
	NSMutableArray *outputArray = [NSMutableArray arrayWithArray:[skritdict allKeys]];
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	NSString *wordBeingSearchedFor;
	
	//Loops through the array of characters and words
	for (int i = 0; i < [outputArray count]; i++) {
		
		//Where it finds a word
		if ([[outputArray objectAtIndex:i] length] > 1) { 
			[tempArray removeAllObjects];
			
			wordBeingSearchedFor = [outputArray objectAtIndex:i];
			
			//puts each character of the current word into an array
			for (int a = 0; a < [wordBeingSearchedFor length]; a++) {
				NSRange range = NSMakeRange(a,1);
				[tempArray addObject:[wordBeingSearchedFor substringWithRange:range]];
			}
			
			//Checks to see if the main array either character from the word, and if it does, removes character from the tempArray
			for (int b = 0; b < [tempArray count]; b++) {
				
				if ([outputArray containsObject:[tempArray objectAtIndex:b]]) {
					[tempArray removeObjectAtIndex:b];
					b--;
				}
				
			}
			
			//then adds any remaining characters to the Skrit list array
			for (int c = 0; c < [tempArray count]; c++) [outputArray insertObject:[tempArray objectAtIndex:c] atIndex:i+1];
			
			//and remove the word
			[outputArray removeObjectAtIndex:i];
			i--;
		}
		
	}
	
	return outputArray;	
}

-(NSMutableArray *)arrayOfWordsOnly:(NSMutableDictionary *)skritdict {
    
    NSMutableArray *array = [NSMutableArray array];
    
    [skritdict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key length] > 1) [array addObject:key];
    }];
	
	return array;
}

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

-(NSMutableDictionary *)addSkritDictToCEDICT:(NSMutableDictionary *)skritDict {
	
	//Loads up the cedict dictionary plist
	[self updateSkritterParserView:@"Loading CC-CEDICT dictionary...\n"];
	NSMutableDictionary *tempSkritcedictDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:cccedictFileLocation];
	
	//See if there are words from Skritter that are also in CC-CEDICT
    //Then, replace CEDICT definitions with Skritter definitions
	[self updateSkritterParserView:@"Replacing CC-CEDICT definitions with Skritter definitions...\n"];
    [skritDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *wordFromSkritterDict = key;
        NSArray *skritterEntry = obj;
        if ([tempSkritcedictDictionary objectForKey:wordFromSkritterDict]) {
            NSString *pinyin = [skritterEntry objectAtIndex:0];
            NSString *definition = [skritterEntry objectAtIndex:1];
            NSString *tradSimp = [[tempSkritcedictDictionary objectForKey:wordFromSkritterDict] objectAtIndex:2];
            NSString *source = @"skritter";
            NSArray *newEntry = [NSArray arrayWithObjects:pinyin,definition,tradSimp,source,nil];
            [tempSkritcedictDictionary setObject:newEntry forKey:wordFromSkritterDict];
        }
        
    }];
    
    //Sees if there are words from Skritter that are missing from the dictionary
	[self updateSkritterParserView:@"Adding extra words from Skritter vocab...\n"];
    [skritWordArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *wordFromSkritterDict = obj;
        if (![tempSkritcedictDictionary objectForKey:wordFromSkritterDict]) {
            NSArray *skritEntry = [skritDict objectForKey:wordFromSkritterDict];
            [tempSkritcedictDictionary setObject:skritEntry forKey:wordFromSkritterDict];
        }
    }];
    
    //Sees if there are any characters from Skritter that are missing from the dictionary
    [self updateSkritterParserView:@"Adding extra characters from Skritter vocab...\n"];
    [skritCharacterArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *charFromSkritterDict = obj;
        if (![tempSkritcedictDictionary objectForKey:charFromSkritterDict]) {
            NSArray *skritEntry = [skritDict objectForKey:charFromSkritterDict];
            [tempSkritcedictDictionary setObject:skritEntry forKey:charFromSkritterDict];
        }
    }];
	
	return tempSkritcedictDictionary;
	
}

-(NSString *)removeURLsFromSkritterDefinitions:(NSString *)def {
	NSString *definition = [NSString stringWithString:def];
	
	if ([definition rangeOfString:@"img:"].location == NSNotFound) return definition;
	
	//If it finds img: splits the string up to bits
	while ([definition rangeOfString:@"img:"].location != NSNotFound) {
		NSArray *splitString = [definition componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString *stringSection = [[NSString alloc] init];
		
		//finds out which bit has the img:
		for (int i = 0; [splitString count]; i++) {
			stringSection = [splitString objectAtIndex:i];
			if ([stringSection rangeOfString:@"img:"].location != NSNotFound) {
				break;
			}
		}
		
		//Deletes it from the string
		definition = [definition stringByReplacingOccurrencesOfString:stringSection withString:@""];
		
	}
	
	return definition;
}

-(void)updateSkritterParserView:(NSString *)text {
	NSDictionary *noteDict = [NSDictionary dictionaryWithObjectsAndKeys:text,@"newText",nil];
	[[CRBrains shared] performSelectorOnMainThread:@selector(updateSkritterParserView:) withObject:noteDict waitUntilDone:NO];
}


@end

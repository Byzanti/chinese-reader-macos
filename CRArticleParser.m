//
//  CRArticleParser.m
//  Chinese Reader
//
//  Created by Peter on 16/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CRArticleParser.h"
#import "CRBrains.h"


@implementation CRArticleParser

@synthesize articleString;
@synthesize skritcedictDictionary;
@synthesize skritWordArray;
@synthesize skritCharacterArray;
@synthesize unknownVocabWithRanges;

-(id)init {
	if (![super init]) return nil;

	articleString = [[NSString alloc] init];
	skritcedictDictionary = [[NSDictionary alloc] init];
	skritWordArray = [[NSArray alloc] init];
	skritCharacterArray = [[NSArray alloc] init];
   

    dictionary = [CRDictionary shared];
		
	return self;
}

-(void)main {
    int positionInArticle = 0;
	int lengthOfArticle = [articleString length];
	int numberOfCharactersToCheck = 6;
	int tempNumberOfCharactersToCheck = 6;
	NSRange subStringRange;
	NSString *checkingString;
	unknownVocabWithRanges = [NSMutableDictionary dictionary];
	NSMutableArray *rangeArray;
	NSCharacterSet *puncSet = [NSCharacterSet characterSetWithCharactersInString:@" \n\t。.，;:；：”’\"'()?<>《》！@£￥%⋯⋯&×（）"];
	
	while (positionInArticle < lengthOfArticle) {
		
	start:
		tempNumberOfCharactersToCheck = 6;
		
		//checks to see if we're about to reach the end of the text
		if (positionInArticle + numberOfCharactersToCheck > lengthOfArticle) tempNumberOfCharactersToCheck = lengthOfArticle - positionInArticle;
		
		//if not, sets the string to look at
		subStringRange = NSMakeRange(positionInArticle, tempNumberOfCharactersToCheck);
		
		checkingString = [articleString substringWithRange:subStringRange];
		
		
		//checks to see if there is a halting punctuation within the next X characters
		for (int i = 0; i < tempNumberOfCharactersToCheck; i++) {
			
			//if there is, makes sure the string just goes up to that point
			if ([checkingString rangeOfCharacterFromSet:puncSet].location != NSNotFound) {
				
				// but skips the next stage if there's nothing to check
				if ([checkingString rangeOfCharacterFromSet:puncSet].location == 0) goto loopend;
				
				tempNumberOfCharactersToCheck = [checkingString rangeOfCharacterFromSet:puncSet].location;
				subStringRange = NSMakeRange(subStringRange.location, tempNumberOfCharactersToCheck);
				break;
			}
		}
		
		checkingString = [articleString substringWithRange:subStringRange];
		
		
		//checks to see if any of the next X characters is a word. Checks for the longest form first.
		for (int i = tempNumberOfCharactersToCheck; i > 0;i--) {
			checkingString = [checkingString substringToIndex:i];
			
            /*if ([skritcedictDictionary objectForKey:checkingString] || [skritWordArray containsObject:checkingString] || [skritCharacterArray containsObject:checkingString] || [[dictionary dictionary ]objectForKey:checkingString]) {*/
            if ([skritcedictDictionary objectForKey:checkingString]) {
				
				BOOL knowThisWord = NO;
				
				//if it is a word or character, checks if it's one we know
				if (i > 1) if ([skritWordArray containsObject:checkingString]) knowThisWord = YES;
				if (i == 1) if ([skritCharacterArray containsObject:checkingString]) knowThisWord = YES;
				
				//if it is not one we know, adds it to the dictionary with the range it's found at
				if (knowThisWord == NO) {
					
                    
					NSRange range = NSMakeRange(positionInArticle, i);
					
					rangeArray = [unknownVocabWithRanges objectForKey:checkingString];
					
					//There's the chance of multiple ranges per item, hence:
					if (rangeArray) [rangeArray addObject:NSStringFromRange(range)];
					else rangeArray = [NSMutableArray arrayWithObject:NSStringFromRange(range)];
                    
					[unknownVocabWithRanges setObject:rangeArray forKey:checkingString];
                    
				}
				
				positionInArticle = positionInArticle + [checkingString length];
				goto start;
			}
		}
		
	loopend:
		
		positionInArticle++;
		
	}
    NSArray *summaryArray = [self addDefinitionsPinyinAndOccurrencesToArray:[unknownVocabWithRanges allKeys]];

	NSArray *oneDictOneArray = [NSArray arrayWithObjects:unknownVocabWithRanges,summaryArray,nil];
	
	[[CRBrains shared] performSelectorOnMainThread:@selector(articleParsed:) withObject:oneDictOneArray waitUntilDone:YES];
    
}


-(NSArray *)addDefinitionsPinyinAndOccurrencesToArray:(NSArray *)array {

    NSMutableArray *arrayWithPinyinAndDefinitions = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *occurrences = [NSNumber numberWithInteger:[[unknownVocabWithRanges objectForKey:obj] count]];
        NSArray *charPinDefArray = [NSArray arrayWithObjects:obj,[dictionary pinyinFor:obj],[dictionary definitionFor:obj],occurrences, nil];
        [arrayWithPinyinAndDefinitions addObject:charPinDefArray];
    }];
    	
	return [arrayWithPinyinAndDefinitions copy];
} 

/*
-(void)alternate {
	//Figures out the unknown stuff in the article, and puts it into an array
    NSMutableDictionary *unknownVocabWithRanges = [NSMutableDictionary dictionary];
    [articleString enumerateSubstringsInRange:NSMakeRange(0, [articleString length]) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        BOOL knownWord = NO;
        if ([substring length] > 1) if ([skritWordArray containsObject:substring]) knownWord = YES;
        else if ([skritCharacterArray containsObject:substring]) knownWord = YES;
        
        if (!knownWord && [dictionary itemInDictionary:substring]) {
            NSMutableArray *rangeArray = [unknownVocabWithRanges objectForKey:substring];
            //There's the chance of multiple ranges per item, hence:
            if (rangeArray) [rangeArray addObject:NSStringFromRange(substringRange)];
            else rangeArray = [NSMutableArray arrayWithObject:NSStringFromRange(substringRange)];
            
            [unknownVocabWithRanges setObject:rangeArray forKey:substring];
        }
    }];
	
	//creates a second array and adds definitions to it
    
    
	
	NSMutableArray *newStuffArrayWithDefinitions = [NSMutableArray arrayWithArray:[unknownVocabWithRanges allKeys]];
	newStuffArrayWithDefinitions = [self addDefinitionsAndPinyinToArray:newStuffArrayWithDefinitions];
	
	NSArray *oneDictOneArray = [NSArray arrayWithObjects:unknownVocabWithRanges,newStuffArrayWithDefinitions,nil];
	
	[[CRBrains shared] performSelectorOnMainThread:@selector(articleParsed:) withObject:oneDictOneArray waitUntilDone:YES];
    
}
 */

@end

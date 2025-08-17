//
//  CRDictSearch.m
//  Chinese Reader
//
//  Created by Peter Wood on 08/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRDictSearch.h"

@implementation CRDictSearch

//Returns the longest possible Chinese word from a string, based on one character in that string
+(NSString *)wordOrCharacterFromString:(NSString *)string forCharacterAtIndex:(NSUInteger)index rangeToIndex:(NSRangePointer)charLocRange {
    
    CRDictionary *dictionary = [CRDictionary shared];
	
	NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:@"theCharacter",@"theCharacter",nil];
	NSMutableAttributedString *tempAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
	
	[tempAttributedString setAttributes:attribute range:NSMakeRange(index, 1)];
	
	NSString *word = [string substringWithRange:NSMakeRange(index, 1)];
    if (![dictionary itemInDictionary:word]) return nil;
    NSRange charRange = NSMakeRange(0, 0);
	
	int positionInArticle = 0;
	int lengthOfArticle = [tempAttributedString length];
	int numberOfCharactersToCheck = 6;
    int tempNumberOfCharactersToCheck = 6;
	NSRange subStringRange;
	NSAttributedString *checkingString;
	NSCharacterSet *puncSet = [NSCharacterSet characterSetWithCharactersInString:@" \n\t。.，;:；：”’\"'()?<>《》！@£￥%⋯⋯&×（）"];
	
	while (positionInArticle < lengthOfArticle) {
		
		tempNumberOfCharactersToCheck = 6;
		
		//checks to see if we're about to reach the end of the text
		if (positionInArticle + numberOfCharactersToCheck > lengthOfArticle) tempNumberOfCharactersToCheck = lengthOfArticle - positionInArticle;
		
		//if not, sets the string to look at
		subStringRange = NSMakeRange(positionInArticle, tempNumberOfCharactersToCheck);
		
		checkingString = [tempAttributedString attributedSubstringFromRange:subStringRange];
		
		//checks to see if there is a halting punctuation within the next X characters
		for (int i = 0; i < tempNumberOfCharactersToCheck; i++) {
			
			//if there is, makes sure the string just goes up to that point
			if ([[checkingString string] rangeOfCharacterFromSet:puncSet].location != NSNotFound) {
				
				// but skips the next stage if there's nothing to check
				if ([[checkingString string] rangeOfCharacterFromSet:puncSet].location == 0) goto loopend;
				
				tempNumberOfCharactersToCheck = [[checkingString string] rangeOfCharacterFromSet:puncSet].location;
				subStringRange = NSMakeRange(subStringRange.location, tempNumberOfCharactersToCheck);
				break;
			}
		}
		
		checkingString = [tempAttributedString attributedSubstringFromRange:subStringRange];
		
		//checks to see if any of the next X characters is a word. Checks for the longest form first.
		for (int i = tempNumberOfCharactersToCheck; i > 0;i--) {
			checkingString = [checkingString attributedSubstringFromRange:NSMakeRange(0,i)];
			
            if ([dictionary itemInDictionary:[checkingString string]]) {
				
				//checks to see if the word contains the index character (with the attribute attached)
				BOOL hasAttribute = NO;
                int charLocation;
				for (charLocation = 0; charLocation < [checkingString length]; charLocation++) {
                    if ([checkingString attribute:@"theCharacter" atIndex:charLocation effectiveRange:NULL]) {
                        hasAttribute = YES;
                        break;
                    }
				}
				//If it does and if it's a longer word than previous seen, makes the checking string the new word
				if (hasAttribute && [checkingString length] > [word length]) {
                    word = [checkingString string];
                    charRange = NSMakeRange(0, charLocation);
                }
			}
		}
		
	loopend:
		positionInArticle++;
		
	}
    if (charLocRange) {
        charLocRange->length = 1;
        charLocRange->location = charRange.length;
    }
    
	return word;
	
}

@end

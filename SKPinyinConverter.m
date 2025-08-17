//
//  SKPinyinConverter.m
//  Chinese Reader
//
//  Main bulk created by Nick Winter of Skritter
//  Remainder by me.

#import "SKPinyinConverter.h"

@implementation SKPinyinConverter

static NSMutableDictionary *toneMarks;
static NSMutableDictionary *reverseToneMarks;

+(BOOL)canUseRegex {
    if (NSClassFromString(@"NSRegularExpression") != nil) return YES;
    else return NO;
}


+ (NSString *)addToneMarksToWord:(NSString *)word {
    
    //Returns pinyin if can't use Regex, or there are already tone marks
    if (![self canUseRegex] || [word rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) return word;
    
    //Changes u: to ü so the script can handle it
    word = [word stringByReplacingOccurrencesOfString:@"u:" withString:@"ü"];
    
    //Splits up by , and space
    NSArray *sylArray = [word componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableString *toneMarkedWord = [NSMutableString string];
    
    [sylArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //If it doesn't contain punctuation, and it's got a number, processes it
        if ([obj rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]].location == NSNotFound
            && [obj rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
        
            [toneMarkedWord appendFormat:@"%@",[self addToneMark:obj]];
        }
        
        //If it's a comma (or got a comma) adds this in
        if ([obj rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@",，"]].location != NSNotFound) {
            [toneMarkedWord appendString:@", "];
        }
        
    }];
    
    if ([toneMarkedWord rangeOfString:@"(null)"].location != NSNotFound) return word;
    
    return [toneMarkedWord copy];
}

+ (NSString *)placeMark:(int)n onSyllable:(NSString *)syl {
    // Rules from: http://www.pinyin.info/rules/where.html
    if([syl isEqualToString:@"r"])
        return @"r";
    
    // A or E (not found together) take precedence, then O in an OU combo.
    for(NSString *vowel in [NSArray arrayWithObjects:@"a", @"A", @"e", @"E", @"ou", @"Ou", nil])
        if([syl rangeOfString:vowel options:NSBackwardsSearch].location != NSNotFound)
            return [syl stringByReplacingOccurrencesOfString:[vowel substringToIndex:1] withString:[[toneMarks objectForKey:[vowel substringToIndex:1]] substringWithRange:NSMakeRange(n, 1)]];
    
    // Otherwise, the last vowel takes the mark.
    NSArray *otherVowels = [NSArray arrayWithObjects:@"o", @"O", @"i", @"I", @"u", @"U", @"ü", @"Ü", nil];
    for(int i = [syl length] - 1; i >= 0; --i) {
        NSString *c = [syl substringWithRange:NSMakeRange(i, 1)];
        if([otherVowels containsObject:c])
            return [syl stringByReplacingOccurrencesOfString:c withString:[[toneMarks objectForKey:c] substringWithRange:NSMakeRange(n, 1)]];
    }
   // DLog(@"<^> <^> <^> <^> <^> <^> <^> Couldn't find vowel in syl %@ (tone number %d) <^> <^> <^> <^> <^> <^> <^>", syl, n);
    return nil;
}

+ (NSString *)addToneMark:(NSString *)syl {
    static NSRegularExpression *syllableRegex = nil;
    if(!syllableRegex)
        syllableRegex = [[NSRegularExpression alloc] initWithPattern:@"^[a-zA-ZüÜ]+[1-5]$" options:0 error:nil];
    if(!syl || ![syl length] || ![[syllableRegex matchesInString:syl options:0 range:NSMakeRange(0, [syl length])] count]) {
       // DLog(@"orz orz orz orz orz orz orz orz orz orz Got bogus syl %@ passed to addToneMark orz orz orz orz orz orz orz orz orz orz", syl);
        return nil;
    }
    syl = [syl stringByReplacingOccurrencesOfString:@"v" withString:@"ü"];
    syl = [syl stringByReplacingOccurrencesOfString:@"V" withString:@"Ü"];
    ushort n = [SKPinyinConverter toneNumberFromSyllable:syl];
    return [SKPinyinConverter placeMark:n onSyllable:[syl substringToIndex:[syl length] - 1]];
}

+ (NSString *)stripToneMarks:(NSString *)p {
    NSMutableString *stripped = [p mutableCopy];
    for(size_t i = 0; i < [stripped length]; ++i) {
        NSString *c = [stripped substringWithRange:NSMakeRange(i, 1)];
        NSString *toneless = [reverseToneMarks objectForKey:c];
        if(toneless != nil)
            [stripped replaceCharactersInRange:NSMakeRange(i, 1) withString:toneless];
    }
    return [NSString stringWithString:stripped];
}

+ (ushort)toneNumberFromSyllable:(NSString *)syl {
    return [syl characterAtIndex:[syl length] - 1] - 48;
}

+ (void)initialize {
    toneMarks = [[NSMutableDictionary alloc] initWithCapacity:12];
    [toneMarks setObject:@"*āáǎàa" forKey:@"a"];
    [toneMarks setObject:@"*ōóǒòo" forKey:@"o"];
    [toneMarks setObject:@"*ēéěèe" forKey:@"e"];
    [toneMarks setObject:@"*īíǐìi" forKey:@"i"];
    [toneMarks setObject:@"*ūúǔùu" forKey:@"u"];
    [toneMarks setObject:@"*ǖǘǚǜü" forKey:@"ü"];
    [toneMarks setObject:@"*ĀÁǍÀA" forKey:@"A"];
    [toneMarks setObject:@"*ŌÓǑÒO" forKey:@"O"];
    [toneMarks setObject:@"*ĒÉĚÈE" forKey:@"E"];
    [toneMarks setObject:@"*ĪÍǏÌI" forKey:@"I"];
    [toneMarks setObject:@"*ŪÚǓÙU" forKey:@"U"];
    [toneMarks setObject:@"*ǕǗǙǛÜ" forKey:@"Ü"];
    
    reverseToneMarks = [[NSMutableDictionary alloc] initWithCapacity:60];
    for(NSString *c in toneMarks) {
        NSString *accented = [toneMarks objectForKey:c];
        for(size_t i = 1; i < [accented length]; ++i)
            [reverseToneMarks setObject:c forKey:[accented substringWithRange:NSMakeRange(i, 1)]];
    }
}


@end

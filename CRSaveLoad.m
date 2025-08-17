//
//  CRSaveLoad.m
//  Chinese Reader
//
//  Created by Peter Wood on 31/05/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRSaveLoad.h"
#import "GHNSString+TimeInterval.h"

@implementation CRSaveLoad

//Save

+(BOOL)saveText:(NSAttributedString *)text withSummary:(NSMutableArray *)summary forFileName:(NSString *)fileName {
    
    BOOL savedOK = NO;
    
    //If the file already exists, preserves the creation date
    NSDate *creationDate = [NSDate date];
    if ([self fileNameExists:fileName]) creationDate = [self createdFileNameDate:fileName];
    
    //save attributed string
    NSData *stringData = [NSKeyedArchiver archivedDataWithRootObject:text];
    if ([stringData writeToFile:[self pathForTextWithFileName:fileName] atomically:YES]) savedOK = YES;
    
    [self saveSummary:summary forFileName:fileName];
    
    //Adds item to index
    NSMutableDictionary *savedIndex = [[self savedDictionary] mutableCopy];
    //created, last accessed
    
    [savedIndex setObject:[NSArray arrayWithObjects:creationDate,[NSDate date], nil] forKey:fileName];
    [savedIndex writeToFile:[self pathForIndex] atomically:YES];
    
    return savedOK;
}

+(void)saveSummary:(NSMutableArray *)summary forFileName:(NSString *)fileName {
    //Saves the summary as NSData due to the AttributedString not playing nice
    NSData *summaryData = [NSKeyedArchiver archivedDataWithRootObject:summary];
    [summaryData writeToFile:[self pathForSummaryWithFileName:fileName] atomically:YES];
}

+(BOOL)saveLastViewedData:(NSDate *)date forFileName:(NSString *)fileName {
    BOOL savedOK = NO;
    
    NSMutableDictionary *savedIndex = [[self savedDictionary] mutableCopy];
    NSDate *creationDate = [[savedIndex objectForKey:fileName] objectAtIndex:0];
    
    [savedIndex setObject:[NSArray arrayWithObjects:creationDate,[NSDate date],nil] forKey:fileName];
    if ([savedIndex writeToFile:[self pathForIndex] atomically:YES]) savedOK = YES;
    
    return savedOK;
}





//Remove
+(BOOL)deleteSavedFile:(NSString *)fileName {
    
    BOOL deletedOK = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self pathForTextWithFileName:fileName] error:nil];
    [fileManager removeItemAtPath:[self pathForSummaryWithFileName:fileName] error:nil];
    
    //Remove item from index
    NSMutableDictionary *savedIndex = [[self savedDictionary] mutableCopy];
    [savedIndex removeObjectForKey:fileName];
    if ([savedIndex writeToFile:[self pathForIndex] atomically:YES]) deletedOK = YES;
    else deletedOK = NO;
    
    return deletedOK;
}





//Get arrays of file names

+(NSDictionary *)savedDictionary {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [NSDictionary dictionaryWithContentsOfFile:[settings objectForKey:@"savedIndexFileLocation"]];
}

+(NSArray *)latestIndex {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *latestIndex = [NSArray array];
    if ([[settings objectForKey:@"saveLoadStyle"] isEqualToString:@"creation"]) latestIndex = [self sortedArrayOfFileNamesByCreationWithTime];
    if ([[settings objectForKey:@"saveLoadStyle"] isEqualToString:@"lastViewed"]) latestIndex = [self sortedArrayOfFileNamesByLastViewedWithTime];
        
    return latestIndex;
}

+(NSArray *)latestSearchedIndex:(NSString *)searchString {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *latestSearchedIndex = [NSArray array];
    if ([[settings objectForKey:@"saveLoadStyle"] isEqualToString:@"creation"]) {
        latestSearchedIndex = [self searchArrayOfFileNamesWithArray:[self sortedArrayOfFileNamesByCreationWithTime] forString:searchString];
    }
    if ([[settings objectForKey:@"saveLoadStyle"] isEqualToString:@"lastViewed"]) {
        latestSearchedIndex = [self searchArrayOfFileNamesWithArray:[self sortedArrayOfFileNamesByLastViewedWithTime] forString:searchString];
    }
    
    return latestSearchedIndex;
}


//Last viewed

+(NSArray *)sortedArrayOfFileNamesByLastViewed {
    
    NSDictionary *savedDictionary = [self savedDictionary];
    NSArray *sortedArray = [savedDictionary keysSortedByValueUsingComparator:^(id obj1, id obj2) {
        NSDate *first = [obj1 objectAtIndex:1];
        NSDate *second = [obj2 objectAtIndex:1];
        return [second compare:first];
    }];
    
    return sortedArray;
}

+(NSArray *)sortedArrayOfFileNamesByLastViewedWithTime {
    
    NSDictionary *savedDictionary = [self savedDictionary];
    NSArray *arrayOfFileNames = [self sortedArrayOfFileNamesByLastViewed];
    NSMutableArray *arrayOfFileNamesWithTime = [NSMutableArray array];
    
    NSDictionary *fileNameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:15.0],NSFontAttributeName, nil];
    NSDictionary *timeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:10.0],NSFontAttributeName,[NSColor grayColor],NSForegroundColorAttributeName, nil];
    
    [arrayOfFileNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDate *lastViewedDate = [[savedDictionary objectForKey:obj] objectAtIndex:1];
        NSTimeInterval timeInterval = [lastViewedDate timeIntervalSinceNow];
        NSString *timeString = [NSString stringWithFormat:@"\nViewed %@ ago",[NSString gh_stringForTimeInterval:timeInterval includeSeconds:NO]];
        
        NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:obj attributes:fileNameAttributes];
        NSAttributedString *timeAtString = [[NSAttributedString alloc] initWithString:timeString attributes:timeAttributes];
        [atString appendAttributedString:timeAtString];
        
        [arrayOfFileNamesWithTime addObject:atString];
        
    }];
    
    return [arrayOfFileNamesWithTime copy];
}

//Creation date

+(NSArray *)sortedArrayOfFileNamesByCreation {
    
    NSDictionary *savedDictionary = [self savedDictionary];
    NSArray *sortedArray = [savedDictionary keysSortedByValueUsingComparator:^(id obj1, id obj2) {
        NSDate *first = [obj1 objectAtIndex:0];
        NSDate *second = [obj2 objectAtIndex:0];
        return [second compare:first];
    }];
    
    return sortedArray;
}

+(NSArray *)sortedArrayOfFileNamesByCreationWithTime {
    
    NSDictionary *savedDictionary = [self savedDictionary];
    NSArray *arrayOfFileNames = [self sortedArrayOfFileNamesByCreation];
    NSMutableArray *arrayOfFileNamesWithTime = [NSMutableArray array];
    
    NSDictionary *fileNameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:15.0],NSFontAttributeName, nil];
    NSDictionary *timeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:10.0],NSFontAttributeName,[NSColor grayColor],NSForegroundColorAttributeName, nil];
    
    [arrayOfFileNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDate *lastViewedDate = [[savedDictionary objectForKey:obj] objectAtIndex:0];
        NSTimeInterval timeInterval = [lastViewedDate timeIntervalSinceNow];
        NSString *timeString = [NSString stringWithFormat:@"\nCreated %@ ago",[NSString gh_stringForTimeInterval:timeInterval includeSeconds:NO]];
        
        NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:obj attributes:fileNameAttributes];
        NSAttributedString *timeAtString = [[NSAttributedString alloc] initWithString:timeString attributes:timeAttributes];
        [atString appendAttributedString:timeAtString];
        
        [arrayOfFileNamesWithTime addObject:atString];
        
    }];
    
    return [arrayOfFileNamesWithTime copy];
}

//Search

+(NSArray *)searchArrayOfFileNamesWithArray:(NSArray *)timeOrDateArray forString:(NSString *)searchString {
    NSArray *savedIndex = timeOrDateArray;
    NSMutableArray *searchedIndex = [NSMutableArray array];
    
    [savedIndex enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = [self fileNameWithoutTime:obj];
        if ([fileName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            [searchedIndex addObject:[savedIndex objectAtIndex:idx]];
    }];
    
    return [searchedIndex copy];
}


//Misc

+(BOOL)fileNameExists:(NSString *)fileName {
    BOOL exists = NO;
    NSDictionary *savedDictionary = [self savedDictionary];
    
    if ([savedDictionary objectForKey:fileName]) exists = YES;
    
    return exists;
}

+(NSUInteger)indexOfFileName:(NSString *)fileName {
    NSArray *sortedArray = [self sortedArrayOfFileNamesByLastViewed];
    
    NSUInteger index = [sortedArray indexOfObject:fileName];
    
    if (index == NSNotFound) index = -1;

    return index;
}

//Get dates for a file name

+(NSDate *)lastViewedFileNameDate:(NSString *)fileName {
    return [[[self savedDictionary] objectForKey:fileName] objectAtIndex:1];
}

+(NSDate *)createdFileNameDate:(NSString *)fileName {
     return [[[self savedDictionary] objectForKey:fileName] objectAtIndex:0];
}






//Get parts of a file
//This is the load function
+(NSAttributedString *)textForFileName:(NSString *)fileName {
    
    NSData *textData = [NSData dataWithContentsOfFile:[self pathForTextWithFileName:fileName]];
    NSAttributedString *text = [NSKeyedUnarchiver unarchiveObjectWithData:textData];
    
    if (!text) return [[NSAttributedString alloc] initWithString:@"Error, text doesn't exist"];
    return text;
    
}

+(NSMutableArray *)summaryForFileName:(NSString *)fileName {

    NSData *summaryData = [NSData dataWithContentsOfFile:[self pathForSummaryWithFileName:fileName]];
    if (!summaryData) return [NSMutableArray array];
    NSMutableArray *summary = [NSKeyedUnarchiver unarchiveObjectWithData:summaryData];

    return summary;
}

+(NSArray *)bookmarksForFileName:(NSString *)fileName {
   
    return [NSArray array];
}
     
+(NSString *)pathForTextWithFileName:(NSString *)fileName {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [[settings objectForKey:@"savedDirectory"] stringByAppendingString:[NSString stringWithFormat:@"/%@.text",fileName]];
}

+(NSString *)pathForSummaryWithFileName:(NSString *)fileName {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [[settings objectForKey:@"savedDirectory"] stringByAppendingString:[NSString stringWithFormat:@"/%@.summary",fileName]];
}

+(NSString *)pathForIndex {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"savedIndexFileLocation"];
}
     
+(NSString *)fileNameWithoutTime:(NSAttributedString *)fileName {
    NSArray *array = [[fileName string] componentsSeparatedByString:@"\n"];
         
    return [array objectAtIndex:0];
}

@end

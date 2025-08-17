//
//  CRSaveLoad.h
//  Chinese Reader
//
//  Created by Peter Wood on 31/05/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHNSString+TimeInterval.h"

@interface CRSaveLoad : NSObject {
    

}

+(BOOL)saveText:(NSAttributedString *)text withSummary:(NSMutableArray *)summary forFileName:(NSString *)fileName;
+(void)saveSummary:(NSMutableArray *)summary forFileName:(NSString *)fileName;
+(BOOL)saveLastViewedData:(NSDate *)date forFileName:(NSString *)fileName;
+(BOOL)deleteSavedFile:(NSString *)fileName;

//File index
+(NSDictionary *)savedDictionary;
+(NSArray *)latestIndex; //Use this one for non searches
+(NSArray *)latestSearchedIndex:(NSString *)searchString; //Use this one for searches. Others are internal.

//Last viewed & by creation date
+(NSArray *)sortedArrayOfFileNamesByLastViewed;
+(NSArray *)sortedArrayOfFileNamesByLastViewedWithTime;
+(NSArray *)sortedArrayOfFileNamesByCreation;
+(NSArray *)sortedArrayOfFileNamesByCreationWithTime;
//Search
+(NSArray *)searchArrayOfFileNamesWithArray:(NSArray *)timeOrDateArray forString:(NSString *)searchString;

+(BOOL)fileNameExists:(NSString *)fileName;
+(NSUInteger)indexOfFileName:(NSString *)fileName;

+(NSDate *)lastViewedFileNameDate:(NSString *)fileName;
+(NSDate *)createdFileNameDate:(NSString *)fileName;

//Return components
+(NSAttributedString *)textForFileName:(NSString *)fileName;
+(NSMutableArray *)summaryForFileName:(NSString *)fileName;
+(NSArray *)bookmarksForFileName:(NSString *)fileName;

//Paths
+(NSString *)pathForTextWithFileName:(NSString *)fileName;
+(NSString *)pathForSummaryWithFileName:(NSString *)fileName;
+(NSString *)pathForIndex;

+(NSString *)fileNameWithoutTime:(NSAttributedString *)fileName;

@end

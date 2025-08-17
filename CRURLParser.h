//
//  CRURLParser.h
//  Chinese Reader
//
//  Created by Peter Wood on 09/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRURLParser : NSObject

+(NSAttributedString *)attributedStringForURL:(NSURL *)url;

+(NSAttributedString *)attributedStringForBBCChinese:(NSData *)websiteData;

+(NSString *)h1FromString:(NSString *)string;
+(NSString *)stringFromTag:(NSString *)tag1 toTag:(NSString *)tag2 forString:(NSString *)string;

+(BOOL)canUseRegex;

@end

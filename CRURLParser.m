//
//  CRURLParser.m
//  Chinese Reader
//
//  Created by Peter Wood on 09/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRURLParser.h"

@implementation CRURLParser

+(NSAttributedString *)attributedStringForURL:(NSURL *)url {
    NSData *websiteData = [[NSData alloc] initWithContentsOfURL:url];
    
    /*
    //This doesn't really work properly. Alternate needed.
    if ([self canUseRegex]) {
        if ([[url host] isEqualToString:@"www.bbc.co.uk"]) return [self attributedStringForBBCChinese:websiteData];
    } 
     */
    
    NSAttributedString *atString = [[NSAttributedString alloc] initWithHTML:websiteData documentAttributes:NULL];
    return atString;
}

+(NSAttributedString *)attributedStringForBBCChinese:(NSData *)websiteData {
    
    NSString *string = [[NSString alloc] initWithData:websiteData encoding:NSUTF8StringEncoding];
    NSString *newString = [self h1FromString:string];
    newString = [newString stringByAppendingString:@"\n\n"];
    newString = [newString stringByAppendingString:[self stringFromTag:@"<p class=\"ingress\">" toTag:@"</div>" forString:string]];

    newString = [self replaceHTMLFormatting:newString];
    NSData *data = [newString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *atString = [[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL];
    return atString;
}

+(NSString *)h1FromString:(NSString *)string {
    NSRange range = [string rangeOfString:@"<h1>.*?</h1>" options:(NSRegularExpressionSearch | NSRegularExpressionCaseInsensitive)];    
    if (range.length == 0) return @"Error with parsing URL, please report!";
    
    return [string substringWithRange:range];
}

+(NSString *)stringFromTag:(NSString *)tag1 toTag:(NSString *)tag2 forString:(NSString *)string {//<p class=\"ingress\">
    NSString *regEx = [NSString stringWithFormat:@"%@[^.]*?(%@)",tag1,tag2];
    //eg regEx = @"<p class=\"ingress\">[^.]*?(</div>)";
    NSRange range = [string rangeOfString:regEx options:(NSRegularExpressionSearch | NSRegularExpressionCaseInsensitive)];    
    if (range.length == 0) return @"Error with parsing URL, please report!";
    
    return [string substringWithRange:range];
}

+(NSString *)replaceHTMLFormatting:(NSString *)string {
    
    string = [string stringByReplacingOccurrencesOfString:@"<p>" withString:@"<br><p>" options:(NSRegularExpressionSearch | NSRegularExpressionCaseInsensitive) range:NSMakeRange(0, [string length])];
    string = [string stringByReplacingOccurrencesOfString:@"<h2>" withString:@"<br><h2>" options:(NSRegularExpressionSearch | NSRegularExpressionCaseInsensitive) range:NSMakeRange(0, [string length])];
    
    
    return string;
}

+(NSDictionary *)titleAttributes {
    return [NSDictionary dictionary];
}

+(BOOL)canUseRegex {
    if (NSClassFromString(@"NSRegularExpression") != nil) return YES;
    else return NO;
}

@end

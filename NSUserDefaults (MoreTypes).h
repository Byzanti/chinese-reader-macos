//
//  NSUserDefaults (MoreTypes).h
//  Chinese Reader
//
//  Created by Peter on 24/05/2012.
//  Copyright 2012 Byzanti. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSUserDefaults (MoreTypes)

- (void)setColor:(NSColor*)aColor
          forKey:(NSString*)aKey ;

- (NSColor*)colorForKey:(NSString*)aKey ;

@end

//
//  CRBookmarksController.m
//  Chinese Reader
//
//  Created by Peter Wood on 02/06/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import "CRBookmarksController.h"

@implementation CRBookmarksController

@synthesize bookmarksArray;
@synthesize bookmarksRangeArray;

-(void)awakeFromNib {
    settings = [NSUserDefaults standardUserDefaults];
    bookmarksArray = [NSMutableArray array];
    bookmarksRangeArray = [NSMutableArray array];
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(addBookmarkAttributes:) name:@"AddBookmarkAttributes" object:nil];
    [center addObserver:self selector:@selector(updateBookmarks) name:@"UpdateBookmarks" object:nil];
    [self updateBookmarks];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [bookmarksArray count];
    
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [bookmarksArray objectAtIndex:row];
}

//Add attributes
-(void)addBookmarkAttributes:(NSNotification *)notification {
    NSDictionary *rangeDict = [notification userInfo];

    //adds date of bookmark
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:dateString,@"bookmark",[settings colorForKey:@"editorBookmarkColour"],NSBackgroundColorAttributeName, nil];
    
    [[articleView textStorage] addAttributes:attributes range:NSRangeFromString([rangeDict objectForKey:@"range"])];
    
    [CRStatus setTextChanged:YES];
    [self updateBookmarks];
    [center postNotificationName:@"UpdateBookText" object:self];
}

//Update
-(void)updateBookmarks {
    [bookmarksArray removeAllObjects];
    [bookmarksRangeArray removeAllObjects];
    NSTextStorage *atString = [articleView textStorage];
    NSString *string = [atString string];
    int stringLength = [string length];
    int exampleChars = 10; //this is x before the character, x after
    
    NSDictionary *bookmarkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:15.0],NSFontAttributeName,[NSColor orangeColor],NSForegroundColorAttributeName,nil];
    NSDictionary *exampleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:15.0],NSFontAttributeName, nil];
    
    [atString enumerateAttribute:@"bookmark" inRange:NSMakeRange(0, stringLength) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            
            //Pre bookmark string
            int newLocation = range.location - exampleChars;
            if (newLocation < 0) newLocation = 0;
            NSRange preBookmarkRange = NSMakeRange(newLocation, range.location - newLocation);
            NSString *preBookmarkString = [[string substringWithRange:preBookmarkRange] stringByRemovingCharactersInSet:[NSCharacterSet newlineCharacterSet] andString:@"\t"];
            NSAttributedString *preBookmarkAtString = [[NSAttributedString alloc] initWithString:preBookmarkString attributes:exampleAttributes];
            
            //bookmark string
            NSAttributedString *bookmarkAtString = [[NSAttributedString alloc] initWithString:[string substringWithRange:range] attributes:bookmarkAttributes];
            
            //post bookmark string
            newLocation = range.location + range.length;
            NSRange postBookmarkRange = NSMakeRange(newLocation, exampleChars);
            if (postBookmarkRange.location + postBookmarkRange.length > stringLength) postBookmarkRange.length = stringLength - postBookmarkRange.location;
            NSAttributedString *postBookmarkAtString = [[NSAttributedString alloc] initWithString:[string substringWithRange:postBookmarkRange] attributes:exampleAttributes];
            
            //together
            NSMutableAttributedString *exampleAtString = [[NSMutableAttributedString alloc] initWithAttributedString:preBookmarkAtString];
            [exampleAtString appendAttributedString:bookmarkAtString];
            [exampleAtString appendAttributedString:postBookmarkAtString];
            
            [bookmarksArray addObject:exampleAtString];
            [bookmarksRangeArray addObject:NSStringFromRange(range)];
            
        }
    }];
    
    [bookmarksTable reloadData];
}

//Load new item
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    
    //Sees how many rows are selected. If more than one, does nothing.
    NSIndexSet *indexSet = [bookmarksTable selectedRowIndexes];
	int indexCount = [indexSet count];
	if (indexCount == 0 || indexCount > 1) return;
    
    int index = [indexSet firstIndex];
    
    NSRange range = NSRangeFromString([bookmarksRangeArray objectAtIndex:index]);
    [articleView scrollRangeToVisible:range];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lu",range.location] forKey:@"place"];
    [center postNotificationName:@"UpdatePlaceInText" object:self userInfo:dict];
}

-(IBAction)addBookmark:(id)sender {
    [settings setBool:YES forKey:@"addingBookmark"];
    [settings synchronize];
    [[NSCursor pointingHandCursor] set];
}

-(IBAction)removeBookmarks:(id)sender {
    
    //Gets an array of all the objects that should be deleted
    NSIndexSet *indexSet = [bookmarksTable selectedRowIndexes];    
    NSUInteger index=[indexSet firstIndex];
    NSMutableArray *bookmarkObjects = [NSMutableArray array];
    
    while (index != NSNotFound) {
        
        [bookmarkObjects addObject:[bookmarksArray objectAtIndex:index]];
        index = [indexSet indexGreaterThanIndex:index];
        
    }
    
    //Then deletes all the objects
    for (int i = 0; i < [bookmarkObjects count]; i++) [self removeBookmarkObject:[bookmarkObjects objectAtIndex:i]];
}

-(void)removeBookmarkObject:(NSAttributedString *)bookmark {
   
    NSUInteger bookmarkIndex = [bookmarksArray indexOfObject:bookmark];
    NSRange range = NSRangeFromString([bookmarksRangeArray objectAtIndex:bookmarkIndex]);
    
    NSTextStorage *articleViewTextStorage = [articleView textStorage];
    [articleViewTextStorage removeAttribute:@"bookmark" range:range];
    [articleViewTextStorage removeAttribute:NSBackgroundColorAttributeName range:range];
    
    [bookmarksRangeArray removeObjectAtIndex:bookmarkIndex];
    [bookmarksArray removeObject:bookmark];
    [bookmarksTable deselectAll:self];
    [self updateBookmarks];
    [CRStatus setTextChanged:YES];
    
}

-(void)deleteSelectionFromTableView:(NSTableView *)tableView {
    [self removeBookmarks:self];
}

@end

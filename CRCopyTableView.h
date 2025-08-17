//
//  CRCopyTableView.h
//  Chinese Reader
//
//  Created by Peter on 14/08/2012.
//  Copyright (c) 2012 Byzanti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CRCopyTableView : NSTableView
@end

@protocol CRCopyTableViewDelegate
@optional
-(void)copyFromTableView:(NSTableView *)tableView;
@end

//
//  BSMainWindowController.h
//  1blankspace
//
//  Created by VenoMKO on 11/29/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INAppStoreWindow.h"
#import "BSAppDelegate.h"
#import "BSAPIRequest.h"
#import "BSPanelController.h"

@interface BSMainWindowController : NSWindowController <NSTableViewDataSource> {
    NSMutableArray                                          *_data;
    NSMutableArray                                          *_groups;
    NSMutableArray                                          *_endpoints;
    NSInteger                                               _prevGroupId;
    NSInteger                                               _prevEndpoint;
    BOOL                                                    initialized;
}

@property (assign) IBOutlet NSTableView                 *dataTableView;
@property (assign) IBOutlet NSTableView                 *groupsTableView;
@property (assign) IBOutlet NSTableView                 *endpointsTableView;
@property (assign) IBOutlet NSProgressIndicator         *spinner;

@property (assign) IBOutlet NSButton                    *addButton;
@property (assign) IBOutlet NSButton                    *editButton;
@property (assign) IBOutlet NSButton                    *removeButton;

@end

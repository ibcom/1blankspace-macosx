//
//  BSPanelController.h
//  1blankspace
//
//  Created by VenoMKO on 11/30/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSPanelController : NSWindowController

@property (assign) IBOutlet NSTextField                 *col1;
@property (assign) IBOutlet NSTextField                 *col2;
@property (assign) IBOutlet NSTextField                 *col3;
@property (assign) IBOutlet NSTextField                 *col4;
@property (assign) IBOutlet NSPopUpButton               *col5;

@property (assign) IBOutlet NSTextField                 *col1label;
@property (assign) IBOutlet NSTextField                 *col2label;
@property (assign) IBOutlet NSTextField                 *col3label;
@property (assign) IBOutlet NSTextField                 *col4label;
@property (assign) IBOutlet NSTextField                 *col5label;

@property (assign) IBOutlet NSButton                    *okButton;

@property (assign) SEL                                  okSelector;
@property (assign) SEL                                  cancelSelector;
@property (assign) id                                   panelOwner;

- (void)bringPanel;

@end

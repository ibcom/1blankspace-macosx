//
//  BSMainWindowController.m
//  1blankspace
//
//  Created by VenoMKO on 11/29/12.
//  Copyright (c) 2012 VenoMKO. All rights reserved.
//

#import "BSMainWindowController.h"

@implementation BSMainWindowController

- (id)init
{
    if ((self = [super initWithWindowNibName:@"BSMainWindowController"])) {
        
        [(INAppStoreWindow *)[self window] setTrafficLightButtonsLeftMargin:7.0f];
        [(INAppStoreWindow *)[self window] setTitleBarHeight:40.0f];
        
        _data = [[NSMutableArray alloc] init];
        _groups = [[NSMutableArray alloc] initWithArray:@[@{@"id" : @(-1), @"title" : @"All (0)"}]];
        _endpoints = [[NSMutableArray alloc] initWithArray:@[@{@"id" : @(0), @"title" : NSLocalizedString(@"Personal", nil), @"icon" : [NSImage imageNamed:NSImageNameUser]},
                                                             @{@"id" : @(1), @"title" : NSLocalizedString(@"Business", nil), @"icon" : [NSImage imageNamed:NSImageNameUserGroup]}]];
        
        _prevGroupId = -1;
        _prevEndpoint = 0;
    }
    return self;
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];
    [self setInterfaceEnabled:NO];
    
    NSSearchField   *searchField = [(INAppStoreWindow *)self.window searchField];
    
    if (searchField) {
        [searchField setContinuous:NO];
        [[searchField cell] setSendsWholeSearchString:YES];
        [searchField setTarget:self];
        [searchField setAction:@selector(searchContacts:)];
    }
    
    [NSApp activateIgnoringOtherApps:YES];
    [_dataTableView setDataSource:_data];
    [_groupsTableView setDataSource:_groups];
    [_endpointsTableView setDataSource:_endpoints];
    [self updateGroupsArray];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

#pragma mark -
#pragma mark Process responses

// Populating groups table view

- (void)updatingGroups:(NSDictionary *)response
{
    if ([_groups count] > 1) {
        NSDictionary    *allElement = @{@"id" : @(-1), @"title" : [NSString stringWithFormat:@"All (%lu)",[_data count]]};
        [_groups removeAllObjects];
        [_groups addObject:allElement];
    }
    [_groups addObjectsFromArray:[[response objectForKey:@"data"] objectForKey:@"rows"]];
    [_groupsTableView reloadData];
    if (initialized)
        [self setInterfaceEnabled:YES];
}

// Populating main table view

- (void)updatingData:(NSDictionary *)response
{
    if (![[response objectForKey:@"status"] isEqualToString:@"OK"]) {
        [self requestFailed:response];
        return;
    }
    
    if ([[[_groups objectAtIndex:[_groupsTableView selectedRow]] objectForKey:@"id"] integerValue] < 0) {
        
        if ([response objectForKey:@"summary"] && [[response objectForKey:@"summary"] objectForKey:@"contactcount"]) {
            
            NSDictionary    *newAllItem = @{@"id" : @(-1), @"title" : [NSString stringWithFormat:@"All (%ld)",[[[response objectForKey:@"summary"] objectForKey:@"contactcount"] integerValue]]};
            
            [_groups replaceObjectAtIndex:0 withObject:newAllItem];
            [_groupsTableView reloadData];
        }
        
    }
    
    if (!initialized)
        initialized = YES;
    
    [_data removeAllObjects];
    [_data addObjectsFromArray:[[response objectForKey:@"data"] objectForKey:@"rows"]];
    [_dataTableView reloadData];
    [self setInterfaceEnabled:YES];
}

- (void)requestFailed:(NSDictionary *)response
{
    [self setInterfaceEnabled:YES];
    NSLog(@"Error: %@",response);
}

#pragma mark -
#pragma mark Handle window events

// Add button pressed

- (IBAction)addAction:(id)sender
{
    BSPanelController   *panelController = [[BSPanelController alloc] init];
    
    [panelController setPanelOwner:self];
    [panelController setOkSelector:@selector(requestAdd:)];
    
    NSDictionary    *labels = [BSAPIRequest displayFormatDictionaryForEndpoint:(BSAPIEndpoint)[[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue]];
    
    [panelController showWindow:nil];
    
    [[panelController col1label] setStringValue:[labels objectForKey:@"col1"]];
    [[panelController col2label] setStringValue:[labels objectForKey:@"col2"]];
    [[panelController col3label] setStringValue:[labels objectForKey:@"col3"]];
    [[panelController col4label] setStringValue:[labels objectForKey:@"col4"]];
    [[panelController col5label] setStringValue:[labels objectForKey:@"col5"]];
    
    NSMenu *items = [[NSMenu alloc] init];
    [items setAutoenablesItems:NO];
    
    for (NSDictionary *groupInfo in _groups) {
        
        NSMenuItem  *newItem = [[NSMenuItem alloc] init];
        
        [newItem setTitle:[groupInfo objectForKey:@"title"]];
        [newItem setTag:[[groupInfo objectForKey:@"id"] integerValue]];
        [items addItem:newItem];
        
        [newItem release];
    }
    
    [[panelController col5] setMenu:items];
    [[panelController col5] selectItemWithTag:[[[_groups objectAtIndex:[_groupsTableView selectedRow]] objectForKey:@"id"] integerValue]];
    [items release];
    
    [[panelController okButton] setTitle:NSLocalizedString(@"Add", nil)];
    
    [panelController bringPanel];
    
    [panelController release];
}

// Remove button pressed

- (IBAction)removeAction:(id)sender
{
    if ([_dataTableView selectedRow] == NSUIntegerMax)
        return;
    BSAPIRequest    *request = [[[BSAPIRequest alloc] initWithType:BSAPIRequestTypeRemoveData] autorelease];
    
    NSInteger endpoint = [[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue];
    NSString *rowId = [[_data objectAtIndex:[_dataTableView selectedRow]] objectForKey:@"id"];
    
    [request setContactInfo:@{@"id" : rowId}];
    [request setEndpoint:(BSAPIEndpoint)endpoint];
    [request setDelegate:self];
    [request setSid:[[NSApp delegate] sid]];
    [request setDidFinishSelector:@selector(selectGroup:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    [self setInterfaceEnabled:NO];
    [request start];
}

// Edit button pressed

- (IBAction)editAction:(id)sender
{
    if ([_dataTableView selectedRow] == NSUIntegerMax)
        return;
    BSPanelController   *panelController = [[BSPanelController alloc] init];
    
    [panelController setPanelOwner:self];
    [panelController setOkSelector:@selector(requestEdit:)];
    
    NSDictionary    *labels = [BSAPIRequest displayFormatDictionaryForEndpoint:(BSAPIEndpoint)[[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue]];
    
    [panelController showWindow:nil];
    
    [[panelController col1label] setStringValue:[labels objectForKey:@"col1"]];
    [[panelController col2label] setStringValue:[labels objectForKey:@"col2"]];
    [[panelController col3label] setStringValue:[labels objectForKey:@"col3"]];
    [[panelController col4label] setStringValue:[labels objectForKey:@"col4"]];
    [[panelController col5label] setHidden:YES];
    [[panelController col5] setHidden:YES];
    
    NSDictionary    *row = [_data objectAtIndex:[_dataTableView selectedRow]];
    
    if ([row objectForKey:@"col1"])
        [[panelController col1] setStringValue:[row objectForKey:@"col1"]];
    
    if ([row objectForKey:@"col2"])
        [[panelController col2] setStringValue:[row objectForKey:@"col2"]];
    
    if ([row objectForKey:@"col3"])
        [[panelController col3] setStringValue:[row objectForKey:@"col3"]];
    
    if ([row objectForKey:@"col4"])
        [[panelController col4] setStringValue:[row objectForKey:@"col4"]];
    
    [[panelController okButton] setTitle:NSLocalizedString(@"Edit", nil)];
    
    [panelController bringPanel];
    
    [panelController release];
}

// Generating Edit row request

- (void)requestEdit:(NSDictionary *)row
{
    BSAPIRequest    *request = [[[BSAPIRequest alloc] initWithType:BSAPIRequestTypeEditData] autorelease];
    
    NSInteger endpoint = [[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue];
    NSString *rowId = [[_data objectAtIndex:[_dataTableView selectedRow]] objectForKey:@"id"];
    
    NSMutableDictionary *newRow = [NSMutableDictionary dictionaryWithDictionary:row];
    [newRow setObject:rowId forKey:@"id"];
    [request setContactInfo:newRow];
    [request setEndpoint:(BSAPIEndpoint)endpoint];
    [request setDelegate:self];
    [request setSid:[[NSApp delegate] sid]];
    [request setDidFinishSelector:@selector(selectGroup:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    [self setInterfaceEnabled:NO];
    [request start];
}

// Generating Add row request

- (void)requestAdd:(NSDictionary *)row
{
    BSAPIRequest    *request = [[[BSAPIRequest alloc] initWithType:BSAPIRequestTypeAddData] autorelease];
    
    NSInteger endpoint = [[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue];
    
    [request setContactInfo:row];
    [request setEndpoint:(BSAPIEndpoint)endpoint];
    [request setDelegate:self];
    [request setSid:[[NSApp delegate] sid]];
    [request setDidFinishSelector:@selector(selectGroup:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    [self setInterfaceEnabled:NO];
    [request start];
}

// Retriving groups and getting data

- (void)updateGroupsArray
{
    BSAPIRequest    *request = [[[BSAPIRequest alloc] initWithType:BSAPIRequestTypeGetGroups] autorelease];
    
    NSInteger newEndpoint = [[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue];
    
    [request setEndpoint:(BSAPIEndpoint)newEndpoint];
    [request setDelegate:self];
    [request setSid:[[NSApp delegate] sid]];
    [request setDidFinishSelector:@selector(updatingGroups:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    BSAPIRequest    *chainRequest = [[[BSAPIRequest alloc] initWithType:BSAPIRequestTypeGetGroupData] autorelease];
    
    [chainRequest setEndpoint:(BSAPIEndpoint)newEndpoint];
    [chainRequest setDelegate:self];
    [chainRequest setSid:[[NSApp delegate] sid]];
    [chainRequest setDidFinishSelector:@selector(updatingData:)];
    [chainRequest setDidFailSelector:@selector(requestFailed:)];
    
    [request setChainRequest:chainRequest];
    [chainRequest release];
    [request start];
}

// Very left table action

- (IBAction)selectEndpoint:(id)sender
{
    NSInteger newEndpoint = [[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue];
    
    if (_prevEndpoint == newEndpoint)
        return;
    
    _prevEndpoint = newEndpoint;
    
    initialized = NO;
    NSDictionary    *formatter = [BSAPIRequest displayFormatDictionaryForEndpoint:(BSAPIEndpoint)newEndpoint];
    for (NSTableColumn *column in [_dataTableView tableColumns]) {
        
        if ([column identifier]) {
            
            if ([formatter objectForKey:[column identifier]]) {
                
                [[column headerCell] setStringValue:[formatter objectForKey:[column identifier]]];
                
            }
            
        }
        
    }
    [_groupsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [self setInterfaceEnabled:NO];
    [self updateGroupsArray];
}

// Group table action

- (IBAction)selectGroup:(id)sender
{
    NSInteger newGroupId = [[[_groups objectAtIndex:[_groupsTableView selectedRow]] objectForKey:@"id"] integerValue];
    
    if (_prevGroupId == newGroupId && sender && ![sender isKindOfClass:[NSDictionary class]])
        return;
    
    _prevGroupId = newGroupId;
    
    BSAPIRequest    *request = [[[BSAPIRequest alloc] initWithType:BSAPIRequestTypeGetGroupData] autorelease];
    
    if (newGroupId != -1)
        [request setGroupId:[NSString stringWithFormat:@"%ld",newGroupId]];
    
    NSInteger newEndpoint = [[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue];
    
    [request setEndpoint:(BSAPIEndpoint)newEndpoint];
    [request setDelegate:self];
    [request setSid:[[NSApp delegate] sid]];
    [request setDidFinishSelector:@selector(updatingData:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    [self setInterfaceEnabled:NO];
    
    [request start];
}

// Searchfield action

- (IBAction)searchContacts:(id)sender //Connected programmatically
{
    if (![[sender stringValue] length]) { // If no search string definded than we just need to update contact list
        [self selectGroup:nil];
        return;
    }
    
    NSInteger newGroupId = [[[_groups objectAtIndex:[_groupsTableView selectedRow]] objectForKey:@"id"] integerValue];
    BSAPIRequest    *request = [[[BSAPIRequest alloc] initWithType:BSAPIRequestTypeGetGroupData] autorelease];
    
    if (newGroupId != -1)
        [request setGroupId:[NSString stringWithFormat:@"%ld",newGroupId]];
    
    NSInteger newEndpoint = [[[_endpoints objectAtIndex:[_endpointsTableView selectedRow]] objectForKey:@"id"] integerValue];
    
    [request setEndpoint:(BSAPIEndpoint)newEndpoint];
    [request setSearchValue:[sender stringValue]];
    [request setDelegate:self];
    [request setSid:[[NSApp delegate] sid]];
    [request setDidFinishSelector:@selector(updatingData:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    [self setInterfaceEnabled:NO];
    
    [request start];
}

#pragma mark -
#pragma mark Handle window interface

- (void)setInterfaceEnabled:(BOOL)aFlag
{
    if (aFlag)
        [_spinner stopAnimation:nil];
    else
        [_spinner startAnimation:nil];
    [_addButton setEnabled:aFlag];
    [_editButton setEnabled:aFlag];
    [_removeButton setEnabled:aFlag];
    [_groupsTableView setEnabled:aFlag];
    [_dataTableView setEnabled:aFlag];
    [_endpointsTableView setEnabled:aFlag];
    [[(INAppStoreWindow *)[self window] searchField] setEnabled:aFlag];
}

@end

//
//  PTReportViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTReportViewController.h"
#import "PTModelController.h"
#import "PTJoggingEntryReportData.h"
#import "PTReportCell.h"
#import "PTDateUtils.h"
#import "PTStringUtils.h"
#import "PTNotificator.h"

static NSString* const kNibName                     = @"PTReportViewController";

PTUseLocalizationTableName(@"PTReportViewController");

@interface PTReportViewController () <UITableViewDataSource,
                                      UITableViewDelegate,
                                      PTNotificationsObserver>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* joggingEntriesReportData;

-(void) reloadData;

@end

@implementation PTReportViewController

+(instancetype) createFromNib
{
    return [[self alloc] initWithNibName:kNibName bundle:nil];
}

-(void) dealloc
{
    [[PTNotificator sharedNotificator] removeObserver:self];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = PTLS(@"Report");
    
    self.joggingEntriesReportData = [[PTModelController sharedController] fetchWeekReportDataForJoggingEntries];
    
    [self.tableView registerNib:[UINib nibWithNibName:[PTReportCell nibName] bundle:nil]
         forCellReuseIdentifier:[PTReportCell reuseIdentifier]];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = [PTReportCell height];
    self.tableView.tableFooterView = [UIView new];
    
    [[PTNotificator sharedNotificator] addObserver:self];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView*) tableView
{
    return [self.joggingEntriesReportData count];
}

-(NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section
{
    return 1;
}

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    PTReportCell* cell = [tableView dequeueReusableCellWithIdentifier:[PTReportCell reuseIdentifier] forIndexPath:indexPath];
    cell.reportData = self.joggingEntriesReportData[indexPath.section];
    [cell reloadData];
    
    return cell;
}

-(NSString*) tableView:(UITableView*) tableView titleForHeaderInSection:(NSInteger) section
{
    PTJoggingEntryReportData* reportData = self.joggingEntriesReportData[section];
    
    return PTLS(@"   %@ - %@",
                [PTStringUtils prettyDescriptionForDate:reportData.weekDate],
                [PTStringUtils prettyDescriptionForDate:[PTDateUtils weekEndForWeekStartDate:reportData.weekDate]]);
}

#pragma mark -
#pragma mark UITableViewDelegate methods

-(CGFloat) tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath
{
    return [PTReportCell height];
}

#pragma mark -
#pragma mark PTNotificationsObserver methods

-(void) observeDidAddSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    [self reloadData];
}

-(void) observeDidUpdateSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    [self reloadData];
}

-(void) observeDidDeleteSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    [self reloadData];
}

-(void) observeModelSyncDidUpdateStatus:(PTModelSyncStatus) syncStatus sender:(id) sender
{
    if(syncStatus != PTModelSyncStatusStarted)
    {
        [self reloadData];
    }
}

#pragma mark -
#pragma mark Private methods

-(void) reloadData
{
    self.joggingEntriesReportData = [[PTModelController sharedController] fetchWeekReportDataForJoggingEntries];
    [self.tableView reloadData];
}

@end

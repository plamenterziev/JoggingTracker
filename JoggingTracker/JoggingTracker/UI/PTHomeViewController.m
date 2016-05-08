//
//  PTHomeViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTHomeViewController.h"
#import "PTRefreshTableHeaderView.h"
#import "PTJoggingEntryCell.h"
#import "PTModelController.h"
#import "PTNotificator.h"
#import "PTJoggingEntryEditViewController.h"
#import "PTJoggingEntryViewController.h"
#import "PTFilterViewController.h"
#import "PTReportViewController.h"
#import "PTJoggingEntry.h"
#import "PTFilterOptions.h"
#import "PTStringUtils.h"

#import <UIActionSheet+Block.h>

static NSString* const kNibName                                 = @"PTHomeViewController";
static NSString* const kRefreshTableHeaderViewArrowImageName    = @"arrow";

PTUseLocalizationTableName(@"PTHomeViewController");

@interface PTHomeViewController () <UITableViewDataSource,
                                    UITableViewDelegate,
                                    PTJoggingEntryEditViewControllerDelegate,
                                    PTFilterViewControllerDelegate,
                                    PTRefreshTableHeaderViewDelegate,
                                    PTNotificationsObserver>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) PTRefreshTableHeaderView* refreshTableHeaderView;
@property (nonatomic, strong) NSArray* joggingEntries;
@property (nonatomic, strong) PTFilterOptions* filterOptions;

-(void) didTapAddBarButtonItem:(UIBarButtonItem*) sender;
-(void) didTapMenuBarButtonItem:(UIBarButtonItem*) sender;

-(void) updateTitle;

-(void) showReportViewController;
-(void) showFilterViewController;

@end

@implementation PTHomeViewController

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
    
    [self updateTitle];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                          target:self
                                                                                          action:@selector(didTapMenuBarButtonItem:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(didTapAddBarButtonItem:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.joggingEntries = [[PTModelController sharedController] fetchLocalJoggingEntriesWithFilter:self.filterOptions];
    
    [self.tableView registerNib:[UINib nibWithNibName:[PTJoggingEntryCell nibName] bundle:nil]
         forCellReuseIdentifier:[PTJoggingEntryCell reuseIdentifier]];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = [PTJoggingEntryCell height];
    
    self.refreshTableHeaderView = [[PTRefreshTableHeaderView alloc] initWithTableView:self.tableView];
    self.refreshTableHeaderView.arrowImage = [UIImage imageNamed:kRefreshTableHeaderViewArrowImageName];
    self.refreshTableHeaderView.backgroundView.backgroundColor = [UIColor blackColor];
    self.refreshTableHeaderView.backgroundView.alpha = 0.1f;
    self.refreshTableHeaderView.activityIndicatorViewColor = [UIColor blackColor];
    self.refreshTableHeaderView.delegate = self;
    
    if([PTModelController sharedController].isSyncing)
    {
        [self.refreshTableHeaderView beginRefreshingAnimated:NO];
    }
    
    [[PTNotificator sharedNotificator] addObserver:self];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

-(NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section
{
    return [self.joggingEntries count];
}

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    PTJoggingEntryCell* cell = [tableView dequeueReusableCellWithIdentifier:[PTJoggingEntryCell reuseIdentifier]
                                                               forIndexPath:indexPath];
    
    cell.joggingEntry = self.joggingEntries[indexPath.row];
    [cell reloadData];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

-(void) scrollViewDidScroll:(UIScrollView*) scrollView
{
    [self.refreshTableHeaderView tableViewDidScroll];
}

-(void) scrollViewDidEndDragging:(UIScrollView*) scrollView willDecelerate:(BOOL) decelerate
{
    [self.refreshTableHeaderView tableViewDidEndDragging];
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView*) scrollView
{
    [self.refreshTableHeaderView tableViewDidEndScrollingAnimation];
}

-(void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PTJoggingEntryViewController* joggingEntryViewController = [PTJoggingEntryViewController new];
    joggingEntryViewController.joggingEntry = [[PTJoggingEntry alloc] initWithManagedObject:self.joggingEntries[indexPath.row]];
    
    [self.navigationController pushViewController:joggingEntryViewController animated:YES];
}

-(CGFloat) tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath
{
    return [PTJoggingEntryCell height];
}

#pragma mark -
#pragma mark PTJoggingEntryEditViewControllerDelegate methods

-(void) joggingEntryEditViewControllerDidCancel:(PTJoggingEntryEditViewController*) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) joggingEntryEditViewController:(PTJoggingEntryEditViewController*) sender
                   didEditJoggingEntry:(PTJoggingEntry*) joggingEntry
{
    NSAssert(NO, @"Cannot edit jogging entries from home view controller");
}

-(void) joggingEntryEditViewController:(PTJoggingEntryEditViewController*) sender
                 didCreateJoggingEntry:(PTJoggingEntry*) joggingEntry
{
    [[PTModelController sharedController] saveJoggingEntry:joggingEntry notificationSender:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark PTFilterViewControllerDelegate methods

-(void) filterViewControllerDidCancel:(PTFilterViewController*) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) filterViewControllerDidRemoveFilterOptions:(PTFilterViewController*) sender
{
    self.filterOptions = nil;
    self.joggingEntries = [[PTModelController sharedController] fetchLocalJoggingEntriesWithFilter:self.filterOptions];
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) filterViewController:(PTFilterViewController*) sender didSelectFilterOptions:(PTFilterOptions*) filterOptions
{
    self.filterOptions = filterOptions;
    self.joggingEntries = [[PTModelController sharedController] fetchLocalJoggingEntriesWithFilter:self.filterOptions];
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark PTRefreshTableHeaderViewDelegate methods

-(void) refreshTableHeaderViewDidStartLoading:(PTRefreshTableHeaderView*) sender
{
    [[PTModelController sharedController] startSync];
}

#pragma mark -
#pragma mark PTNotificationsObserver methods

-(void) observeModelSyncDidUpdateStatus:(PTModelSyncStatus) syncStatus sender:(id) sender
{
    if(syncStatus == PTModelSyncStatusStarted)
    {
        [self.refreshTableHeaderView beginRefreshingAnimated:YES];
    }
    else
    {
        [self.refreshTableHeaderView endRefreshingAnimated:YES];
        
        self.joggingEntries = [[PTModelController sharedController] fetchLocalJoggingEntriesWithFilter:self.filterOptions];
        [self.tableView reloadData];
    }
}

-(void) observeDidAddSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    if([object isKindOfClass:[PTJoggingEntry class]])
    {
        if(!self.filterOptions || [self.filterOptions containsDate:((PTJoggingEntry*) object).date])
        {
            self.joggingEntries = [[PTModelController sharedController] fetchLocalJoggingEntriesWithFilter:self.filterOptions];
            [self.tableView reloadData];
        }
    }
}

-(void) observeDidUpdateSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    if([object isKindOfClass:[PTJoggingEntry class]])
    {
        if(!self.filterOptions || [self.filterOptions containsDate:((PTJoggingEntry*) object).date])
        {
            self.joggingEntries = [[PTModelController sharedController] fetchLocalJoggingEntriesWithFilter:self.filterOptions];
            [self.tableView reloadData];
        }
    }
}

-(void) observeDidDeleteSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    if([object isKindOfClass:[PTJoggingEntry class]])
    {
        if(!self.filterOptions || [self.filterOptions containsDate:((PTJoggingEntry*) object).date])
        {
            self.joggingEntries = [[PTModelController sharedController] fetchLocalJoggingEntriesWithFilter:self.filterOptions];
            [self.tableView reloadData];
        }
    }
}

#pragma mark -
#pragma mark Private methods

-(void) setFilterOptions:(PTFilterOptions*) filterOptions
{
    _filterOptions = filterOptions;
    
    [self updateTitle];
}

-(void) didTapAddBarButtonItem:(UIBarButtonItem*) sender
{
    PTJoggingEntryEditViewController* joggingEntryEditViewController = [PTJoggingEntryEditViewController createFromNib];
    joggingEntryEditViewController.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:joggingEntryEditViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void) didTapMenuBarButtonItem:(UIBarButtonItem*) sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:PTLS(@"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@[PTLS(@"Report"),
                                                                        PTLS(@"Filter"),
                                                                        PTLS(@"Log Out")]];
    [actionSheet showFromBarButtonItem:sender
                              animated:YES
                            usingBlock:^(UIActionSheet* actionSheet, NSInteger buttonIndex) {
                                switch(buttonIndex) {
                                    case 0:
                                        break;
                                    case 1:
                                        [self showReportViewController];
                                        break;
                                    case 2:
                                        [self showFilterViewController];
                                        break;
                                    case 3:
                                        [[PTNotificator sharedNotificator] notifyRequestLogout:self];
                                        break;
                                    default:
                                        NSAssert(NO, @"Invalid button index: %d", buttonIndex);
                                        break;
                                }
                            }];
}

-(void) updateTitle
{
    self.title = (self.filterOptions ?
                  PTLS(@"%@ - %@",
                       [PTStringUtils prettyDescriptionForDate:self.filterOptions.fromDate],
                       [PTStringUtils prettyDescriptionForDate:self.filterOptions.toDate]) :
                  PTLS(@"Jogging"));
}

-(void) showReportViewController
{
    PTReportViewController* reportViewController = [PTReportViewController createFromNib];
    
    [self.navigationController pushViewController:reportViewController animated:YES];
}

-(void) showFilterViewController
{
    PTFilterViewController* filterViewController = [PTFilterViewController createFromNib];
    filterViewController.filterOptions = self.filterOptions;
    filterViewController.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:filterViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end

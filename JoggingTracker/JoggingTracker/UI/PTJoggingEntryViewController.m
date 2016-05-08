//
//  PTJoggingEntryViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTJoggingEntryViewController.h"
#import "PTTitledElementView.h"
#import "PTJoggingEntry.h"
#import "PTStringUtils.h"
#import "PTUIUtils.h"
#import "PTNotificator.h"
#import "PTModelController.h"
#import "PTJoggingEntryEditViewController.h"

#import <UIActionSheet+Block.h>

static NSString* const kNibName             = @"PTJoggingEntryViewController";

PTUseLocalizationTableName(@"PTJoggingEntryViewController");

@interface PTJoggingEntryViewController () <PTJoggingEntryEditViewControllerDelegate,
                                            PTNotificationsObserver>

@property (nonatomic, weak) IBOutlet UIView* timeElementContainerView;
@property (nonatomic, weak) IBOutlet UIView* distanceElementContainerView;
@property (nonatomic, weak) IBOutlet UIView* speedElementContainerView;
@property (nonatomic, strong) PTTitledElementView* timeTitledElementView;
@property (nonatomic, strong) PTTitledElementView* distanceTitledElementView;
@property (nonatomic, strong) PTTitledElementView* speedTitledElementView;

-(IBAction) didTapEditButton:(UIButton*) sender;
-(IBAction) didTapDeleteButton:(UIButton*) sender;

-(void) reloadData;
-(void) updateWithJoggingEntry:(PTJoggingEntry*) joggingEntry;
-(void) handleDeletedJoggingEntry;

@end

@implementation PTJoggingEntryViewController

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
    
    self.title = [PTStringUtils prettyDescriptionForDateTime:self.joggingEntry.date];
    
    self.timeTitledElementView = [PTTitledElementView createFromNib];
    [self.timeElementContainerView addSubview:self.timeTitledElementView];
    [PTUIUtils addLayoutConstraintsToMatchSuperViewBounds:self.timeTitledElementView];
    
    self.distanceTitledElementView = [PTTitledElementView createFromNib];
    [self.distanceElementContainerView addSubview:self.distanceTitledElementView];
    [PTUIUtils addLayoutConstraintsToMatchSuperViewBounds:self.distanceTitledElementView];
    
    self.speedTitledElementView = [PTTitledElementView createFromNib];
    [self.speedElementContainerView addSubview:self.speedTitledElementView];
    [PTUIUtils addLayoutConstraintsToMatchSuperViewBounds:self.speedTitledElementView];
    
    [self reloadData];
    
    [[PTNotificator sharedNotificator] addObserver:self];
}

#pragma mark -
#pragma mark PTJoggingEntryEditViewControllerDelegate methods

-(void) joggingEntryEditViewController:(PTJoggingEntryEditViewController*) sender didCreateJoggingEntry:(PTJoggingEntry*) joggingEntry
{
    NSAssert(NO, @"Cannot create jogging entries from jogging entry view controller");
}

-(void) joggingEntryEditViewController:(PTJoggingEntryEditViewController*) sender didEditJoggingEntry:(PTJoggingEntry*) joggingEntry
{
    BOOL result = [[PTModelController sharedController] saveJoggingEntry:joggingEntry notificationSender:self];
    if(!result)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:PTLS(@"Unable to edit jogging entry. Please try again.")
                                                           delegate:nil
                                                  cancelButtonTitle:PTLS(@"OK")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [self updateWithJoggingEntry:joggingEntry];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) joggingEntryEditViewControllerDidCancel:(PTJoggingEntryEditViewController*) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark PTNotificationsObserver methods

-(void) observeModelSyncDidUpdateStatus:(PTModelSyncStatus) modelSyncStatus sender:(id) sender
{
    if(modelSyncStatus != PTModelSyncStatusStarted)
    {
        PTJoggingEntry* updateJoggingEntry = [[PTModelController sharedController] fetchUpdatedJoggingEntryForJoggingEntry:self.joggingEntry];
        if(!updateJoggingEntry)
        {
            [self handleDeletedJoggingEntry];
        }
        else
        {
            self.joggingEntry = updateJoggingEntry;
            [self reloadData];
        }
    }
}

-(void) observeDidUpdateSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    if(sender != self && [self.joggingEntry isEqualToSynchronisableObject:object])
    {
        NSAssert([object isKindOfClass:[PTJoggingEntry class]], @"Invalid object: %@", object);
        
        [self updateWithJoggingEntry:((PTJoggingEntry*) object)];
    }
}

-(void) observeDidDeleteSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    if(sender != self && [self.joggingEntry isEqualToSynchronisableObject:object])
    {
        [self handleDeletedJoggingEntry];
    }
}

#pragma mark -
#pragma mark Private methods

-(IBAction) didTapEditButton:(UIButton*) sender
{
    PTJoggingEntryEditViewController* joggingEntryEditViewController = [PTJoggingEntryEditViewController createFromNib];
    joggingEntryEditViewController.delegate = self;
    joggingEntryEditViewController.joggingEntry = self.joggingEntry;
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:joggingEntryEditViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(IBAction) didTapDeleteButton:(UIButton*) sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:PTLS(@"Confirm delete?")
                                                    cancelButtonTitle:PTLS(@"Cancel")
                                               destructiveButtonTitle:PTLS(@"Delete")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view usingBlock:^(UIActionSheet* actionSheet, NSInteger buttonIndex) {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            BOOL result = [[PTModelController sharedController] deleteJoggingEntry:self.joggingEntry notificationSender:self];
            if(result)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:PTLS(@"Unale to delete jogging entry. Please try again.")
                                                                   delegate:nil
                                                          cancelButtonTitle:PTLS(@"OK")
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

-(void) reloadData
{
    self.timeTitledElementView.titleLabel.text = PTLS(@"Time");
    self.timeTitledElementView.detailsLabel.text = [PTStringUtils prettyDescriptionForTimeInSeconds:self.joggingEntry.time];

    self.distanceTitledElementView.titleLabel.text = PTLS(@"Distance");
    self.distanceTitledElementView.detailsLabel.text = [PTStringUtils prettyDescriptionForDistanceInMeters:self.joggingEntry.distance];

    self.speedTitledElementView.titleLabel.text = PTLS(@"Average speed");
    self.speedTitledElementView.detailsLabel.text = [PTStringUtils prettyDescriptionForSpeedForMeters:self.joggingEntry.distance
                                                                                           forSeconds:self.joggingEntry.time];
}
                      
-(void) updateWithJoggingEntry:(PTJoggingEntry*) joggingEntry
{
    self.joggingEntry = joggingEntry;
    self.title = [PTStringUtils prettyDescriptionForDateTime:joggingEntry.date];
    
    [self reloadData];
}

-(void) handleDeletedJoggingEntry
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:PTLS(@"Jogging entry was deleted.")
                                                       delegate:nil
                                              cancelButtonTitle:PTLS(@"OK")
                                              otherButtonTitles:nil];
    [alertView show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

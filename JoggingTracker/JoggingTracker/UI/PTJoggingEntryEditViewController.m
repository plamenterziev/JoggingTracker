//
//  PTJoggingEntryEditViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTJoggingEntryEditViewController.h"
#import "PTJoggingEntry.h"
#import "PTGUIDUtils.h"
#import "PTStringUtils.h"
#import "PTTimePickerView.h"
#import "PTDistancePickerView.h"

static NSString* const kNibName                 = @"PTJoggingEntryEditViewController";

PTUseLocalizationTableName(@"PTJoggingEntryEditViewController");

@interface PTJoggingEntryEditViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView* outletScrollView;
@property (nonatomic, weak) IBOutlet UITextField* dateTextField;
@property (nonatomic, weak) IBOutlet UITextField* distanceTextField;
@property (nonatomic, weak) IBOutlet UITextField* timeTextField;
@property (nonatomic) BOOL isAddingNewJoggingEntry;

-(void) didTapCancelBarButtonItem:(UIBarButtonItem*) sender;
-(void) didTapActionBarButtonItem:(UIBarButtonItem*) sender;
-(void) didSelectDate:(UIDatePicker*) datePicker;
-(void) didSelectDistance:(PTDistancePickerView*) distancePicker;
-(void) didSelectTime:(PTTimePickerView*) timePicker;

-(void) updateActionBarButton;

@end

@implementation PTJoggingEntryEditViewController

+(instancetype) createFromNib
{
    return [[self alloc] initWithNibName:kNibName bundle:nil];
}

-(UIScrollView*) mainScrollView
{
    return self.outletScrollView;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.isAddingNewJoggingEntry = !self.joggingEntry;
    self.title = (self.joggingEntry ? PTLS(@"Edit") : PTLS(@"Add"));
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(didTapCancelBarButtonItem:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(self.joggingEntry ?
                                                                                                   UIBarButtonSystemItemDone :
                                                                                                   UIBarButtonSystemItemAdd)
                                                                                           target:self
                                                                                           action:@selector(didTapActionBarButtonItem:)];
    
    if(!self.joggingEntry)
    {
        self.joggingEntry = [PTJoggingEntry new];
    }
    
    UIDatePicker* datePicker = [UIDatePicker new];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self
                   action:@selector(didSelectDate:)
         forControlEvents:UIControlEventValueChanged];
    self.dateTextField.inputView = datePicker;
    
    PTDistancePickerView* distancePicker = [PTDistancePickerView new];
    [distancePicker addTarget:self
                       action:@selector(didSelectDistance:)
             forControlEvents:UIControlEventValueChanged];
    self.distanceTextField.inputView = distancePicker;
    
    PTTimePickerView* timePicker = [PTTimePickerView new];
    [timePicker addTarget:self
                   action:@selector(didSelectTime:)
         forControlEvents:UIControlEventValueChanged];
    self.timeTextField.inputView = timePicker;
    
    [self.dateTextField becomeFirstResponder];
    [datePicker setDate:(self.joggingEntry.date ? self.joggingEntry.date : [NSDate date]) animated:NO];
    [self didSelectDate:datePicker];
    
    if(!self.isAddingNewJoggingEntry)
    {
        [distancePicker setDistanceInMeters:self.joggingEntry.distance animated:NO];
        [self didSelectDistance:distancePicker];
        
        [timePicker setTimeInSeconds:self.joggingEntry.time animated:NO];
        [self didSelectTime:timePicker];
    }
}

#pragma mark -
#pragma mark UItextFieldDelegate methods
    
#pragma mark -
#pragma mark Private methods

-(void) didTapCancelBarButtonItem:(UIBarButtonItem*) sender
{
    [self.delegate joggingEntryEditViewControllerDidCancel:self];
}

-(void) didTapActionBarButtonItem:(UIBarButtonItem*) sender
{
    if(self.isAddingNewJoggingEntry)
    {
        self.joggingEntry.clientSideObjectID = [PTGUIDUtils createGUID];
        [self.delegate joggingEntryEditViewController:self didCreateJoggingEntry:self.joggingEntry];
    }
    else
    {
        [self.delegate joggingEntryEditViewController:self didEditJoggingEntry:self.joggingEntry];
    }
}

-(void) didSelectDate:(UIDatePicker*) datePicker
{
    self.joggingEntry.date = datePicker.date;
    self.dateTextField.text = [PTStringUtils prettyDescriptionForDateTime:datePicker.date];
    
    [self updateActionBarButton];
}

-(void) didSelectDistance:(PTDistancePickerView*) distancePicker
{
    self.joggingEntry.distance = distancePicker.distanceInMeters;
    self.distanceTextField.text = [PTStringUtils prettyDescriptionForDistanceInMeters:distancePicker.distanceInMeters];
    
    [self updateActionBarButton];
}

-(void) didSelectTime:(PTTimePickerView*) timePicker
{
    self.joggingEntry.time = timePicker.timeInSeconds;
    self.timeTextField.text = [PTStringUtils prettyDescriptionForTimeInSeconds:timePicker.timeInSeconds];
    
    [self updateActionBarButton];
}

-(void) updateActionBarButton
{
    self.navigationItem.rightBarButtonItem.enabled = ([self.dateTextField.text length] > 0 &&
                                                      [self.distanceTextField.text length] > 0 &&
                                                      [self.timeTextField.text length] > 0);
}

@end

//
//  PTFilterViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTFilterViewController.h"
#import "PTFilterOptions.h"
#import "PTStringUtils.h"
#import "PTDateUtils.h"

#import <UIAlertView+Block.h>

static NSString* const kNibName                      = @"PTFilterViewController";

PTUseLocalizationTableName(@"PTFilterViewController");

@interface PTFilterViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView* outletScrollView;
@property (nonatomic, weak) IBOutlet UITextField* fromDateTextField;
@property (nonatomic, weak) IBOutlet UITextField* toDateTextField;
@property (nonatomic, weak) IBOutlet UIButton* removeButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* removeButtonTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* textFieldContainerBottomConstraint;
@property (nonatomic) BOOL isAddingNewFilter;

-(IBAction) didTapRemoveButton:(UIButton*) sender;
-(void) didTapCancelBarButtonItem:(UIBarButtonItem*) sender;
-(void) didTapApplyBarButtonItem:(UIBarButtonItem*) sender;
-(void) didSelectFromDate:(UIDatePicker*) datePicker;
-(void) didSelectToDate:(UIDatePicker*) datePicker;

-(void) showRemoveButton:(BOOL) show;
-(void) updateApplyButton;
-(BOOL) validateFields;

@end

@implementation PTFilterViewController

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
    
    self.title = PTLS(@"Select filter");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(didTapCancelBarButtonItem:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:PTLS(@"Apply")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(didTapApplyBarButtonItem:)];
    
    UIDatePicker* fromDatePicker = [UIDatePicker new];
    fromDatePicker.datePickerMode = UIDatePickerModeDate;
    [fromDatePicker addTarget:self
                       action:@selector(didSelectFromDate:)
             forControlEvents:UIControlEventValueChanged];
    self.fromDateTextField.inputView = fromDatePicker;
    
    UIDatePicker* toDatePicker = [UIDatePicker new];
    toDatePicker.datePickerMode = UIDatePickerModeDate;
    [toDatePicker addTarget:self
                     action:@selector(didSelectToDate:)
           forControlEvents:UIControlEventValueChanged];
    self.toDateTextField.inputView = toDatePicker;
  
    self.isAddingNewFilter = !self.filterOptions;
    if(self.isAddingNewFilter)
    {
        [fromDatePicker setDate:[NSDate date] animated:NO];
        self.filterOptions = [PTFilterOptions new];
    }
    else
    {
        [fromDatePicker setDate:self.filterOptions.fromDate animated:NO];
        
        [toDatePicker setDate:self.filterOptions.toDate animated:NO];
        [self didSelectToDate:toDatePicker];
    }
    
    [self.fromDateTextField becomeFirstResponder];
    [self didSelectFromDate:fromDatePicker];
    
    [self showRemoveButton:!self.isAddingNewFilter];
}

#pragma mark -
#pragma mark Private methods

-(IBAction) didTapRemoveButton:(UIButton*) sender
{
    [self.delegate filterViewControllerDidRemoveFilterOptions:self];
}

-(void) didTapCancelBarButtonItem:(UIBarButtonItem*) sender
{
    [self.delegate filterViewControllerDidCancel:self];
}

-(void) didTapApplyBarButtonItem:(UIBarButtonItem*) sender
{
    if([self validateFields])
    {
        [self.delegate filterViewController:self didSelectFilterOptions:self.filterOptions];
    }
}

-(void) didSelectFromDate:(UIDatePicker*) datePicker
{
    NSDate* date = [PTDateUtils dayStartForDate:datePicker.date];
    
    self.filterOptions.fromDate = date;
    self.fromDateTextField.text = [PTStringUtils prettyDescriptionForDate:date];
    
    [self updateApplyButton];
}

-(void) didSelectToDate:(UIDatePicker*) datePicker
{
    NSDate* date = [PTDateUtils dayEndForDate:datePicker.date];
    
    self.filterOptions.toDate = date;
    self.toDateTextField.text = [PTStringUtils prettyDescriptionForDate:date];
    
    [self updateApplyButton];
}

-(void) showRemoveButton:(BOOL) show
{
    self.removeButton.hidden = !show;
    self.removeButtonTopConstraint.priority = (show ? 999.0f : 1.0f);
    self.textFieldContainerBottomConstraint.priority = (show ? 1.0f : 999.0f);
}

-(void) updateApplyButton
{
    self.navigationItem.rightBarButtonItem.enabled = (self.filterOptions.fromDate != nil && self.filterOptions.toDate != nil);
}

-(BOOL) validateFields
{
    UITextField* invalidTextField = nil;
    NSString* errorDescription = nil;

    if([self.filterOptions.fromDate compare:self.filterOptions.toDate] == NSOrderedDescending)
    {
        invalidTextField = self.toDateTextField;
        errorDescription = PTLS(@"'To date' is before 'from date'");
    }
    
    if(errorDescription)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithMessage:errorDescription cancelButtonTitle:PTLS(@"OK")];
        [alertView showUsingBlock:^(UIAlertView* alertView, NSInteger buttonIndex) {
            [invalidTextField becomeFirstResponder];
        }];
    }
    
    return !invalidTextField;
}

@end

//
//  PTTimePickerView.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTTimePickerView.h"
#import "PTStringUtils.h"

PTUseLocalizationTableName(@"PTTimePickerView");

@interface PTTimePickerView () <UIPickerViewDataSource,
                                UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView* pickerView;

-(void) setup;

@end

@implementation PTTimePickerView

-(instancetype) initWithFrame:(CGRect) frame
{
    if((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    
    return self;
}

-(NSInteger) timeInSeconds
{
    return (3600 * [self.pickerView selectedRowInComponent:0] + 60 * [self.pickerView selectedRowInComponent:1]);
}

-(void) setTimeInSeconds:(NSInteger) timeInSeconds animated:(BOOL) animated
{
    NSInteger hours = (timeInSeconds / 3600);
    NSInteger minutes = ((timeInSeconds % 3600) / 60);
    
    [self.pickerView selectRow:hours inComponent:0 animated:animated];
    [self.pickerView selectRow:minutes inComponent:1 animated:animated];
}

#pragma mark -
#pragma mark UIPickerViewDataSource method

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView*) pickerView
{
    return 2;
}

-(NSInteger) pickerView:(UIPickerView*) pickerView numberOfRowsInComponent:(NSInteger) component
{
    NSInteger rowsCount = 0;
    switch(component)
    {
        case 0:
            rowsCount = 24;
            break;
        case 1:
            rowsCount = 60;
            break;
        default:
            NSAssert(NO, @"Invalid component index: %d", component);
            break;
    }
    
    return rowsCount;
}

#pragma mark -
#pragma mark UIPickerViewDelegate method

-(NSString*) pickerView:(UIPickerView*) pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
{
    NSString* rowTitle = nil;
    switch(component)
    {
        case 0:
            rowTitle = PTLS(@"%@ hours", [PTStringUtils stringFromInteger:row]);
            break;
        case 1:
            rowTitle = PTLS(@"%@ mins", [PTStringUtils stringFromInteger:row]);
            break;
        default:
            NSAssert(NO, @"Invalid component index: %d", component);
            break;
    }
    
    return rowTitle;
}

-(void) pickerView:(UIPickerView*) pickerView didSelectRow:(NSInteger) row inComponent:(NSInteger) component
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark -
#pragma mark Private methods

-(void) setup
{
    self.pickerView = [UIPickerView new];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self addSubview:self.pickerView];
    self.frame = self.pickerView.frame;
}

@end

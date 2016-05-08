//
//  PTDistancePickerView.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTDistancePickerView.h"
#import "PTStringUtils.h"

PTUseLocalizationTableName(@"PTDistancePickerView");

@interface PTDistancePickerView () <UIPickerViewDataSource,
                                    UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView* pickerView;

-(void) setup;

@end

@implementation PTDistancePickerView

-(instancetype) initWithFrame:(CGRect) frame
{
    if((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    
    return self;
}

-(NSInteger) distanceInMeters
{
    return (1000 * [self.pickerView selectedRowInComponent:0] + [self.pickerView selectedRowInComponent:1]);
}

-(void) setDistanceInMeters:(NSInteger) distanceInMeters animated:(BOOL) animated
{
    NSInteger kilometers = (distanceInMeters / 1000);
    NSInteger meters = (distanceInMeters % 1000);
    
    [self.pickerView selectRow:kilometers inComponent:0 animated:animated];
    [self.pickerView selectRow:meters inComponent:1 animated:animated];
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
            rowsCount = 999;
            break;
        case 1:
            rowsCount = 999;
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
            rowTitle = PTLS(@"%@ km", [PTStringUtils stringFromInteger:row]);
            break;
        case 1:
            rowTitle = PTLS(@"%@ m", [PTStringUtils stringFromInteger:row]);
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

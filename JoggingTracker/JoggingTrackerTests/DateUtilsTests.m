//
//  DateUtilsTests.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PTDateUtils.h"

@interface DateUtilsTests : XCTestCase

@property (nonatomic, strong) NSCalendar* calendar;

-(NSDateComponents*) dateComponentsForDate:(NSDate*) date;

@end

@implementation DateUtilsTests

-(void) setUp
{
    [super setUp];
    self.calendar = [NSCalendar currentCalendar];
}

-(void) testDayStartForDate
{
    NSDate* nowDate = [NSDate date];
    NSDate* dayStartDate = [PTDateUtils dayStartForDate:nowDate];
    
    NSDateComponents* nowDateComponents = [self dateComponentsForDate:nowDate];
    NSDateComponents* dayStartDateComponents = [self dateComponentsForDate:dayStartDate];
    
    XCTAssertEqual([nowDateComponents year], [dayStartDateComponents year], @"");
    XCTAssertEqual([nowDateComponents month], [dayStartDateComponents month], @"");
    XCTAssertEqual([nowDateComponents day], [dayStartDateComponents day], @"");
    XCTAssertEqual([dayStartDateComponents hour], 0, @"");
    XCTAssertEqual([dayStartDateComponents minute], 0, @"");
    XCTAssertEqual([dayStartDateComponents second], 0, @"");
}

-(void) testDayEndForDate
{
    NSDate* nowDate = [NSDate date];
    NSDate* dayEndDate = [PTDateUtils dayEndForDate:nowDate];
    
    NSDateComponents* nowDateComponents = [self dateComponentsForDate:nowDate];
    NSDateComponents* dayEndDateComponents = [self dateComponentsForDate:dayEndDate];
    
    XCTAssertEqual([nowDateComponents year], [dayEndDateComponents year], @"");
    XCTAssertEqual([nowDateComponents month], [dayEndDateComponents month], @"");
    XCTAssertEqual([nowDateComponents day], [dayEndDateComponents day], @"");
    XCTAssertEqual([dayEndDateComponents hour], 23, @"");
    XCTAssertEqual([dayEndDateComponents minute], 59, @"");
    XCTAssertEqual([dayEndDateComponents second], 59, @"");
}

-(void) testWeekStartForDate
{
    NSDate* nowDate = [NSDate date];
    NSDate* weekStartDate = [PTDateUtils weekStartForDate:nowDate];
    
    NSDateComponents* nowDateComponents = [self dateComponentsForDate:nowDate];
    NSDateComponents* weekStartDateComponents = [self dateComponentsForDate:weekStartDate];
    
    XCTAssertTrue([nowDateComponents year] >= [weekStartDateComponents year], @"");
    XCTAssertEqual([weekStartDateComponents hour], 0, @"");
    XCTAssertEqual([weekStartDateComponents minute], 0, @"");
    XCTAssertEqual([weekStartDateComponents second], 0, @"");
}

-(void) testWeekEndForDate
{
    NSDate* nowDate = [NSDate date];
    
    NSDate* weekStartDate = [PTDateUtils weekStartForDate:nowDate];
    NSDate* weekEndDate = [PTDateUtils weekEndForWeekStartDate:weekStartDate];
    
    NSDateComponents* weekStartDateComponents = [self dateComponentsForDate:weekStartDate];
    NSDateComponents* weekEndDateComponents = [self dateComponentsForDate:weekEndDate];
    
    XCTAssertTrue([weekEndDateComponents year] >= [weekStartDateComponents year], @"");
    XCTAssertEqual([weekEndDateComponents hour], 23, @"");
    XCTAssertEqual([weekEndDateComponents minute], 59, @"");
    XCTAssertEqual([weekEndDateComponents second], 59, @"");
}

#pragma mark -
#pragma mark Private methods

-(NSDateComponents*) dateComponentsForDate:(NSDate*) date
{
    return [self.calendar components:(NSYearCalendarUnit |
                                      NSMonthCalendarUnit|
                                      NSDayCalendarUnit |
                                      NSHourCalendarUnit |
                                      NSMinuteCalendarUnit |
                                      NSSecondCalendarUnit)
                            fromDate:date];
}

@end

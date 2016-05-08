//
//  PTDateUtils.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTDateUtils.h"

@implementation PTDateUtils

+(NSDate*) dayStartForDate:(NSDate*) date
{
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit |
                                                                                 NSMonthCalendarUnit|
                                                                                 NSDayCalendarUnit)
                                                                       fromDate:date];
    
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

+(NSDate*) dayEndForDate:(NSDate*) date
{
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit |
                                                                                 NSMonthCalendarUnit|
                                                                                 NSDayCalendarUnit |
                                                                                 NSHourCalendarUnit |
                                                                                 NSMinuteCalendarUnit |
                                                                                 NSSecondCalendarUnit)
                                                                       fromDate:date];
    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];
    
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

+(NSDate*) weekStartForDate:(NSDate*) date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents* componentsToSubtract = [NSDateComponents new];
    
    [componentsToSubtract setDay: -([weekdayComponents weekday] - [calendar firstWeekday])];
    NSDate* beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:date options:0];
    

    return [self dayStartForDate:beginningOfWeek];
}

+(NSDate*) weekEndForWeekStartDate:(NSDate*) date
{
    NSDateComponents* componentsToAdd = [NSDateComponents new];
    
    [componentsToAdd setDay:7];
    [componentsToAdd setSecond:-1];
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:componentsToAdd toDate:date options:0];
}

@end

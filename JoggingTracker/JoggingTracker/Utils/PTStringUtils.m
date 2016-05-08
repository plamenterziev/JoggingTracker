//
//  PTStringUtils.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTStringUtils.h"

PTUseLocalizationTableName(@"PTStringUtils");

@implementation PTStringUtils

+(NSString*) stringFromInteger:(NSInteger) integer
{
    return [NSString stringWithFormat:@"%d", integer];
}

+(NSString*) prettyDescriptionForDateTime:(NSDate*) date
{
    static NSDateFormatter* dateFormatter = nil;
    if(!dateFormatter)
    {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"dd MMM yyyy 'at' HH:mm"];
    }

    return [dateFormatter stringFromDate:date];
}

+(NSString*) prettyDescriptionForDate:(NSDate*) date
{
    static NSDateFormatter* dateFormatter = nil;
    if(!dateFormatter)
    {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"dd MMM yyyy"];
    }
    
    return [dateFormatter stringFromDate:date];

}

+(NSString*) prettyDescriptionForTimeInSeconds:(NSInteger) time
{
    NSInteger hours = (time / 3600);
    NSInteger minutes = ((time % 3600) / 60);
    
    return PTLS(@"%d h and %d min", hours, minutes);
}

+(NSString*) prettyDescriptionForDistanceInMeters:(NSInteger) distance
{
    NSInteger kilometers = (distance / 1000);
    NSInteger meters = (distance % 1000);
    
    return PTLS(@"%d km and %d m", kilometers, meters);
}

+(NSString*) prettyDescriptionForSpeedForMeters:(NSInteger) distance
                                     forSeconds:(NSInteger) seconds
{
    NSString* description = nil;
    if(seconds <= 0)
    {
        description = PTLS(@"∞");
    }
    else
    {
        CGFloat speed = ((CGFloat)(distance * 36) / (CGFloat)(seconds * 10));
        description = PTLS(@"%.2f km/h", speed);
    }
    
    return description;
}

@end

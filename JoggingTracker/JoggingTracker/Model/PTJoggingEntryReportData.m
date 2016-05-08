//
//  PTJoggingEntryReportData.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTJoggingEntryReportData.h"

@interface PTJoggingEntryReportData ()

@property (nonatomic) NSInteger time;
@property (nonatomic) BOOL isTimeLoaded;
@property (nonatomic) NSInteger distance;
@property (nonatomic) BOOL isDistanceLoaded;
@property (nonatomic) CGFloat averageSpeed;
@property (nonatomic, strong) NSDate* weekDate;
@property (nonatomic, strong) NSDictionary* dictionary;

@end

@implementation PTJoggingEntryReportData

-(instancetype) initWithDictionary:(NSDictionary*) dictionary
{
    if((self = [super init]))
    {
        _dictionary = dictionary;
    }
    
    return self;
}

-(NSInteger) time
{
    if(!self.isTimeLoaded)
    {
        NSNumber* timeSum = self.dictionary[@"timeSum"];
        NSAssert(timeSum, @"Unable to find timeSum in dictionary: %@", self.dictionary);
        _time = [timeSum integerValue];
        self.isTimeLoaded = YES;
    }
    
    return _time;
}

-(NSInteger) distance
{
    if(!self.isDistanceLoaded)
    {
        NSNumber* distanceSum = self.dictionary[@"distanceSum"];
        NSAssert(distanceSum, @"Unable to find distanceSum in dictionary: %@", self.dictionary);
        _distance = [distanceSum integerValue];
        self.isDistanceLoaded = YES;
    }
    
    return _distance;
}

-(CGFloat) averageSpeed
{
    return ((CGFloat)(self.distance * 36) / (CGFloat)(self.time * 10));
}

-(NSDate*) weekDate
{
    if(!_weekDate)
    {
        _weekDate = self.dictionary[@"weekDate"];
        NSAssert(_weekDate, @"Unable to find weekDate in dictionary: %@", self.dictionary);
    }
    
    return _weekDate;
}

@end

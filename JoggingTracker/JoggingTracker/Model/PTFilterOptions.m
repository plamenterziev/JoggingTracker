//
//  PTFilterOptions.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTFilterOptions.h"

@implementation PTFilterOptions

-(id) copyWithZone:(NSZone*) zone
{
    PTFilterOptions* copy = [[self class] new];
    
    copy.fromDate = self.fromDate;
    copy.toDate = self.toDate;
    
    return copy;
}

-(BOOL) containsDate:(NSDate*) date
{
    return ([self.fromDate compare:date] != NSOrderedDescending && [self.toDate compare:date] != NSOrderedAscending);
}

@end

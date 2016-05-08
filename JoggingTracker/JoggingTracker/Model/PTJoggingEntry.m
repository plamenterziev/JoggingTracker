//
//  PTJoggingEntry.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTJoggingEntry.h"
#import "PTManagedJoggingEntry.h"
#import "PTDateUtils.h"

@implementation PTJoggingEntry

-(instancetype) initWithManagedObject:(PTManagedSynchronisableObject*) managedObject
{
    if((self = [super initWithManagedObject:managedObject]))
    {
        if([managedObject isKindOfClass:[PTManagedJoggingEntry class]])
        {
            self.date = ((PTManagedJoggingEntry*) managedObject).date;
            self.time = [((PTManagedJoggingEntry*) managedObject).time integerValue];
            self.distance = [((PTManagedJoggingEntry*) managedObject).distance integerValue];
        }
        else
        {
            NSAssert(NO, @"Invalid class: %@", [managedObject class]);
            self = nil;
        }
    }
    
    return self;
}

-(id) copyWithZone:(NSZone*) zone
{
    PTJoggingEntry* copy = [super copyWithZone:zone];
    
    copy.date = [self.date copy];
    copy.time = self.time;
    copy.distance = self.distance;
    
    return copy;
}

-(void) exportToManagedObject:(PTManagedSynchronisableObject*) managedObject
{
    NSAssert([managedObject isKindOfClass:[PTManagedJoggingEntry class]], @"Invalid class: %@", [managedObject class]);
    
    [super exportToManagedObject:managedObject];
    
    PTManagedJoggingEntry* managedJoggingEntry = (PTManagedJoggingEntry*) managedObject;
    managedJoggingEntry.date = self.date;
    managedJoggingEntry.time = @(self.time);
    managedJoggingEntry.distance = @(self.distance);

    NSDate* date = [PTDateUtils weekStartForDate:self.date];
    managedJoggingEntry.weekDate = date;
}

@end

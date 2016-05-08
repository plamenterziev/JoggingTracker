//
//  PTNotificator.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTNotificator.h"

@interface PTNotificator ()

@property (nonatomic, strong) NSMutableArray* mutableNonretainedObservers;

@end

@implementation PTNotificator

static PTNotificator* theNotificator = nil;

+(instancetype) sharedNotificator
{
    if(!theNotificator)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            theNotificator = [PTNotificator new];
        });
    }
    
    return theNotificator;
}

-(void) addObserver:(id<PTNotificationsObserver>) observer
{
    BOOL isFound = NO;
    for(NSValue* value in self.mutableNonretainedObservers)
    {
        if([value nonretainedObjectValue] == observer)
        {
            isFound = YES;
            break;
        }
    }
    
    if(!isFound)
    {
        [self.mutableNonretainedObservers addObject:[NSValue valueWithNonretainedObject:observer]];
    }
}

-(void) removeObserver:(id<PTNotificationsObserver>) observer
{
    BOOL isFound = NO;
    NSUInteger index = 0;
    for(NSValue* value in self.mutableNonretainedObservers)
    {
        if([value nonretainedObjectValue] == observer)
        {
            [self.mutableNonretainedObservers removeObjectAtIndex:index];
            
            isFound = YES;
            break;
        }
        
        ++index;
    }
    
    NSAssert(isFound, @"Observer %@ is not found in %@", observer, self);
}

-(NSArray*) observers
{
    NSMutableArray* mutableObservers = [NSMutableArray arrayWithCapacity:[self.mutableNonretainedObservers count]];
    for(NSValue* value in self.mutableNonretainedObservers)
    {
        [mutableObservers addObject:[value nonretainedObjectValue]];
    }
    
    return [mutableObservers copy];
}

NOTIFICATIONS_NAMES(DEFINE_NOTIFY)

#pragma mark -
#pragma mark Private methods

-(NSMutableArray*) mutableNonretainedObservers
{
    if(!_mutableNonretainedObservers)
    {
        _mutableNonretainedObservers = [NSMutableArray array];
    }
    
    return _mutableNonretainedObservers;
}


@end

//
//  PTModelSyncScheduler.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTModelSyncScheduler.h"

#import <Reachability.h>

@interface PTModelSyncScheduler ()

@property (nonatomic, strong) Reachability* reachability;
@property (nonatomic, strong) NSTimer* retryTimer;
@property (nonatomic) PTModelSyncStatus syncStatus;

-(void) handleRechabilityChangedNotification:(NSNotification*) notification;
-(void) retryTimerDidFire:(NSTimer*) timer;

@end

@implementation PTModelSyncScheduler

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) updateWithSyncStatus:(PTModelSyncStatus) syncStatus
{
    self.syncStatus = syncStatus;
    
    switch (syncStatus)
    {
        case PTModelSyncStatusStarted:
            [self.retryTimer invalidate];
            break;
        case PTModelSyncStatusFinished:
        case PTModelSyncStatusStopped:
            [self.retryTimer invalidate];
            break;
        case PTModelSyncStatusFailed:
            [self.retryTimer invalidate];
            self.retryTimer = [NSTimer timerWithTimeInterval:kModelSyncFailRetryInterval
                                                      target:self
                                                    selector:@selector(retryTimerDidFire:)
                                                    userInfo:nil
                                                     repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.retryTimer forMode:NSRunLoopCommonModes];
            if(!self.reachability)
            {
                self.reachability = [Reachability reachabilityWithHostname:kReachabilityHostName];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(handleRechabilityChangedNotification:)
                                                             name:kReachabilityChangedNotification
                                                           object:self.reachability];
                [self.reachability startNotifier];
            }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Private methods

-(void) handleRechabilityChangedNotification:(NSNotification*) notification
{
    if(self.syncStatus == PTModelSyncStatusFailed)
    {
        Reachability* reachability = [notification object];
        if([reachability isReachable])
        {
            [self.delegate modelSyncSchedulerDidRequestModelSync:self];
        }
    }
}

-(void) retryTimerDidFire:(NSTimer*) timer
{
    NSAssert(self.syncStatus == PTModelSyncStatusFailed, @"Invalid sync status: %d", self.syncStatus);
    
    if([self.reachability isReachable])
    {
        [self.delegate modelSyncSchedulerDidRequestModelSync:self];
    }
}

@end

//
//  PTNotificator.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTNotificationsNames.h"
#import "PTNotificationMacros.h"

@protocol PTNotificationsObserver <NSObject>

@optional

NOTIFICATIONS_NAMES(DECLARE_OBSERVE)

@end

@interface PTNotificator : NSObject

@property (nonatomic, readonly) NSArray* observers;

+(instancetype) sharedNotificator;

-(void) addObserver:(id<PTNotificationsObserver>) observer;
-(void) removeObserver:(id<PTNotificationsObserver>) observer;

NOTIFICATIONS_NAMES(DECLARE_NOTIFY)

@end

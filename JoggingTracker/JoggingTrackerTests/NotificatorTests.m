//
//  NotificatorTests.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PTNotificator.h"

typedef enum : NSUInteger {
    ObserverExecutedMarker = 0,
    TestObserveAddSynchronisableObject,
    TestObserveDeleteSynchronisableObject,
    TestObserveUpdateSynchronisableObject,
    TestObserveModelSyncDidUpdateStatus,
    TestObserveRequestLogout
} TestObserveMethod;

@interface NotificatorTests : XCTestCase <PTNotificationsObserver>

@property (nonatomic) TestObserveMethod method;

@end

@implementation NotificatorTests

-(void) setUp
{
    [super setUp];
    
    NSArray* observers = [[PTNotificator sharedNotificator].observers copy];
    for(id<PTNotificationsObserver> observer in observers)
    {
        [[PTNotificator sharedNotificator] removeObserver:observer];
    }
    
    [[PTNotificator sharedNotificator] addObserver:self];
}

-(void) tearDown
{
    [[PTNotificator sharedNotificator] removeObserver:self];
    
    [super tearDown];
}

-(void) testNotifications
{
    self.method = TestObserveAddSynchronisableObject;
    [[PTNotificator sharedNotificator] notifyDidAddSynchronisableObject:nil sender:self];
    XCTAssertEqual(self.method, ObserverExecutedMarker, @"");
    
    self.method = TestObserveDeleteSynchronisableObject;
    [[PTNotificator sharedNotificator] notifyDidDeleteSynchronisableObject:nil sender:self];
    XCTAssertEqual(self.method, ObserverExecutedMarker, @"");
    
    self.method = TestObserveUpdateSynchronisableObject;
    [[PTNotificator sharedNotificator] notifyDidUpdateSynchronisableObject:nil sender:self];
    XCTAssertEqual(self.method, ObserverExecutedMarker, @"");
    
    self.method = TestObserveModelSyncDidUpdateStatus;
    [[PTNotificator sharedNotificator] notifyModelSyncDidUpdateStatus:PTModelSyncStatusStarted sender:self];
    XCTAssertEqual(self.method, ObserverExecutedMarker, @"");
    
    self.method = TestObserveRequestLogout;
    [[PTNotificator sharedNotificator] notifyRequestLogout:self];
    XCTAssertEqual(self.method, ObserverExecutedMarker, @"");
}

#pragma mark -
#pragma mark PTNotificationsObserver methods

-(void) observeDidAddSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    XCTAssertEqual(self.method, TestObserveAddSynchronisableObject, @"");
    XCTAssertTrue(sender == self, @"");
    
    self.method = ObserverExecutedMarker;
}

-(void) observeDidDeleteSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    XCTAssertEqual(self.method, TestObserveDeleteSynchronisableObject, @"");
    XCTAssertTrue(sender == self, @"");
    
    self.method = ObserverExecutedMarker;
}

-(void) observeDidUpdateSynchronisableObject:(PTSynchronisableObject*) object sender:(id) sender
{
    XCTAssertEqual(self.method, TestObserveUpdateSynchronisableObject, @"");
    XCTAssertTrue(sender == self, @"");
    
    self.method = ObserverExecutedMarker;
}

-(void) observeModelSyncDidUpdateStatus:(PTModelSyncStatus) syncStatus sender:(id) sender
{
    XCTAssertEqual(self.method, TestObserveModelSyncDidUpdateStatus, @"");
    XCTAssertTrue(sender == self, @"");
    
    self.method = ObserverExecutedMarker;
}

-(void) observeRequestLogout:(id) sender
{
    XCTAssertEqual(self.method, TestObserveRequestLogout, @"");
    XCTAssertTrue(sender == self, @"");
    
    self.method = ObserverExecutedMarker;
}

@end

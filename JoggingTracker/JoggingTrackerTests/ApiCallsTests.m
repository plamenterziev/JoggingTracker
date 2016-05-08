//
//  ApiCallsTests.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PTApiCallCreateJoggingEntry.h"
#import "PTApiCallUpdateJoggingEntry.h"
#import "PTApiCallFetchJoggingEntries.h"
#import "PTApiCallBatchOperations.h"
#import "PTApiCallLoginUser.h"
#import "PTCreatedRemoteObjectResponseData.h"
#import "PTUpdatedRemoteObjectResponseData.h"
#import "PTJoggingEntry.h"
#import "PTUserLoginResponseData.h"
#import "PTUser.h"
#import "PTConstants.h"
#import "PTApiCallsUtils.h"
#import "PTGUIDUtils.h"
#import "PTJoggingEntryRequestDetails.h"
#import "PTApiCallResponseResult.h"

#import <RestKit.h> 

#define DEFINE_API_CALL_TEST_CATEGORY(API_CALL_CLASS, PATH_PATTERN)     \
    @interface API_CALL_CLASS (Tests)                                   \
    +(NSString*) pathPattern;                                           \
    @end                                                                \
    @implementation API_CALL_CLASS (Tests)                              \
    +(NSString*) pathPattern { return PATH_PATTERN; }                   \
    @end

DEFINE_API_CALL_TEST_CATEGORY(PTApiCallCreateJoggingEntry, @"classes/JoggingEntry_Tests")
DEFINE_API_CALL_TEST_CATEGORY(PTApiCallUpdateJoggingEntry, @"classes/JoggingEntry_Tests/:serverSideObjectID")
DEFINE_API_CALL_TEST_CATEGORY(PTApiCallFetchJoggingEntries, @"classes/JoggingEntry_Tests")

@interface ApiCallsTests : XCTestCase

@property (nonatomic, strong) RKObjectManager* objectManager;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic) BOOL isTestFinished;

-(void) waitTestToFinish;

@end

@implementation ApiCallsTests

-(void) setUp
{
    [super setUp];

    self.objectManager = [PTApiCallsUtils createObjectManager];
    
    [self.objectManager addRequestDescriptorsFromArray:@[[PTApiCallCreateJoggingEntry requestDescriptor],
                                                         [PTApiCallUpdateJoggingEntry requestDescriptor],
                                                         [PTApiCallBatchOperations requestDescriptor]]];
    [self.objectManager addResponseDescriptorsFromArray:@[[PTApiCallLoginUser responseDescriptor],
                                                          [PTApiCallFetchJoggingEntries responseDescriptor],
                                                          [PTApiCallCreateJoggingEntry responseDescriptor],
                                                          [PTApiCallUpdateJoggingEntry responseDescriptor],
                                                          [PTApiCallBatchOperations responseDescriptor]]];
    
    self.userID = @"TxUkJe09XV";
}

-(void) tearDown
{
    [super tearDown];
}

-(void) testUserLogin
{
    PTApiCallLoginUser* apiCall = [PTApiCallLoginUser new];
    apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
    {
        XCTAssertEqual([result.objects count], 1, @"");
        PTUserLoginResponseData* responseData = [result.objects lastObject];
        XCTAssertTrue([responseData isKindOfClass:[PTUserLoginResponseData class]], @"");
        XCTAssertNotNil(responseData.sessionToken, @"");
        XCTAssertNotNil(responseData.user, @"");
        PTUser* user = responseData.user;
        XCTAssertTrue([user isKindOfClass:[PTUser class]], @"");
        XCTAssertEqualObjects(user.userID, self.userID, @"");
        XCTAssertEqualObjects(user.displayName, @"Unit Tests", @"");
        
        self.isTestFinished = YES;
    };
    apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
    {
        XCTFail(@"%@", error);
        self.isTestFinished = YES;
    };
    apiCall.parameters = @{@"username" : @"test@test.test",
                           @"password" : @"unittest"};
    
    self.isTestFinished = NO;
    [apiCall executeWithManager:self.objectManager pathUsingObjects:nil];

    [self waitTestToFinish];
}

-(void) testCreateUpdateFetchJoggingEntryApiCalls
{
    PTJoggingEntry* joggingEntry = [PTJoggingEntry new];
    joggingEntry.clientSideObjectID = [PTGUIDUtils createGUID];
    joggingEntry.date = [NSDate date];
    joggingEntry.distance = 12345;
    joggingEntry.time = 4567;
    
    PTJoggingEntryRequestDetails* requestDetails = [PTJoggingEntryRequestDetails new];
    requestDetails.joggingEntry = joggingEntry;
    requestDetails.userID = self.userID;
    requestDetails.isDeleted = @NO;
    
    {
        PTApiCallCreateJoggingEntry* apiCall = [PTApiCallCreateJoggingEntry new];
        apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
        {
            XCTAssertEqual([result.objects count], 1, @"");
            PTCreatedRemoteObjectResponseData* responseData = [result.objects lastObject];
            XCTAssertTrue([responseData isKindOfClass:[PTCreatedRemoteObjectResponseData class]], @"");
            XCTAssertNotNil(responseData.objectID, @"");
            XCTAssertNotNil(responseData.dateCreated, @"");
            
            joggingEntry.serverSideObjectID = responseData.objectID;
            joggingEntry.dateCreated = responseData.dateCreated;
            joggingEntry.dateUpdated = responseData.dateCreated;
            
            self.isTestFinished = YES;
        };
        apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
        {
            XCTFail(@"%@", error);
            self.isTestFinished = YES;
        };
        
        self.isTestFinished = NO;
        [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:nil];
        
        [self waitTestToFinish];
    }
    {
        joggingEntry.distance = 5432;
        joggingEntry.time = 321;
        
        PTApiCallUpdateJoggingEntry* apiCall = [PTApiCallUpdateJoggingEntry new];
        apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
        {
            XCTAssertEqual([result.objects count], 1, @"");
            PTUpdatedRemoteObjectResponseData* responseData = [result.objects lastObject];
            XCTAssertTrue([responseData isKindOfClass:[PTUpdatedRemoteObjectResponseData class]], @"");
            XCTAssertNotNil(responseData.dateUpdated, @"");
            
            joggingEntry.dateUpdated = responseData.dateUpdated;
            
            self.isTestFinished = YES;
        };
        apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
        {
            XCTFail(@"%@", error);
            self.isTestFinished = YES;
        };
        
        self.isTestFinished = NO;
        [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:@[joggingEntry]];
        
        [self waitTestToFinish];
    }
    {
        PTApiCallFetchJoggingEntries* apiCall = [PTApiCallFetchJoggingEntries new];
        apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
        {
            XCTAssertEqual([result.objects count], 1, @"");
            PTJoggingEntry* newJoggingEntry = [result.objects lastObject];
            XCTAssertTrue([newJoggingEntry isKindOfClass:[PTJoggingEntry class]], @"");
            XCTAssertEqualObjects(newJoggingEntry.serverSideObjectID, joggingEntry.serverSideObjectID, @"");
            XCTAssertEqualObjects(newJoggingEntry.clientSideObjectID, joggingEntry.clientSideObjectID, @"");
            XCTAssertEqualObjects(newJoggingEntry.dateUpdated, joggingEntry.dateUpdated, @"");
            XCTAssertEqualObjects(newJoggingEntry.dateCreated, joggingEntry.dateCreated, @"");
            XCTAssertFalse(newJoggingEntry.isDeleted, @"");
            unsigned int flags = (NSYearCalendarUnit |
                                  NSMonthCalendarUnit |
                                  NSDayCalendarUnit |
                                  NSHourCalendarUnit |
                                  NSMinuteCalendarUnit |
                                  NSSecondCalendarUnit);
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:flags fromDate:newJoggingEntry.date];
            NSDate* newJoggingEntryDate = [calendar dateFromComponents:components];
            components = [calendar components:flags fromDate:joggingEntry.date];
            NSDate* joggingEntryDate = [calendar dateFromComponents:components];
            XCTAssertEqualObjects(newJoggingEntryDate, joggingEntryDate, @"");
            XCTAssertEqual(newJoggingEntry.time, joggingEntry.time, @"");
            XCTAssertEqual(newJoggingEntry.distance, joggingEntry.distance, @"");
            
            self.isTestFinished = YES;
        };
        apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
        {
            XCTFail(@"%@", error);
            self.isTestFinished = YES;
        };
        
        apiCall.parameters = @{@"limit" : @(1),
                               @"where" : [NSString stringWithFormat:@"{\"userId\":\"%@\",\"objectId\":\"%@\"}",
                                           self.userID, joggingEntry.serverSideObjectID],
                               @"order" : @"updatedAt"};
        
        self.isTestFinished = NO;
        [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:nil];
        
        [self waitTestToFinish];
    }
    {
        requestDetails.isDeleted = @YES;
        
        PTApiCallUpdateJoggingEntry* apiCall = [PTApiCallUpdateJoggingEntry new];
        apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
        {
            XCTAssertEqual([result.objects count], 1, @"");
            PTUpdatedRemoteObjectResponseData* responseData = [result.objects lastObject];
            XCTAssertTrue([responseData isKindOfClass:[PTUpdatedRemoteObjectResponseData class]], @"");
            XCTAssertNotNil(responseData.dateUpdated, @"");
            
            joggingEntry.dateUpdated = responseData.dateUpdated;
            
            self.isTestFinished = YES;
        };
        apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
        {
            XCTFail(@"%@", error);
            self.isTestFinished = YES;
        };
        
        self.isTestFinished = NO;
        [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:@[joggingEntry]];
        
        [self waitTestToFinish];
    }
    {
        PTApiCallFetchJoggingEntries* apiCall = [PTApiCallFetchJoggingEntries new];
        apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
        {
            XCTAssertEqual([result.objects count], 1, @"");
            PTJoggingEntry* newJoggingEntry = [result.objects lastObject];
            XCTAssertTrue([newJoggingEntry isKindOfClass:[PTJoggingEntry class]], @"");
            XCTAssertEqualObjects(newJoggingEntry.serverSideObjectID, joggingEntry.serverSideObjectID, @"");
            XCTAssertEqualObjects(newJoggingEntry.clientSideObjectID, joggingEntry.clientSideObjectID, @"");
            XCTAssertEqualObjects(newJoggingEntry.dateUpdated, joggingEntry.dateUpdated, @"");
            XCTAssertEqualObjects(newJoggingEntry.dateCreated, joggingEntry.dateCreated, @"");
            XCTAssertTrue(newJoggingEntry.isDeleted, @"");
            unsigned int flags = (NSYearCalendarUnit |
                                  NSMonthCalendarUnit |
                                  NSDayCalendarUnit |
                                  NSHourCalendarUnit |
                                  NSMinuteCalendarUnit |
                                  NSSecondCalendarUnit);
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:flags fromDate:newJoggingEntry.date];
            NSDate* newJoggingEntryDate = [calendar dateFromComponents:components];
            components = [calendar components:flags fromDate:joggingEntry.date];
            NSDate* joggingEntryDate = [calendar dateFromComponents:components];
            XCTAssertEqualObjects(newJoggingEntryDate, joggingEntryDate, @"");
            XCTAssertEqual(newJoggingEntry.time, joggingEntry.time, @"");
            XCTAssertEqual(newJoggingEntry.distance, joggingEntry.distance, @"");
            
            self.isTestFinished = YES;
        };
        apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
        {
            XCTFail(@"%@", error);
            self.isTestFinished = YES;
        };
        
        apiCall.parameters = @{@"limit" : @(1),
                               @"where" : [NSString stringWithFormat:@"{\"userId\":\"%@\",\"objectId\":\"%@\"}",
                                           self.userID, joggingEntry.serverSideObjectID],
                               @"order" : @"updatedAt"};
        
        self.isTestFinished = NO;
        [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:nil];
        
        [self waitTestToFinish];
    }
    {
        // Delete jogging entry from the database
        self.isTestFinished = NO;
        [self.objectManager.HTTPClient deletePath:[@"classes/JoggingEntry_Tests/" stringByAppendingString:joggingEntry.serverSideObjectID]
                                       parameters:nil
                                          success:^(AFHTTPRequestOperation* operation, id responseObject)
        {
            self.isTestFinished = YES;
        }
                                          failure:^(AFHTTPRequestOperation* operation, NSError* error)
        {
            XCTFail(@"%@", error);
            self.isTestFinished = YES;
        }];
        
        [self waitTestToFinish];
    }
}

#pragma mark -
#pragma mark Private methods

-(void) waitTestToFinish
{
    while(!self.isTestFinished)
    {
        [NSThread sleepForTimeInterval:1];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

@end

//
//  PTLoginController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTLoginController.h"
#import "PTUserDefaultSettings.h"
#import "PTApiCallSignupUser.h"
#import "PTApiCallLoginUser.h"
#import "PTApiCallsUtils.h"
#import "PTUserSignupRequestDetails.h"
#import "PTUserSignupResponseData.h"
#import "PTUserLoginResponseData.h"
#import "PTUser.h"
#import "PTPersistenceController.h"

#import <RestKit.h>

@interface PTLoginController ()

@property (nonatomic, strong) RKObjectManager* objectManager;
@property (nonatomic, strong) PTUser* currentUser;

-(void) setup;

@end

@implementation PTLoginController

static PTLoginController* theController = nil;

+(instancetype) sharedController
{
    if(!theController)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            theController = [self new];
        });
    }
    
    return theController;
}

-(instancetype) init
{
    if((self = [super init]))
    {
        [self setup];
    }
    
    return self;
}

-(PTRemoteRequestHandler*) signupUserWithDetails:(PTUserSignupRequestDetails*) details
                                         success:(void (^)(PTRemoteRequestHandler* requestHandler, PTUser* user)) success
                                         failure:(PTRemoteRequestFailureBlock) failure
{
    PTApiCallSignupUser* apiCall = [PTApiCallSignupUser new];
    __weak typeof(self) weakSelf = self;
    apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
    {
        PTUserSignupResponseData* userSignupResponseData = [result.objects lastObject];
        [PTUserDefaultsSettings sharedSettings].sessionToken = userSignupResponseData.sessionToken;
        PTUser* user = [PTUser new];
        user.displayName = details.displayName;
        user.userID = userSignupResponseData.userID;

        if([[PTPersistenceController sharedController] saveCurrentUser:user])
        {
            weakSelf.currentUser = user;
        }
        if(success)
        {
            success(requestHandler, user);
        }
    };
    apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
    {
        if(failure)
        {
            failure(requestHandler, error);
        }
    };
    
    return [apiCall executeWithManager:self.objectManager withPayloadObject:details pathUsingObjects:nil];
}

-(PTRemoteRequestHandler*) loginUserWithEmail:(NSString*) email
                                  andPassword:(NSString*) password
                                      success:(void (^)(PTRemoteRequestHandler* requestHandler, PTUser* user)) success
                                      failure:(PTRemoteRequestFailureBlock) failure
{
    PTApiCallLoginUser* apiCall = [PTApiCallLoginUser new];
    __weak typeof(self) weakSelf = self;
    apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
    {
        PTUserLoginResponseData* userLoginResponseData = [result.objects lastObject];
        [PTUserDefaultsSettings sharedSettings].sessionToken = userLoginResponseData.sessionToken;
        PTUser* user = userLoginResponseData.user;
        if([[PTPersistenceController sharedController] saveCurrentUser:user])
        {
            weakSelf.currentUser = user;
        }
        if(success)
        {
            success(requestHandler, user);
        }
    };
    apiCall.failureBlock = failure;
    apiCall.parameters = @{@"username" : SAFE_DICTIONARY_VALUE(email),
                           @"password" : SAFE_DICTIONARY_VALUE(password)};
    return [apiCall executeWithManager:self.objectManager pathUsingObjects:nil];
}

-(void) logout
{
    [[PTPersistenceController sharedController] deleteCurrentUser];
    [PTUserDefaultsSettings sharedSettings].sessionToken = nil;
    self.currentUser = nil;
}

-(BOOL) isAuthenticated
{
    return (!!self.currentUser && ([[PTUserDefaultsSettings sharedSettings].sessionToken length] > 0));
}

#pragma mark -
#pragma mark Private methods

-(void) setup
{
    self.objectManager = [PTApiCallsUtils createObjectManager];
    
    [self.objectManager addRequestDescriptorsFromArray:@[[PTApiCallSignupUser requestDescriptor]]];
    [self.objectManager addResponseDescriptorsFromArray:@[[PTApiCallSignupUser responseDescriptor],
                                                          [PTApiCallLoginUser responseDescriptor]]];
    
    self.currentUser = [[PTPersistenceController sharedController] fetchCurrentUser];
}

@end

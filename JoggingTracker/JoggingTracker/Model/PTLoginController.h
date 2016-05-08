//
//  PTLoginController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTRemoteRequestHandler.h"

@class PTUserSignupRequestDetails;
@class PTUser;

/**
 * Main controller for user login and sign up
 */
@interface PTLoginController : NSObject

/**
 * Keeps current logged in user or 'nil' if no such user exists
 */
@property (nonatomic, readonly, strong) PTUser* currentUser;

+(instancetype) sharedController;

/**
 * Try to singup user with the provided signup details
 *
 * @param details Signup details to use
 * @param success Success block to execute on success
 * @param failure Failure block to execute on failure
 * @return Remote request handler to the operation
 */
-(PTRemoteRequestHandler*) signupUserWithDetails:(PTUserSignupRequestDetails*) details
                                         success:(void (^)(PTRemoteRequestHandler* requestHandler, PTUser* user)) success
                                         failure:(PTRemoteRequestFailureBlock) failure;

/**
 * Try to logn user with the provided user name (email) and password
 *
 * @param email Email for login
 * @param password Password for login
 * @param success Success block to execute on success
 * @param failure Failure block to execute on failure
 * @return Remote request handler to the operation
 */
-(PTRemoteRequestHandler*) loginUserWithEmail:(NSString*) email
                                  andPassword:(NSString*) password
                                      success:(void (^)(PTRemoteRequestHandler* requestHandler, PTUser* user)) success
                                      failure:(PTRemoteRequestFailureBlock) failure;

/**
 * Logout current user
 */
-(void) logout;

/** 
 * @return YES if is authenticated, NO otherwise
 */
-(BOOL) isAuthenticated;

@end

//
//  PTUserSignupRequestDetails.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTUserSignupRequestDetails : NSObject

@property (nonatomic, strong) NSString* displayName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* password;

@end

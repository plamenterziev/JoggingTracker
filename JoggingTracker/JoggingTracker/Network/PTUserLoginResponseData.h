//
//  PTUserLoginResponseData.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTUser;

@interface PTUserLoginResponseData : NSObject

@property (nonatomic, strong) PTUser* user;
@property (nonatomic, strong) NSString* sessionToken;

@end

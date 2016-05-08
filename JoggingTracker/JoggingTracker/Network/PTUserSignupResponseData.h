//
//  PTUserSignupResponseData.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTUserSignupResponseData : NSObject

@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* sessionToken;

@end

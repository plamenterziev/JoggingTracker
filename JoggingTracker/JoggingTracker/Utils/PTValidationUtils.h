//
//  PTValidationUtils.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTValidationUtils : NSObject

+(BOOL) isEmailValid:(NSString*) email;
+(BOOL) isPasswordValid:(NSString*) password;
+(BOOL) isNameValid:(NSString*) name;

@end

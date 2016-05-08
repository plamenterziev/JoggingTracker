//
//  PTStringUtils.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTStringUtils : NSObject

+(NSString*) stringFromInteger:(NSInteger) integer;
+(NSString*) prettyDescriptionForDateTime:(NSDate*) date;
+(NSString*) prettyDescriptionForDate:(NSDate*) date;
+(NSString*) prettyDescriptionForTimeInSeconds:(NSInteger) time;
+(NSString*) prettyDescriptionForDistanceInMeters:(NSInteger) distance;
+(NSString*) prettyDescriptionForSpeedForMeters:(NSInteger) distance
                                     forSeconds:(NSInteger) seconds;

@end

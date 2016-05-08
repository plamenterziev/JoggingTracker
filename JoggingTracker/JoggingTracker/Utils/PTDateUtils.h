//
//  PTDateUtils.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTDateUtils : NSObject

+(NSDate*) dayStartForDate:(NSDate*) date;
+(NSDate*) dayEndForDate:(NSDate*) date;
+(NSDate*) weekStartForDate:(NSDate*) date;
+(NSDate*) weekEndForWeekStartDate:(NSDate*) date;

@end

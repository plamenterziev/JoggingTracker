//
//  PTFilterOptions.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTFilterOptions : NSObject <NSCopying>

@property (nonatomic, copy) NSDate* fromDate;
@property (nonatomic, copy) NSDate* toDate;

-(BOOL) containsDate:(NSDate*) date;

@end

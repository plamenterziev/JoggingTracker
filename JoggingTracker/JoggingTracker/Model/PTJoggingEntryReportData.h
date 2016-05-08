//
//  PTJoggingEntryReportData.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTJoggingEntryReportData : NSObject

@property (nonatomic, readonly) NSInteger time;
@property (nonatomic, readonly) NSInteger distance;
@property (nonatomic, readonly) CGFloat averageSpeed;
@property (nonatomic, readonly, strong) NSDate* weekDate;

-(instancetype) initWithDictionary:(NSDictionary*) dictionary;

@end

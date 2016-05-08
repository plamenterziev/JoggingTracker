//
//  PTReportCell.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTCell.h"

@class PTJoggingEntryReportData;

@interface PTReportCell : PTCell

@property (nonatomic, strong) PTJoggingEntryReportData* reportData;

@end

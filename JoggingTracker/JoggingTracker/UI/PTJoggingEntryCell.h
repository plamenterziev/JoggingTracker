//
//  PTJoggingEntryCell.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTCell.h"

@class PTManagedJoggingEntry;

@interface PTJoggingEntryCell : PTCell

@property (nonatomic, strong) PTManagedJoggingEntry* joggingEntry;

@end

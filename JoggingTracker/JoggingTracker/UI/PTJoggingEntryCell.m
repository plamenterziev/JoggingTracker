//
//  PTJoggingEntryCell.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTJoggingEntryCell.h"
#import "PTManagedJoggingEntry.h"
#import "PTStringUtils.h"

DEFINE_CELL_CONFIGURATION(PTJoggingEntryCell,
                          @"PTJoggingEntryCell",
                          @"kJoggingEntryCellIdentifier",
                          70.0f)

@interface PTJoggingEntryCell ()

@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
@property (nonatomic, weak) IBOutlet UILabel* distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeLabel;

@end

@implementation PTJoggingEntryCell

-(void) reloadData
{
    self.dateLabel.text = [PTStringUtils prettyDescriptionForDateTime:self.joggingEntry.date];
    self.distanceLabel.text = [PTStringUtils prettyDescriptionForDistanceInMeters:[self.joggingEntry.distance integerValue]];
    self.timeLabel.text = [PTStringUtils prettyDescriptionForTimeInSeconds:[self.joggingEntry.time integerValue]];
}


@end

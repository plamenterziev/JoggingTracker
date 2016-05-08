//
//  PTReportCell.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTReportCell.h"
#import "PTJoggingEntryReportData.h"
#import "PTStringUtils.h"

DEFINE_CELL_CONFIGURATION(PTReportCell,
                          @"PTReportCell",
                          @"kReportCellIdentifier",
                          60.0f);

PTUseLocalizationTableName(@"PTReportCell");

@interface PTReportCell ()

@property (nonatomic, weak) IBOutlet UILabel* distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel* speedLabel;

@end

@implementation PTReportCell

-(void) reloadData
{
    self.distanceLabel.text = PTLS(@"Distance: %@", [PTStringUtils prettyDescriptionForDistanceInMeters:self.reportData.distance]);
    self.speedLabel.text = PTLS(@"Speed: %@", [PTStringUtils prettyDescriptionForSpeedForMeters:self.reportData.distance
                                                                                     forSeconds:self.reportData.time]);
}

@end

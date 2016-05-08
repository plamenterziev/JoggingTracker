//
//  PTJoggingEntryViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTNibLoading.h"

@class PTJoggingEntry;

@interface PTJoggingEntryViewController : UIViewController <PTNibLoading>

@property (nonatomic, strong) PTJoggingEntry* joggingEntry;

@end

//
//  PTJoggingEntryEditViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTFormViewController.h"
#import "PTNibLoading.h"

@class PTJoggingEntry;
@class PTJoggingEntryEditViewController;

@protocol PTJoggingEntryEditViewControllerDelegate <NSObject>

-(void) joggingEntryEditViewControllerDidCancel:(PTJoggingEntryEditViewController*) sender;
-(void) joggingEntryEditViewController:(PTJoggingEntryEditViewController*) sender
                   didEditJoggingEntry:(PTJoggingEntry*) joggingEntry;
-(void) joggingEntryEditViewController:(PTJoggingEntryEditViewController*) sender
                 didCreateJoggingEntry:(PTJoggingEntry*) joggingEntry;

@end

@interface PTJoggingEntryEditViewController : PTFormViewController <PTNibLoading>

@property (nonatomic, weak) id<PTJoggingEntryEditViewControllerDelegate> delegate;
// If not set then will create new jogging entry
@property (nonatomic, copy) PTJoggingEntry* joggingEntry;

@end

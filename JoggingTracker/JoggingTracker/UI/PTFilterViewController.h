//
//  PTFilterViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTFormViewController.h"
#import "PTNibLoading.h"

@class PTFilterViewController;
@class PTFilterOptions;

@protocol PTFilterViewControllerDelegate <NSObject>

-(void) filterViewControllerDidCancel:(PTFilterViewController*) sender;
-(void) filterViewControllerDidRemoveFilterOptions:(PTFilterViewController*) sender;
-(void) filterViewController:(PTFilterViewController*) sender didSelectFilterOptions:(PTFilterOptions*) filterOptions;

@end

@interface PTFilterViewController : PTFormViewController <PTNibLoading>

@property (nonatomic, weak) id<PTFilterViewControllerDelegate> delegate;
@property (nonatomic, copy) PTFilterOptions* filterOptions;

@end

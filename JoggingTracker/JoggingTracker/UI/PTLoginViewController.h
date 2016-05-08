//
//  PTLoginViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTFormViewController.h"
#import "PTNibLoading.h"

@class PTLoginViewController;
@class PTUser;

@protocol PTLoginViewControllerDelegate <NSObject>

-(void) loginViewController:(PTLoginViewController*) sender didSignupUser:(PTUser *)user;
-(void) loginViewController:(PTLoginViewController*) sender didLoginUser:(PTUser*) user;

@end

@interface PTLoginViewController : PTFormViewController <PTNibLoading>

@property (nonatomic, weak) id<PTLoginViewControllerDelegate> delegate;

@end

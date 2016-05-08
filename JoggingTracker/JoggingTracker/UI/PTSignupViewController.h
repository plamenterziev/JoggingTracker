//
//  PTSignupViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTFormViewController.h"
#import "PTNibLoading.h"

@class PTSignupViewController;
@class PTUser;

@protocol PTSignupViewControllerDelegate <NSObject>

-(void) signupViewController:(PTSignupViewController*) sender didSignupUser:(PTUser*) user;
-(void) signupViewControllerDidRequestToClose:(PTSignupViewController*) sender;

@end

@interface PTSignupViewController : PTFormViewController <PTNibLoading>

@property (nonatomic, weak) id<PTSignupViewControllerDelegate> delegate;

@end

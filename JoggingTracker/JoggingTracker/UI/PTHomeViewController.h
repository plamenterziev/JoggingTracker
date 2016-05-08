//
//  PTHomeViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTNibLoading.h"

@class PTUser;

@interface PTHomeViewController : UIViewController <PTNibLoading>

@property (nonatomic, strong) PTUser* user;

@end

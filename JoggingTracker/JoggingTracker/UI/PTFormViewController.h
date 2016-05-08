//
//  PTFormViewController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Base view controller for form-like view controllers.
 * Supports scroll view and automatically updates its content insets when keyboard is visible
 * so keyboard cannot overlap content
 */
@interface PTFormViewController : UIViewController

/**
 * Derived classes must return mainScrollView
 */
@property (nonatomic, readonly) UIScrollView* mainScrollView;

-(void) handleWillShowKeyboardNotification:(NSNotification*) notification;
-(void) handleWillHideKeyboardNotification:(NSNotification*) notification;

@end

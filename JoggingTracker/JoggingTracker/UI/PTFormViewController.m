//
//  PTFormViewController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTFormViewController.h"

@interface PTFormViewController ()

@property (nonatomic) BOOL isKeyboardVisible;
@property (nonatomic) CGFloat originalBottomContentInset;

@end

@implementation PTFormViewController

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark -
#pragma mark Private methods

-(UIScrollView*) mainScrollView
{
    NSAssert(NO, @"Implement in a derived class");
    
    return nil;
}

-(void) handleWillShowKeyboardNotification:(NSNotification*) notification
{
    CGRect endFrame = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];

    UIEdgeInsets currContentInset = self.mainScrollView.contentInset;
    
    if(!self.isKeyboardVisible)
    {
        self.isKeyboardVisible = YES;
        self.originalBottomContentInset = currContentInset.bottom;
        currContentInset.bottom += endFrame.size.height;
    }
    else
    {
        currContentInset.bottom = (self.originalBottomContentInset + endFrame.size.height);
    }
    
    self.mainScrollView.contentInset = currContentInset;
}

-(void) handleWillHideKeyboardNotification:(NSNotification*) notification
{
    UIEdgeInsets currContentInset = self.mainScrollView.contentInset;
    
    self.isKeyboardVisible = NO;
    currContentInset.bottom = self.originalBottomContentInset;
    
    self.mainScrollView.contentInset = currContentInset;
}

@end

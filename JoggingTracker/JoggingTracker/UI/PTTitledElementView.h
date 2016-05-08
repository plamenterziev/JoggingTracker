//
//  PTTitledElementView.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTNibLoading.h"

/**
 * View that supports title and details bellow the title. The format is:
 * *---------------*
 * |     title     |
 * *---------------*
 * |               |
 * |    details    |
 * |               |
 * *---------------*
 */
@interface PTTitledElementView : UIView <PTNibLoading>

@property (nonatomic, readonly, weak) UILabel* titleLabel;
@property (nonatomic, readonly, weak) UILabel* detailsLabel;
@property (nonatomic, readonly, weak) UIView* titleContainerView;
@property (nonatomic, readonly, weak) UIView* detailsContainerView;

@end

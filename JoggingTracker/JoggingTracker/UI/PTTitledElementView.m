//
//  PTTitledElementView.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTTitledElementView.h"

static NSString* const kNibName                     = @"PTTitledElementView";

@interface PTTitledElementView ()

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* detailsLabel;
@property (nonatomic, weak) IBOutlet UIView* titleContainerView;
@property (nonatomic, weak) IBOutlet UIView* detailsContainerView;

@end

@implementation PTTitledElementView

+(instancetype) createFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:kNibName owner:nil options:nil] lastObject];
}

@end

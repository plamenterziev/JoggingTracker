//
//  PTUIUtils.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTUIUtils.h"

@implementation PTUIUtils

+(void) addLayoutConstraintsToCenterInSuperViewBounds:(UIView*) view
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0f
                                                                constant:0]];
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0f
                                                                constant:0]];
}

+(void) addLayoutConstraintsToMatchSuperViewBounds:(UIView*) view
{
    [self addLayoutConstraintsToMatchSuperViewBounds:view edgeInsets:UIEdgeInsetsZero];
}

+(void) addLayoutConstraintsToMatchSuperViewBounds:(UIView*) view edgeInsets:(UIEdgeInsets) edgeInsets
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0f
                                                                constant:edgeInsets.top]];
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0f
                                                                constant:edgeInsets.left]];
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0f
                                                                constant:-edgeInsets.bottom]];
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0f
                                                                constant:-edgeInsets.right]];
}

+(void) addLayoutConstraintsToView:(UIView*) view forSize:(CGSize) size
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0.0f
                                                      constant:size.width]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0.0f
                                                      constant:size.height]];
}

+(NSLayoutConstraint*) addLayoutConstraintToView:(UIView*) view toMatchSuperViewAttribute:(NSLayoutAttribute) attribute
{
    return [self addLayoutConstraintToView:view toMatchSuperViewAttribute:attribute constant:0.0f];
}

+(NSLayoutConstraint*) addLayoutConstraintToView:(UIView*) view toMatchSuperViewAttribute:(NSLayoutAttribute) attribute constant:(CGFloat) constant
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view.superview
                                                                  attribute:attribute
                                                                 multiplier:1.0f
                                                                   constant:constant];
    [view.superview addConstraint:constraint];
    
    return constraint;
}

+(void) addLayoutConstraintsToView:(UIView*) view forMinHorizontalMarginInSuperView:(CGFloat) margin
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:0.0f
                                                                constant:margin]];
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:0.0f
                                                                constant:-margin]];
}

@end

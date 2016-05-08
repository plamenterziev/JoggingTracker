//
//  PTUIUtils.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/26/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Utils for different UI and layout related stuff
 */
@interface PTUIUtils : NSObject

+(void) addLayoutConstraintsToCenterInSuperViewBounds:(UIView*) view;
+(void) addLayoutConstraintsToMatchSuperViewBounds:(UIView*) view;
+(void) addLayoutConstraintsToMatchSuperViewBounds:(UIView*) view edgeInsets:(UIEdgeInsets) edgeInsets;
+(void) addLayoutConstraintsToView:(UIView*) view forSize:(CGSize) size;
+(NSLayoutConstraint*) addLayoutConstraintToView:(UIView*) view toMatchSuperViewAttribute:(NSLayoutAttribute) attribute;
+(NSLayoutConstraint*) addLayoutConstraintToView:(UIView*) view toMatchSuperViewAttribute:(NSLayoutAttribute) attribute constant:(CGFloat) constant;
+(void) addLayoutConstraintsToView:(UIView*) view forMinHorizontalMarginInSuperView:(CGFloat) margin;

@end

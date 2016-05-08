//
//  PTTimePickerView.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Picker view for selecting time in seconds. Range is from 0 hours and 0 mins. to 23 hours and 59 mins.
 */
@interface PTTimePickerView : UIControl

@property (nonatomic, readonly) NSInteger timeInSeconds;

-(void) setTimeInSeconds:(NSInteger) timeInSeconds animated:(BOOL) animated;

@end

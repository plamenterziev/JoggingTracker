//
//  PTDistancePickerView.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Picker view for selecting distance in seconds. Range is from 0 kilometers 0 meters to 999 kilometers and 999 meters.
 */
@interface PTDistancePickerView : UIControl

@property (nonatomic, readonly) NSInteger distanceInMeters;

-(void) setDistanceInMeters:(NSInteger) distanceInMeters animated:(BOOL) animated;

@end

//
//  PTCell.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Base class for UITableViewCell-s
 */
@interface PTCell : UITableViewCell

/**
 * Derived classes should overwrite this method to update content
 */
-(void) reloadData;

@end

@interface PTCell (Configuration)

+(NSString*) nibName;
+(NSString*) reuseIdentifier;
+(CGFloat) height;

@end

#define DEFINE_CELL_CONFIGURATION(CLASS, NIB_NAME, REUSE_IDENTIFIER, HEIGHT)                            \
    @implementation CLASS (Configuration)                                                               \
    +(NSString*) nibName                                                                                \
    {                                                                                                   \
        return NIB_NAME;                                                                                \
    }                                                                                                   \
    +(NSString*) reuseIdentifier                                                                        \
    {                                                                                                   \
        return REUSE_IDENTIFIER;                                                                        \
    }                                                                                                   \
    +(CGFloat) height                                                                                   \
    {                                                                                                   \
        return HEIGHT;                                                                                  \
    }                                                                                                   \
    @end

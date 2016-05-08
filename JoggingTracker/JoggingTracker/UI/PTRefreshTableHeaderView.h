//
//  PTRefreshTableHeaderView.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTRefreshTableHeaderView;

@protocol PTRefreshTableHeaderViewDelegate <NSObject>

-(void) refreshTableHeaderViewDidStartLoading:(PTRefreshTableHeaderView*) sender;

@end

@interface PTRefreshTableHeaderView : UIView

@property (nonatomic, weak) id<PTRefreshTableHeaderViewDelegate> delegate;
@property (nonatomic, readonly) BOOL isRefreshing;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, strong) UIImage* arrowImage;
@property (nonatomic, strong) UIColor* activityIndicatorViewColor;
@property (nonatomic, readonly, strong) UIView* backgroundView;

-(instancetype) initWithTableView:(UITableView*) tableView;

-(void) beginRefreshingAnimated:(BOOL) animated;
-(void) endRefreshingAnimated:(BOOL) animated;

/**
 * Must call when table view did scroll
 */
-(void) tableViewDidScroll;
/**
 * Must call when table view did end dragging
 */
-(void) tableViewDidEndDragging;
/**
 * Must call when table view did end scrolling animation
 */
-(void) tableViewDidEndScrollingAnimation;

@end

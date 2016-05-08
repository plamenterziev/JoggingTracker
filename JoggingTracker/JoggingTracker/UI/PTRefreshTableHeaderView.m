//
//  PTRefreshTableHeaderView.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

//
//  LTRefreshTableHeaderView.m
//  LoveThis
//
//  Created by Plamen Terziev on 1/21/14.
//  Copyright (c) 2014 Bitmix. All rights reserved.
//

#import "PTRefreshTableHeaderView.h"
#import "PTUIUtils.h"

static const CGFloat kRefreshViewHeight                     = 64.0f;
static const CGFloat kSwitchStateOffset                     = 65.0f;
static const NSTimeInterval kAnimationDuration              = 0.2f;
static const NSTimeInterval kArrowFlipAnimationDuration     = 0.2f;
static const CGFloat kBackgroundViewAlpha                   = 0.2f;

typedef enum : NSUInteger
{
    PTRefreshTableHeaderViewStateNormal = 0,
    PTRefreshTableHeaderViewStatePulling,
    PTRefreshTableHeaderViewStateLoading
} PTRefreshTableHeaderViewState;

@interface PTRefreshTableHeaderView ()

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic) PTRefreshTableHeaderViewState state;
@property (nonatomic) BOOL isLayoutedProperly;
@property (nonatomic, readonly) BOOL isVisible;
@property (nonatomic) UIEdgeInsets deferredContentInset;
@property (nonatomic) BOOL hasDeferredContentInset;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIImageView* arrowImageView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) NSLayoutConstraint* backgroundViewHeightConstraint;

-(void) configureUI;
-(void) setTableViewContentInset:(UIEdgeInsets) contentInset animated:(BOOL) animated;
-(void) applyDeferredContentInset;

@end

@implementation PTRefreshTableHeaderView

-(instancetype) initWithTableView:(UITableView*) tableView
{
    if((self = [super init]))
    {
        _tableView = tableView;
        _isLayoutedProperly = NO;
        
        [_tableView addSubview:self];
        
        [self configureUI];
        
        self.state = PTRefreshTableHeaderViewStateNormal;
    }
    
    return self;
}

-(BOOL) isRefreshing
{
    return (self.state == PTRefreshTableHeaderViewStateLoading);
}

-(CGFloat) height
{
    return ((self.state == PTRefreshTableHeaderViewStateLoading || self.hasDeferredContentInset) ? kRefreshViewHeight : 0.0f);
}

-(void) setArrowImage:(UIImage*) arrowImage
{
    self.arrowImageView.image = arrowImage;
}

-(UIImage*) arrowImage
{
    return self.arrowImageView.image;
}

-(void) setActivityIndicatorViewColor:(UIColor*) activityIndicatorViewColor
{
    self.activityIndicatorView.color = activityIndicatorViewColor;
}

-(UIColor*) activityIndicatorViewColor
{
    return self.activityIndicatorView.color;
}

-(void) beginRefreshingAnimated:(BOOL) animated
{
    if(self.state == PTRefreshTableHeaderViewStateNormal)
    {
        [self applyDeferredContentInset];
        
        UIEdgeInsets contentInset = self.tableView.contentInset;
        contentInset.top += kRefreshViewHeight;
        [self setTableViewContentInset:contentInset animated:(animated && self.isVisible)];
        
        self.state = PTRefreshTableHeaderViewStateLoading;
    }
}

-(void) endRefreshingAnimated:(BOOL) animated
{
    if(self.state == PTRefreshTableHeaderViewStateLoading)
    {
        [self applyDeferredContentInset];
        
        UIEdgeInsets contentInset = self.tableView.contentInset;
        contentInset.top -= kRefreshViewHeight;
        [self setTableViewContentInset:contentInset animated:(animated && self.isVisible)];
        
        self.state = PTRefreshTableHeaderViewStateNormal;
    }
}

-(void) tableViewDidScroll
{
    CGFloat visibleHeight = fabs(self.tableView.contentOffset.y + kRefreshViewHeight);
    CGFloat backgroundViewHeight = MAX(0.0f, visibleHeight);
    if(self.backgroundViewHeightConstraint.constant != backgroundViewHeight)
    {
        self.backgroundViewHeightConstraint.constant = backgroundViewHeight;
    }
    
    if(self.tableView.isDragging &&
       (self.state == PTRefreshTableHeaderViewStateNormal || self.state == PTRefreshTableHeaderViewStatePulling))
    {
        CGFloat offset = (self.tableView.contentOffset.y + self.tableView.contentInset.top);
        if(offset < 0.0f)
        {
            if(self.state == PTRefreshTableHeaderViewStateNormal)
            {
                if(!self.isLayoutedProperly)
                {
                    [self layoutIfNeeded];
                    self.isLayoutedProperly = YES;
                }
                if(offset < -kSwitchStateOffset)
                {
                    self.state = PTRefreshTableHeaderViewStatePulling;
                }
            }
            else if(self.state == PTRefreshTableHeaderViewStatePulling)
            {
                NSAssert(self.isLayoutedProperly, @"Must be layouted properly");
                if(offset >= -kSwitchStateOffset)
                {
                    self.state = PTRefreshTableHeaderViewStateNormal;
                }
            }
        }
    }
}

-(void) tableViewDidEndDragging
{
    if(self.state == PTRefreshTableHeaderViewStatePulling)
    {
        UIEdgeInsets contentInset = self.tableView.contentInset;
        contentInset.top += kRefreshViewHeight;
        CGPoint contentOffset = self.tableView.contentOffset;
        self.tableView.contentInset = contentInset;
        // Restore contentOffset because after contentInset is changed and tableView sets wrong contentOffset
        self.tableView.contentOffset = contentOffset;
        
        self.state = PTRefreshTableHeaderViewStateLoading;
        [self.delegate refreshTableHeaderViewDidStartLoading:self];
    }
}

-(void) tableViewDidEndScrollingAnimation
{
    self.tableView.scrollEnabled = YES;
    [self applyDeferredContentInset];
}

#pragma mark -
#pragma mark Private methods

-(void) setState:(PTRefreshTableHeaderViewState) state
{
    switch(state)
    {
        case PTRefreshTableHeaderViewStatePulling:
        {
            [self.activityIndicatorView stopAnimating];
            [UIView animateWithDuration:kArrowFlipAnimationDuration
                             animations:^{
                                 self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
                             }];
            
            break;
        }
        case PTRefreshTableHeaderViewStateNormal:
        {
            [self.activityIndicatorView stopAnimating];
            self.arrowImageView.hidden = NO;
            if(_state == PTRefreshTableHeaderViewStatePulling)
            {
                [UIView animateWithDuration:kArrowFlipAnimationDuration
                                 animations:^{
                                     self.arrowImageView.transform = CGAffineTransformIdentity;
                                 }];
            }
            
            break;
        }
        case PTRefreshTableHeaderViewStateLoading:
        {
            [self.activityIndicatorView startAnimating];
            
            self.arrowImageView.transform = CGAffineTransformIdentity;
            self.arrowImageView.hidden = YES;
            
            break;
        }
    }
    
    _state = state;
}

-(BOOL) isVisible
{
    return (self.tableView.contentOffset.y - kRefreshViewHeight < -self.tableView.contentInset.top);
}

-(void) configureUI
{
    self.frame = CGRectMake(0, -kRefreshViewHeight, self.tableView.bounds.size.width, kRefreshViewHeight);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.backgroundView = [UIView new];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = kBackgroundViewAlpha;
    [self addSubview:self.backgroundView];
    [self.backgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [PTUIUtils addLayoutConstraintToView:self.backgroundView toMatchSuperViewAttribute:NSLayoutAttributeLeft];
    [PTUIUtils addLayoutConstraintToView:self.backgroundView toMatchSuperViewAttribute:NSLayoutAttributeRight];
    [PTUIUtils addLayoutConstraintToView:self.backgroundView toMatchSuperViewAttribute:NSLayoutAttributeBottom];
    self.backgroundViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:0.0f];
    [self addConstraint:self.backgroundViewHeightConstraint];
    
    
    self.arrowImageView = [UIImageView new];
    [self addSubview:self.arrowImageView];
    [PTUIUtils addLayoutConstraintToView:self.arrowImageView toMatchSuperViewAttribute:NSLayoutAttributeCenterX];
    [PTUIUtils addLayoutConstraintToView:self.arrowImageView toMatchSuperViewAttribute:NSLayoutAttributeCenterY];
    
    self.activityIndicatorView = [UIActivityIndicatorView new];
    [self addSubview:self.activityIndicatorView];
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    [PTUIUtils addLayoutConstraintToView:self.activityIndicatorView toMatchSuperViewAttribute:NSLayoutAttributeCenterX];
    [PTUIUtils addLayoutConstraintToView:self.activityIndicatorView toMatchSuperViewAttribute:NSLayoutAttributeCenterY];
}

-(void) setTableViewContentInset:(UIEdgeInsets) contentInset animated:(BOOL) animated
{
    self.hasDeferredContentInset = NO;
    
    if(animated)
    {
        if(contentInset.top < self.tableView.contentInset.top)
        {
            self.tableView.scrollEnabled = NO;
            self.deferredContentInset = contentInset;
            self.hasDeferredContentInset = YES;
            [self.tableView setContentOffset:CGPointMake(0, -kRefreshViewHeight) animated:YES];
        }
        else
        {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.tableView.contentInset = contentInset;
            }];
        }
    }
    else
    {
        self.tableView.contentInset = contentInset;
    }
}

-(void) applyDeferredContentInset
{
    if(self.hasDeferredContentInset)
    {
        self.hasDeferredContentInset = NO;
        self.tableView.contentInset = self.deferredContentInset;
    }
}

@end
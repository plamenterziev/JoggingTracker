//
//  PTActivityIndicatorHUD.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTActivityIndicatorHUD : NSObject

-(void) show;
-(void) hide;
-(void) showWithCompletion:(void(^)()) completion;
-(void) hideWithCompletion:(void(^)()) completion;
-(void) showInView:(UIView*) view withCompletion:(void(^)()) completion;
-(void) hideInView:(UIView*) view withCompletion:(void(^)()) completion;
-(void) showInViewController:(UIViewController*) viewController withCompletion:(void(^)()) completion;

@end

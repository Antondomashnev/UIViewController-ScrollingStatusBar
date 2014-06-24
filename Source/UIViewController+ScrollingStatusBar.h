//
//  UIViewController+ScrollingStatusBar.h
//  UIViewControllerScrollingStatusBar
//
//  Created by Anton Domashnev on 25.06.14.
//  Copyright (c) 2014 Anton Domashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ScrollingStatusBar)

- (void)enableStatusBarScrollingAlongScrollView:(UIScrollView *)scrollView;
- (void)disableStatusBarScrollingAlongScrollView:(UIScrollView *)scrollView;

@end

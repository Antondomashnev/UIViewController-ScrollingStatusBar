//
//  UIViewController+ScrollingStatusBar.m
//  UIViewControllerScrollingStatusBar
//
//  Created by Anton Domashnev on 25.06.14.
//  Copyright (c) 2014 Anton Domashnev. All rights reserved.
//

#import "UIViewController+ScrollingStatusBar.h"

#import <objc/runtime.h>

@interface ADScrollingHandler : NSObject

- (instancetype)initWithDidScrollBlock:(void(^)(UIScrollView *scrollView))didScrollBlock;

@end

NSString* const ADScrollingHandlerDidScrollBlock = @"ADScrollingHandlerDidScrollBlock";

@implementation ADScrollingHandler

- (instancetype)initWithDidScrollBlock:(void(^)(UIScrollView *scrollView))didScrollBlock
{
    if(self = [super init]){
        self.didScrollBlock = didScrollBlock;
    }
    return self;
}

#pragma mark - Properties

- (void)setDidScrollBlock:(void(^)(UITableView *tableView))didScrollBlock
{
    objc_setAssociatedObject(self, (__bridge const void *)(ADScrollingHandlerDidScrollBlock), didScrollBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(UITableView *tableView))didScrollBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(ADScrollingHandlerDidScrollBlock));
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(![keyPath isEqualToString:@"contentOffset"]){
        return;
    }
    
    if(self.didScrollBlock){
        self.didScrollBlock(object);
    }
}

@end


NSString* const UIViewControllerScrollingStatusBarContext = @"UIViewControllerScrollingStatusBarContext";
NSString* const UIViewControllerScrollingHandler = @"UIViewControllerScrollingHandler";
NSString* const UIViewControllerStatusBarView = @"UIViewControllerStatusBarView";
NSString* const UIViewControllerStatusBarWindow = @"UIViewControllerStatusBarWindow";

@implementation UIViewController (ScrollingStatusBar)

#pragma mark - Properties

- (void)setScrollingHandler:(ADScrollingHandler *)handler
{
    objc_setAssociatedObject(self, (__bridge const void *)(UIViewControllerScrollingHandler), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ADScrollingHandler *)scrollingHandler
{
    return objc_getAssociatedObject(self, (__bridge const void *)(UIViewControllerScrollingHandler));
}


- (void)setStatusBarView:(UIView *)statusBarView
{
    objc_setAssociatedObject(self, (__bridge const void *)(UIViewControllerStatusBarView), statusBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)statusBarView
{
    return objc_getAssociatedObject(self, (__bridge const void *)(UIViewControllerStatusBarView));
}

- (void)setStatusBarWindow:(UIView *)statusBarWindow
{
    objc_setAssociatedObject(self, (__bridge const void *)(UIViewControllerStatusBarWindow), statusBarWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)statusBarWindow
{
    return objc_getAssociatedObject(self, (__bridge const void *)(UIViewControllerStatusBarWindow));
}

#pragma mark - UI

static UIWindow *fakeStatusBarWindow = nil;
- (UIWindow *)fakeStatusBarWindow
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fakeStatusBarWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        fakeStatusBarWindow.backgroundColor = [UIColor clearColor];
        fakeStatusBarWindow.userInteractionEnabled = NO;
        fakeStatusBarWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        fakeStatusBarWindow.windowLevel = UIWindowLevelStatusBar;
        fakeStatusBarWindow.hidden = NO;
    });
    return fakeStatusBarWindow;
}

- (void)createStatusBarView
{
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    self.statusBarView = [[UIView alloc] initWithFrame:frame];
    self.statusBarView.clipsToBounds = YES;
    UIView *statusBarImageView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    [self.statusBarView addSubview:statusBarImageView];
    [self.fakeStatusBarWindow addSubview:self.statusBarView];
}

#pragma mark - Helpers

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY > -scrollView.contentInset.top){
        if(!self.statusBarView){
            [self createStatusBarView];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
        self.statusBarView.frame = (CGRect){.origin = CGPointMake(self.statusBarView.frame.origin.x, -scrollView.contentInset.top - offsetY), .size = self.statusBarView.frame.size};
    }
    else{
        if(self.statusBarView){
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [self.statusBarView removeFromSuperview];
            self.statusBarView = nil;
        }
    }
}

#pragma mark - Interface

- (void)enableStatusBarScrollingAlongScrollView:(UIScrollView *)scrollView
{
    __weak id wSelf = self;
    self.scrollingHandler = [[ADScrollingHandler alloc] initWithDidScrollBlock:^(UIScrollView *scrollView) {
        [wSelf scrollViewDidScroll:scrollView];
    }];
    
    [scrollView addObserver:self.scrollingHandler forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:(__bridge void *)(UIViewControllerScrollingStatusBarContext)];
}

- (void)disableStatusBarScrollingAlongScrollView:(UITableView *)scrollView
{
    [scrollView removeObserver:self.scrollingHandler forKeyPath:@"contentOffset" context:(__bridge void *)(UIViewControllerScrollingStatusBarContext)];
}

@end

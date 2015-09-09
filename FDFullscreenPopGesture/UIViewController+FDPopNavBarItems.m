//
//  UIViewController+FDPopNavBarItems.m
//  youyushe
//
//  Created by Pan Xiao Ping on 15/8/17.
//  Copyright (c) 2015年 cimu. All rights reserved.
//

#import "UIViewController+FDPopNavBarItems.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <objc/runtime.h>

void *FDNavigationBarDelegateContext = &FDNavigationBarDelegateContext;
void *FDCurrentItem = &FDCurrentItem;
void *FDNavigationBar = &FDNavigationBar;

void MethodSwizzle(Class c, SEL origSEL, SEL newSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = nil;
    if (!origMethod) {
        origMethod = class_getClassMethod(c, origSEL);
        newMethod = class_getClassMethod(c, newSEL);
    }else{
        newMethod = class_getInstanceMethod(c, newSEL);
    }
    
    if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@interface FDNavigationBarDelegate : NSObject <UINavigationBarDelegate>
@property (weak) UIViewController *refViewController;
@end
@implementation FDNavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self.refViewController.navigationController popViewControllerAnimated:YES];
    return NO;
}
@end

@implementation UIViewController (FDPopNavBarItems)
+ (void)load {
    MethodSwizzle(self.class, @selector(viewWillAppear:), @selector(fdp_viewWillAppear:));
    MethodSwizzle(self.class, @selector(setTitle:), @selector(fdp_setTitle:));
}

- (void)fdp_viewWillAppear:(BOOL)animted {
    [self fdp_viewWillAppear:animted];
    
    if (self.fd_prefersNavigationBarHidden) {
        [self fd_setupNavigationBar];
        UINavigationBar *navbar = [self fd_navigationBar];
        CGRect frame = self.navigationController.navigationBar.frame;
        navbar.frame = CGRectMake(0, 20, CGRectGetWidth(frame), CGRectGetHeight(frame));
    } else {
        UINavigationBar *navbar = objc_getAssociatedObject(self, FDNavigationBar);
        if (navbar) {
            [navbar removeFromSuperview];
            objc_setAssociatedObject(self, FDNavigationBar, NULL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

- (void)fdp_setTitle:(NSString *)title {
    [self fdp_setTitle:title];
    
    UINavigationItem *currentItem = objc_getAssociatedObject(self, FDCurrentItem);
    currentItem.title = title;
}

- (void)fd_setupNavigationBar {
    UINavigationBar *navbar = [self fd_navigationBar];
    if (!navbar.superview) {
        [self.view addSubview:navbar];
    }
    
    if (!navbar.items.count) {
        NSInteger vcIndex = [self.navigationController.viewControllers indexOfObject:self];
        if (vcIndex != NSNotFound && vcIndex > 0) {
            UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:vcIndex -1];
            UINavigationItem *previousItem = [[UINavigationItem alloc] initWithTitle:previousViewController.navigationItem.title ?: previousViewController.title];
            [navbar pushNavigationItem:previousItem animated:NO];
        }
        [navbar pushNavigationItem:self.fd_navigationItem animated:NO];
    }
}

- (UINavigationItem *)fd_navigationItem {
    UINavigationItem *currentItem = objc_getAssociatedObject(self, FDCurrentItem);
    if (!currentItem) {
        currentItem = [[UINavigationItem alloc] init];
        currentItem.title = self.title;
        objc_setAssociatedObject(self, FDCurrentItem, currentItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return currentItem;
}

- (UINavigationBar *)fd_navigationBar {
    UINavigationBar *navbar = objc_getAssociatedObject(self, FDNavigationBar);
    if (!navbar) {
        navbar = [[UINavigationBar alloc] init];
        navbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        navbar.tintColor = [[UINavigationBar appearance] tintColor];
        navbar.backgroundColor = [UIColor blackColor];
        navbar.backgroundColor = [UIColor clearColor];
        
        FDNavigationBarDelegate *barDelegate = [FDNavigationBarDelegate new];
        barDelegate.refViewController = self;
        navbar.delegate = barDelegate;
        
        UIView *barBackground = [navbar.subviews firstObject];
        barBackground.hidden = YES;
        
        objc_setAssociatedObject(self, FDNavigationBarDelegateContext, barDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, FDNavigationBar, navbar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return navbar;
}
@end

//
//  UIViewController+FDPopNavBarItems.h
//  youyushe
//
//  Created by Pan Xiao Ping on 15/8/17.
//  Copyright (c) 2015年 cimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FDPopNavBarItems)

/**
 *  Generate a new UINavigationBar when fd_prefersNavigationBarHidden = YES
 *
 *  @return UINavigationItem
 */
- (UINavigationItem *)fd_navigationItem;

- (UINavigationBar *)fd_navigationBar;
@end

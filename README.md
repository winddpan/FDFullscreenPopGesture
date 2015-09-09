# Patch - FDFullscreenPopGesture

增加了fd_prefersNavigationBarHidden时导航条的支持，不需要手动创建无背景的导航栏。


![snapshot](https://https://github.com/winddpan/FDFullscreenPopGesture/blob/master/Snapshots/snapshot3.png)

# Usage

    UIViewController *viewController;
    [[viewController fd_navigationItem] setTitle:@"this is title"];
    [[viewController fd_navigationBar] setBarTintColor:[UIColor redColor]];
    
# License  
MIT

SlideMenuController2
===========================

iOS slide menu controller.

## Usage

``` objective-c
CenterViewController *centerViewController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
self.navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];

MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];

self.slideController = [[SlideMenuController alloc] initWithCenterViewController:self.navigationController];
self.slideController.leftViewController = menuViewController;
    
self.window.rootViewController = self.slideController;
[self.window makeKeyAndVisible];
```

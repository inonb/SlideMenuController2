SlideMenuController2
===========================

iOS slide menu controller.

## Usage

### Setup
In AppDelegate window initializing,
``` objective-c
SlideMenuController slideMenuController = [[SlideMenuController alloc] initWithCenterViewController:centerViewController];
slideMenuController.leftViewController = menuViewController;
// Set window root view or something...
```

### Menu Slide
``` objective-c
[slideMenuController presentLeftViewControllerAnimated:YES]; // Show Left
[slideMenuController presentCenterViewControllerAnimated:YES]; // Show Center
[slideMenuController presentRightViewControllerAnimated:YES]; // Show Right
```

### Option
Draggable
``` objective-c
slideMenuController.draggable = YES;
```

Tap to slide
``` objective-c
slideMenuController.tapToSlide = YES;
```

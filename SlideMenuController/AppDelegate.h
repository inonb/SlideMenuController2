//
//  AppDelegate.h
//  SlideViewControllerDemo
//
//  Created by inoue on 2013/09/02.
//  Copyright (c) 2013年 Inoue Takayuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideMenuController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) SlideMenuController *slideMenuController;

@end

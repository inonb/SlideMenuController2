//
//  TKSlideViewController.m
//
//  Created by Inoue Takayuki on 2012/09/20.
//  Copyright (c) 2012年 inoue. All rights reserved.
//

#import "SlideMenuController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    TKSlideDragDirectionNone = 0,
    TKSlideDragDirectionLeftOpen = 1,
    TKSlideDragDirectionRightOpen = 2,
    TKSlideDragDirectionLeftClose = 3,
    TKSlideDragDirectionRightClose = 4,
} TKSlideDragDirection;

@interface SlideMenuController () <UIGestureRecognizerDelegate> {
    BOOL _animationInProgress;
    CGPoint _dragOrigin;
    TKSlideDragDirection _dragDirection;
    CGPoint _panVelocity;
}

@property (strong, nonatomic) NSMutableArray *gestureRecognizers;
@property (strong, nonatomic) UIView *lockView;

CGFloat SlideThreshold(void);
UIInterfaceOrientation InterfaceOrientation(void);
CGRect ScreenBounds(void);
CGFloat StatusBarHeight(void);
BOOL IsLandscape(UIInterfaceOrientation orientation);

@end

@implementation SlideMenuController

@synthesize centerViewController = _centerViewController;
@synthesize leftViewController = _leftViewController;
@synthesize rightViewController = _rightViewController;

@synthesize position = _position;
@synthesize slideOffset = _slideOffset;
@synthesize shadow = _shadow;

@synthesize tapToSlide = _tapToSlide;
@synthesize draggable = _draggable;

@synthesize gestureRecognizers = _gestureRecognizers;

#pragma mark - Initialize

- (id)initWithCenterViewController:(UIViewController *)controller
{
    self = [super init];
    if (self) {        
        _position = TKSlidePositionCenter;
        _dragDirection = TKSlideDragDirectionNone;
        
        _slideOffset = 60;
        self.shadow = YES;
        
        _tapToSlide = YES;
        _draggable = YES;
        
        _gestureRecognizers = [NSMutableArray array];
        
        self.centerViewController = controller;

    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    CGRect rect  = ScreenBounds();
    rect.size.height -= StatusBarHeight();
    self.view = [[UIView alloc] initWithFrame:rect];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.clipsToBounds = YES;
    self.view.autoresizesSubviews = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadViewControllers];
}

- (void)reloadViewControllers
{
    if (_centerViewController && !_centerViewController.view.superview) {
        UIViewController *newController = _centerViewController;
        self.centerViewController = nil;
        self.centerViewController = newController;
    }
    if (_leftViewController && !_leftViewController.view.superview) {
        UIViewController *newController = _leftViewController;
        self.leftViewController = nil;
        self.leftViewController = newController;
    }
    if (_rightViewController && !_rightViewController.view.superview) {
        UIViewController *newController = _rightViewController;
        self.rightViewController = nil;
        self.rightViewController = newController;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_centerViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_centerViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_centerViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_centerViewController viewDidDisappear:animated];
}

#pragma mark - Child Controllers

- (void)setCenterViewController:(UIViewController *)controller
{
//    if (controller == _centerViewController) return;

    [self removeControllerFromView:_centerViewController animated:NO];
    
    _centerViewController = controller;
    
    if (_centerViewController) {
        if (OveriOS5) {
            [_centerViewController willMoveToParentViewController:self];
            [self addChildViewController:_centerViewController];
        }
        
        if (!OveriOS5) [_centerViewController viewWillAppear:NO];
        [self.view addSubview:_centerViewController.view];
        if (!OveriOS5) [_centerViewController viewDidAppear:NO];
        
        if (OveriOS5) [_centerViewController didMoveToParentViewController:self];
        
        if (_shadow) [self addCenterViewShadow];
        [self setGestureRecognizer];
        [self enableTapToSlide:NO];
    }
}

- (void)setLeftViewController:(UIViewController*)controller
{
    if (controller == _leftViewController) return;
    
    if (_leftViewController.view.superview) [self removeControllerFromView:_leftViewController animated:NO];
    
    _leftViewController = controller;
    
    if (controller) {
        CGRect frame = self.view.bounds;
        frame.size.width -= _slideOffset;
        controller.view.frame = frame;
    }
    
    [self setSideViewController:controller];
}

- (void)setRightViewController:(UIViewController*)controller
{
    if (controller == _rightViewController) return;
    
    if (_rightViewController.view.superview) [self removeControllerFromView:_rightViewController animated:NO];
    
    _rightViewController = controller;

    if (controller) {
        CGRect frame = self.view.bounds;
        frame.size.width -= _slideOffset;
        frame.origin.x += _slideOffset;
        controller.view.frame = frame;
    }
    
    [self setSideViewController:controller];
}

- (void)setSideViewController:(UIViewController *)controller
{
    if (!controller) return;
    
    if (OveriOS5) [controller willMoveToParentViewController:self];
    
    [self.view insertSubview:controller.view atIndex:0];
    
    if (OveriOS5) {
        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];
    }
    controller.view.hidden = YES;
}

- (void)removeControllerFromView:(UIViewController*)controller animated:(BOOL)animated
{
    if (OveriOS5) [controller willMoveToParentViewController:nil];
    if (!OveriOS5) [controller viewWillDisappear:animated];
    
    [controller.view removeFromSuperview];
    
    if (!OveriOS5) [controller viewDidDisappear:animated];
    
    if (OveriOS5) {
        [controller removeFromParentViewController];
        [controller didMoveToParentViewController:nil];
    }
}

- (void)presentCenterViewControllerAnimated:(BOOL)animated
{
    if (!self.centerViewController || self.position == TKSlidePositionCenter) return;
    
    if (self.position == TKSlidePositionLeft) {
        [self.leftViewController viewWillDisappear:animated];
    } else if (self.position == TKSlidePositionRight) {
        [self.rightViewController viewWillDisappear:animated];
    }
    [self.centerViewController viewWillAppear:YES];
    
    if (animated) {
        
        _animationInProgress = YES;
        
        CGRect frame = self.centerViewController.view.frame;
        CGFloat width = ABS(frame.origin.x);
        CGFloat duration = [self slideDuration:width];

        [UIView animateWithDuration:duration animations:^{

            CGRect frame = self.centerViewController.view.frame;
            frame.origin.x = 0;
            self.centerViewController.view.frame = frame;
            
        } completion:^(BOOL finished) {

            if (self.position == TKSlidePositionLeft) {
                [self.leftViewController viewDidDisappear:animated];
            } else if (self.position == TKSlidePositionRight) {
                [self.rightViewController viewDidDisappear:animated];
            }
            [self.centerViewController viewDidAppear:animated];
            
            [self enableTapToSlide:NO];
            
            self.leftViewController.view.hidden = YES;
            self.rightViewController.view.hidden = YES;
            _position = TKSlidePositionCenter;
            _animationInProgress = NO;
            
            [self lockControllCenterViewController:NO];
        }];
        
    } else {
        CGRect frame = self.centerViewController.view.frame;
        frame.origin.x = 0;
        self.centerViewController.view.frame = frame;
        
        [self.centerViewController viewDidAppear:YES];
        
        if (self.position == TKSlidePositionLeft) {
            [self.leftViewController viewDidDisappear:animated];
        } else if (self.position == TKSlidePositionRight) {
            [self.rightViewController viewDidDisappear:animated];
        }
        
        [self enableTapToSlide:NO];
        
        self.leftViewController.view.hidden = YES;
        self.rightViewController.view.hidden = YES;
        _position = TKSlidePositionCenter;
        
        [self lockControllCenterViewController:NO];
    }
}

- (void)presentLeftViewControllerAnimated:(BOOL)animated
{
    if (!self.leftViewController || self.position == TKSlidePositionLeft) return;
    
    self.leftViewController.view.hidden = NO;
    
    [self.centerViewController viewWillDisappear:animated];
    [self.leftViewController viewWillAppear:animated];
    
    if (animated) {
        _animationInProgress = YES;
        
        CGRect frame = self.centerViewController.view.frame;
        CGFloat width = ABS(frame.origin.x - (frame.size.width - _slideOffset));
        CGFloat duration = [self slideDuration:width];
        
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.centerViewController.view.frame;
            frame.origin.x = frame.size.width - _slideOffset;
            self.centerViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            _position = TKSlidePositionLeft;
            _animationInProgress = NO;
            
            [self enableTapToSlide:YES];
            
            [self.centerViewController viewDidDisappear:YES];
            [self.leftViewController viewDidAppear:YES];
            
            [self lockControllCenterViewController:YES];
        }];

    } else {
        
        CGRect frame = self.centerViewController.view.frame;
        frame.origin.x = frame.size.width - _slideOffset;
        self.centerViewController.view.frame = frame;
        
        [self enableTapToSlide:YES];
        
        [self.centerViewController viewDidDisappear:YES];
        [self.leftViewController viewDidAppear:YES];
        
        _position = TKSlidePositionLeft;
        
        [self lockControllCenterViewController:YES];
    }
}

- (void)presentRightViewControllerAnimated:(BOOL)animated
{
    if (!self.rightViewController || self.position == TKSlidePositionRight) return;
    
    [self.centerViewController viewWillDisappear:animated];
    [self.rightViewController viewWillAppear:animated];

    self.rightViewController.view.hidden = NO;

    if (animated) {
        _animationInProgress = YES;
        
        CGRect frame = self.centerViewController.view.frame;
        CGFloat width = frame.origin.x - (_slideOffset - frame.size.width);
        CGFloat duration = [self slideDuration:width];
        
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.centerViewController.view.frame;
            frame.origin.x = _slideOffset - frame.size.width;
            self.centerViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            _position = TKSlidePositionRight;
            _animationInProgress = NO;
            
            [self enableTapToSlide:YES];

            [self.centerViewController viewDidDisappear:animated];
            [self.rightViewController viewDidAppear:animated];
            
            [self lockControllCenterViewController:YES];
        }];

    } else {
        CGRect frame = self.centerViewController.view.frame;
        frame.origin.x = _slideOffset - frame.size.width;
        self.centerViewController.view.frame = frame;

        [self enableTapToSlide:YES];

        [self.centerViewController viewDidDisappear:animated];
        [self.rightViewController viewDidAppear:animated];
        
        _position = TKSlidePositionRight;
        _animationInProgress = NO;
        
        [self lockControllCenterViewController:YES];
    }
}

- (void)presentCenterViewController:(UIViewController *)controller Animated:(BOOL)animated
{
    controller.view.frame = self.centerViewController.view.frame;
    self.centerViewController = controller;
    [self presentCenterViewControllerAnimated:animated];
}

- (void)presentLeftViewController:(UIViewController *)controller Animated:(BOOL)animated
{
    controller.view.frame = self.leftViewController.view.frame;
    self.leftViewController = controller;
    [self presentLeftViewControllerAnimated:animated];
}

- (void)presentRightViewController:(UIViewController *)controller Animated:(BOOL)animated
{
    controller.view.frame = self.rightViewController.view.frame;
    self.rightViewController = controller;
    [self presentRightViewControllerAnimated:animated];
}

- (void)lockControllCenterViewController:(BOOL)enabled
{    
    if (enabled) {
        
        UIView *targetView;
        if ([self.centerViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *controller = [((UINavigationController*)self.centerViewController).viewControllers lastObject];
            targetView = controller.view;
        } else {
            targetView = self.centerViewController.view;
        }
        
        if (!self.lockView) {
            self.lockView = [[UIView alloc] initWithFrame:CGRectZero];
            self.lockView.userInteractionEnabled = YES;
        }
        self.lockView.frame = self.centerViewController.view.bounds;
        [targetView addSubview:self.lockView];
        
        if (_tapToSlide) {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToSlide:)];
            
            [targetView addGestureRecognizer:tapGestureRecognizer];
        }
        
        if (_draggable) {
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDrag:)];
            panGestureRecognizer.delegate = self;
            
            [targetView addGestureRecognizer:panGestureRecognizer];
        }
        
    } else {
        
        [self.lockView removeFromSuperview];
    }
}

#pragma mark - Edge Shadow

- (void)setShadow:(BOOL)shadow
{
    if (_shadow == shadow) return;
    
    _shadow = shadow;
    
    if (_shadow) {
        [self addCenterViewShadow];
    } else {
        [self removeCenterViewShadow];
    }
}

- (void)addCenterViewShadow
{
    _centerViewController.view.layer.shadowOffset = CGSizeZero;
    _centerViewController.view.layer.shadowOpacity = 0.5;
    _centerViewController.view.layer.shadowRadius = 6;
    _centerViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _centerViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    _centerViewController.view.clipsToBounds = NO;
}

- (void)removeCenterViewShadow
{
    _centerViewController.view.layer.shadowPath = nil;
    _centerViewController.view.layer.shadowOpacity = 0;
    _centerViewController.view.layer.shadowRadius = 0;
    _centerViewController.view.layer.shadowColor = nil;
}

#pragma mark - Gesture Recognizer

- (void)removeAllGestureRecognizers
{
    for (UIGestureRecognizer* recognizer in _gestureRecognizers) {
        [recognizer.view removeGestureRecognizer:recognizer];
    }
    [_gestureRecognizers removeAllObjects];
}


- (void)setGestureRecognizer
{
    if (!(_tapToSlide||_draggable)) return;

    [self removeAllGestureRecognizers];
    UIViewController *controller;
    UINavigationBar *navigationBar;
    
    if ([_centerViewController isKindOfClass:[UINavigationController class]]) {
        controller = [((UINavigationController*)_centerViewController).viewControllers lastObject];
        navigationBar = [(UINavigationController*)_centerViewController navigationBar];
        
    } else {
        controller = _centerViewController;
    }

    if (_tapToSlide) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToSlide:)];
        
        [controller.view addGestureRecognizer:tapGestureRecognizer];
        [self.gestureRecognizers addObject:tapGestureRecognizer];        
    }
    
    if (_draggable) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDrag:)];
        panGestureRecognizer.delegate = self;
        
        [controller.view addGestureRecognizer:panGestureRecognizer];
        [self.gestureRecognizers addObject:panGestureRecognizer];
        
        if (navigationBar) {
            UIPanGestureRecognizer *panGestureRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDrag:)];
            panGestureRecognizer2.delegate = self;
            
            [navigationBar addGestureRecognizer:panGestureRecognizer2];
            [self.gestureRecognizers addObject:panGestureRecognizer2];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (_animationInProgress) return NO;
    _dragOrigin = self.centerViewController.view.frame.origin;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)enableTapToSlide:(BOOL)enable
{
    for (UIGestureRecognizer *r in self.gestureRecognizers) {
        if ([r isKindOfClass:[UITapGestureRecognizer class]]) {
            r.enabled = enable;
        }
    }
}

- (void)didDrag:(UIPanGestureRecognizer*)gesture
{
    if (_animationInProgress) return;
    
    CGPoint translation = [gesture translationInView:self.view];
        
    if (_dragDirection == TKSlideDragDirectionNone) {
        
        if (_position == TKSlidePositionCenter) {
            if (translation.x > 3 && self.leftViewController) {
                _dragDirection = TKSlideDragDirectionRightOpen;
                self.leftViewController.view.hidden = NO;
                
            } else if (translation.x < -3 && self.rightViewController) {
                _dragDirection = TKSlideDragDirectionLeftOpen;
                self.rightViewController.view.hidden = NO;
                
            } else {
                return;
            }
        } else if (_position == TKSlidePositionLeft || _position == TKSlidePositionRight) {
            if (translation.x > 3) {
                _dragDirection = TKSlideDragDirectionRightClose;
                
            } else if (translation.x < -3) {
                _dragDirection = TKSlideDragDirectionLeftClose;
            }
        }
    }
    
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
                
        if (_dragDirection == TKSlideDragDirectionRightOpen) {
            if (translation.x > SlideThreshold()) {
                [self presentLeftViewControllerAnimated:YES];
            } else {
                [self slideDrawBack];
            }
            
        } else if (_dragDirection == TKSlideDragDirectionLeftOpen) {
            if (translation.x < -SlideThreshold()) {
                [self presentRightViewControllerAnimated:YES];
            } else {
                [self slideDrawBack];
            }
            
        } else if (_dragDirection == TKSlideDragDirectionRightClose) {
            
            if (translation.x > SlideThreshold()) {
                [self presentCenterViewControllerAnimated:YES];
            } else {
                [self slideDrawBack];
            }
            
        } else if (_dragDirection == TKSlideDragDirectionLeftClose) {
            
            if (translation.x < -SlideThreshold()) {
                [self presentCenterViewControllerAnimated:YES];
            } else {
                [self slideDrawBack];
            }

        }
        _panVelocity = [gesture velocityInView:self.view];
        _dragDirection = TKSlideDragDirectionNone;
        
    } else {
        
        CGRect frame = self.centerViewController.view.frame;
        frame.origin.x = _dragOrigin.x + translation.x;
        self.centerViewController.view.frame = frame;
    }
}

- (void)slideDrawBack
{
    _animationInProgress = YES;

    CGFloat width = ABS(self.centerViewController.view.frame.origin.x - _dragOrigin.x);
    CGFloat duration = [self slideDuration:width];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.centerViewController.view.frame;
        frame.origin = _dragOrigin;
        self.centerViewController.view.frame = frame;
        
    } completion:^(BOOL finished) {
        _animationInProgress = NO;
        _dragOrigin = CGPointZero;
    }];
}

- (void)didTapToSlide:(UITapGestureRecognizer*)gesture
{
    if (self.position == TKSlidePositionCenter) return;
    [self presentCenterViewControllerAnimated:YES];
}

#pragma mark - Slide Duration

- (CGFloat)slideDuration:(CGFloat)width
{
    if (!_panVelocity.x) {
        return 0.25;
    }

    CGFloat velocityX = ABS(_panVelocity.x);
    _panVelocity = CGPointZero;
    CGFloat duration =  width / velocityX;

    if (duration > 0.25) {
        duration = 0.25;
    }
    return  duration;
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect frame;

    if (self.leftViewController) {
        frame = self.view.bounds;
        frame.size.width -= _slideOffset;
        self.leftViewController.view.frame = frame;
    }
    
    if (self.rightViewController) {
        frame = self.view.bounds;
        frame.size.width -= _slideOffset;
        frame.origin.x += _slideOffset;
        self.rightViewController.view.frame = frame;
    }
}

#pragma mark - View Bounds

BOOL IsLandscape(orientation)
{
    return ((orientation) == UIInterfaceOrientationLandscapeLeft || (orientation) == UIInterfaceOrientationLandscapeRight);
}

UIInterfaceOrientation InterfaceOrientation(void)
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	return orientation;
}

CGRect ScreenBounds(void)
{
	CGRect bounds = [UIScreen mainScreen].bounds;
	if (IsLandscape(InterfaceOrientation())) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	return bounds;
}

CGFloat StatusBarHeight(void)
{
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return 0.0;
    if (IsLandscape(InterfaceOrientation()))
        return [[UIApplication sharedApplication] statusBarFrame].size.width;
    else
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

CGFloat SlideThreshold(void)
{
    CGRect frame = ScreenBounds();
    return frame.size.width / 3;
}

@end

// TKSlideController.h
//  Created by Inoue Takayuki on 2012/09/20.

#define OveriOS5 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5)


@interface SlideMenuController : UIViewController

///-------------------------------------------
/// @name Creating and Initializing Controller
///-------------------------------------------

/**
 Creates and initializes an `TKSlideController` object with child ViewControllers.
 
 @param controllers The child ViewControlles. Left and center of 2 controllers, or left and center and right of 3 controllers.
 @return The initialized New Controller
 */

- (id)initWithCenterViewController:(UIViewController *)controller;

/**
 The center ViewController
 */
@property (strong, nonatomic) UIViewController *centerViewController;

/**
 The left ViewController
 */
@property (strong, nonatomic) UIViewController *leftViewController;

/**
 The right ViewController
 */
@property (strong, nonatomic) UIViewController *rightViewController;


///-------------------------------------------
/// @name Switching Controllers
///-------------------------------------------

/**
 Present center controller.
 */
- (void)presentCenterViewControllerAnimated:(BOOL)animated;

- (void)presentCenterViewController:(UIViewController *)controller Animated:(BOOL)animated;


/**
 Present left side controller.
 */
- (void)presentLeftViewControllerAnimated:(BOOL)animated;

- (void)presentLeftViewController:(UIViewController *)controller Animated:(BOOL)animated;

/**
 Present right side controller.
 */
- (void)presentRightViewControllerAnimated:(BOOL)animated;

- (void)presentRightViewController:(UIViewController *)controller Animated:(BOOL)animated;


/** @enum TKSlidePosition
 Position of Controller
 */
typedef enum {
    TKSlidePositionLeft = 0,
    TKSlidePositionCenter = 1,
    TKSlidePositionRight = 2,
} TKSlidePosition;

/**
 The current position of Controller.
 */
@property (readonly) TKSlidePosition position;

/**
 The offset of sliding. Default is 60.
 */
@property (assign) CGFloat slideOffset;

/**
 A Boolean value that corresponds to whether the center ViewController have edge shadow. Default is YES;
 */
@property (assign, nonatomic) BOOL shadow;

/**
 A Boolean value whether to close by tapping the center view. Default is YES;
 */
@property (assign, nonatomic) BOOL tapToSlide;

/**
 A Boolean value whether to drag the center view. Default is YES;
 */
@property (assign, nonatomic) BOOL draggable;


@end

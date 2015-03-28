//
//  MONActivityIndicatorView.m
//
//  Created by Mounir Ybanez on 4/24/14.
//

#import <QuartzCore/QuartzCore.h>
#import "MONActivityIndicatorView.h"

@interface MONActivityIndicatorView ()

/** The default color of each circle. */
@property (strong, nonatomic) UIColor *defaultColor;

/** An indicator whether the activity indicator view is animating. */
@property (readwrite, nonatomic) BOOL isAnimating;

/**
 Sets up default values
 */
- (void)setupDefaults;

/**
 Adds circles.
 */
- (void)addCircles;

/**
 Removes circles.
 */
- (void)removeCircles;

/**
 Adjusts self's frame.
 */
- (void)adjustFrame;

/**
 Creates the circle view.
 @param radius The radius of the circle.
 @param color The background color of the circle.
 @param positionX The x-position of the circle in the contentView.
 @return The circle view.
 */
- (UIView *)createCircleWithRadius:(CGFloat)radius color:(UIColor *)color positionX:(CGFloat)x;

/**
 Creates the animation of the circle.
 @param duration The duration of the animation.
 @param delay The delay of the animation
 @return The animation of the circle.
 */
- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay;

@property (nonatomic, retain) UIView *loadingView;

@end

@implementation MONActivityIndicatorView
//@synthesize loadingMessage;

#pragma mark -
#pragma mark - Initializations

- (id)initWithMessage:(NSString *)message {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 568)];
    if (self) {
        self.loadingView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.loadingView];
        
        [self setupDefaults];
        self.loadingMessage = message;
        //[self setFrame:CGRectMake(0, 0, 640, 1136)];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Methods

- (void)setupDefaults {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberOfCircles = 8;
    self.internalSpacing = 3;
    self.radius = 10;
    self.delay = 0.2;
    self.duration = 0.6;
    self.defaultColor = [UIColor lightGrayColor];
    self.loadingMessage = @"Loading...";
    //[self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
}

- (UIView *)createCircleWithRadius:(CGFloat)radius
                             color:(UIColor *)color
                         positionX:(CGFloat)x {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(x, 0, radius * 2, radius * 2)];
    circle.backgroundColor = color;
    circle.layer.cornerRadius = radius;
    circle.translatesAutoresizingMaskIntoConstraints = NO;
    return circle;
}

- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.delegate = self;
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.autoreverses = YES;
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.beginTime = CACurrentMediaTime()+delay;
    anim.repeatCount = INFINITY;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}

- (void)addCircles {
    for (NSUInteger i = 0; i < self.numberOfCircles; i++) {
        UIColor *color = nil;
        /*
        if (self.delegate && [self.delegate respondsToSelector:@selector(activityIndicatorView:circleBackgroundColorAtIndex:)]) {
            color = [self.delegate activityIndicatorView:self circleBackgroundColorAtIndex:i];
        }*/
        color = [self activityIndicatorView:self circleBackgroundColorAtIndex:i];
        UIView *circle = [self createCircleWithRadius:self.radius
                                                color:(color == nil) ? self.defaultColor : color
                                            positionX:(i * ((2 * self.radius) + self.internalSpacing))];
        [circle setTransform:CGAffineTransformMakeScale(0, 0)];
        [circle.layer addAnimation:[self createAnimationWithDuration:self.duration delay:(i * self.delay)] forKey:@"scale"];
        [self.loadingView addSubview:circle];
    }
}

- (void)removeCircles {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}

- (void)adjustFrame {
    CGRect frame = self.loadingView.frame;
    frame.size.width = (self.numberOfCircles * ((2 * self.radius) + self.internalSpacing)) - self.internalSpacing;
    frame.size.height = self.radius * 2;
    self.loadingView.frame = frame;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.center.y-45, 320, 24)];
    [titleLable setText:self.loadingMessage];
    [titleLable setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:titleLable];
    
    self.loadingView.center = self.center;
}

#pragma mark -
#pragma mark - Public Methods

- (void)startAnimating {
    if (!self.isAnimating) {
        [self addCircles];
        self.hidden = NO;
        self.isAnimating = YES;
    }
}

- (void)stopAnimating {
    if (self.isAnimating) {
        [self removeCircles];
        self.hidden = YES;
        self.isAnimating = NO;
    }
}

#pragma mark -
#pragma mark - Custom Setters and Getters

- (void)setNumberOfCircles:(NSUInteger)numberOfCircles {
    _numberOfCircles = numberOfCircles;
    [self adjustFrame];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self adjustFrame];
}

- (void)setInternalSpacing:(CGFloat)internalSpacing {
    _internalSpacing = internalSpacing;
    [self adjustFrame];
}

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    CGFloat red   = (arc4random() % 256)/255.0;
    CGFloat green = (arc4random() % 256)/255.0;
    CGFloat blue  = (arc4random() % 256)/255.0;
    CGFloat alpha = 0.6f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

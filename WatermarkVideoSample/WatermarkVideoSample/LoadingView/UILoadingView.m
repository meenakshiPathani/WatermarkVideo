//
//  UILoadingView.m
//  
//
//

#import <QuartzCore/QuartzCore.h>

#import "UILoadingView.h"

@implementation UILoadingView

+ (UILoadingView*) loadingView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"UILoadingView" owner:self options:nil] objectAtIndex:0];
}

- (void) showViewAnimated:(BOOL)animated onView:(UIView*)view
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.superview)
        return;
    
    CGRect rect = [[UIScreen mainScreen] bounds];//([UIUtils isiPhone]) ? CGRectMake(0,0,320,548) : CGRectMake(0,0,768,1024);
    [self setFrame:rect];
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
	
    if (animated)
        [self animateShow];
	
	_activityIndicator.hidden = NO;
	_percentLabel.hidden = YES;
	_progressView.hidden = YES;
    [self activityLabelWithText:@"Loading..."];
	_progressView.progress = 0.0;
	_percentLabel.text = @"0 %";
    
    [_activityIndicator startAnimating];
}

- (void) showProgressAnimated:(BOOL)animated onView:(UIView*)view
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.superview)
        return;
    
    CGRect rect = [[UIScreen mainScreen] bounds];//([UIUtils isiPhone]) ? CGRectMake(0,0,320,548) : CGRectMake(0,0,768,1024);
	
    [self setFrame:rect];
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
    if (animated)
        [self animateShow];
	
    _activityIndicator.hidden = YES;
	_percentLabel.hidden = NO;
	_progressView.hidden = NO;
    [self activityLabelWithText:@"Submitting..."];
	
	[_borderView addSubview:_progressView];
}

- (void) removeViewAnimated:(BOOL)animated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (!self.superview)
        return;
    
    [_activityIndicator stopAnimating];

    if (animated)
        [self animateRemove];
    else
        [self removeView];    
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self performSelector:@selector(privateInit) withObject:nil afterDelay:0.01];
    }
    return self;
}

- (void) animateShow
{
    self.alpha = 0.0;
    _borderView.transform = CGAffineTransformMakeScale(3.0, 3.0);
    
	[UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationDuration:5.0];            // Uncomment to see the animation in slow motion
	
    _borderView.transform = CGAffineTransformIdentity;
    self.alpha = 1.0;
    
	[UIView commitAnimations];
}

- (void) animateRemove;
{
    _borderView.transform = CGAffineTransformIdentity;
    
	[UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationDuration:5.0];            // Uncomment to see the animation in slow motion
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
	
    _borderView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.alpha = 0.0;
    
	[UIView commitAnimations];
}


- (void) removeView
{
    [self removeFromSuperview];
}

- (void) removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    [self removeView];
}

- (void) privateInit
{
    [self setupBackground];
    [self setBorderView];;
    [self activityLabelWithText:@"Loading..."];
}

- (void) setupBackground
{
    self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
}

- (void) setBorderView;
{
    _borderView.opaque = NO;
    _borderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _borderView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _borderView.layer.cornerRadius = 10.0;
}

- (void) activityLabelWithText:(NSString*)labelText;
{
    _activityLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _activityLabel.textAlignment = NSTextAlignmentCenter;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.backgroundColor = [UIColor clearColor];
    _activityLabel.shadowColor = [UIColor blackColor];
    _activityLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _activityLabel.text = labelText;
}

- (void) setLoadingTitle:(NSString*)title
{
	_activityLabel.text = title;
}

- (void) setProgreesbarProgress:(float)progressValue
{
	_progressView.progress = progressValue;
	_percentLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progressValue*100)];
}

@end

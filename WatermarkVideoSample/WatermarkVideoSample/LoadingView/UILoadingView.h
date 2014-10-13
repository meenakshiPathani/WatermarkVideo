//
//  UILoadingView.h
//  
//

@interface UILoadingView : UIView
{
    IBOutlet UIView* _borderView;
    IBOutlet UILabel* _activityLabel;
	IBOutlet UIProgressView* _progressView;
	IBOutlet UILabel* _percentLabel;

    IBOutlet UIActivityIndicatorView* _activityIndicator;
}

+ (UILoadingView*) loadingView;

- (void) showViewAnimated:(BOOL)animated onView:(UIView*)view;
- (void) showProgressAnimated:(BOOL)animated onView:(UIView*)view;
- (void) removeViewAnimated:(BOOL)animated;
- (void) setLoadingTitle:(NSString*)title;
- (void) setProgreesbarProgress:(float)progressValue;

@end

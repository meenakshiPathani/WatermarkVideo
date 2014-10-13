//
//  AppDelegate.h
//  WatermarkVideoSample
//
//  Created by Meenakshi on 05/09/14.
//  Copyright (c) 2014 Mindfire Solutions. All rights reserved.
//

#import "UILoadingView.h"
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
	UILoadingView*		_loadingView;
}

@property (strong, nonatomic) UIWindow *window;

- (void) showLoadingView:(BOOL)show;

@end

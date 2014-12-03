//
//  AppDelegate.h
//  VideoInset
//
//  Created by Sumit Gupta on 8/13/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppOrientationDelegate <NSObject>

- (void) orientationDidChangedFromOrientation:(UIInterfaceOrientation)oldOrientation toOrientation:(UIInterfaceOrientation)currentOrientation;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray *assets;
    id<AppOrientationDelegate> _orientationDelegate;
}
@property (strong, nonatomic)    NSMutableArray *assets;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<AppOrientationDelegate> orientationDelegate;

@end

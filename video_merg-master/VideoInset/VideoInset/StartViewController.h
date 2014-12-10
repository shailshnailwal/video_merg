//
//  StartViewController.h
//  VideoInset
//
//  Created by Sumit Gupta on 8/20/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTAssetsPickerController.h"
#import "AppDelegate.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MainViewController.h"

@interface StartViewController : UIViewController<CTAssetsPickerControllerDelegate>

@property(nonatomic,retain) UIImagePickerController *cameraPicker;
-(IBAction)btnPickVideosPressed:(id)sender;
-(IBAction)btnPickAudioPressed:(UIButton *)sender;
-(IBAction)btnMergePressed:(UIButton *)sender;
@end

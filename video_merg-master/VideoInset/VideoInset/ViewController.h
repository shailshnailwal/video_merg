//
//  ViewController.h
//  VideoInset
//
//  Created by Sumit Gupta on 8/13/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTAssetsPickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CTAssetsPageViewController.h"
#import "VideoPlayerViewController.h"
#import "VTime.h"

@interface ViewController : UIViewController <CTAssetsPickerControllerDelegate,UIImagePickerControllerDelegate>
{
    NSMutableArray *assets;

    NSMutableDictionary *dicTime;
    NSMutableArray * arrSeconds;
    CMTime currentTime;
    NSDate *startTime;
    id lastSelectedAssest;
    CMTimeRange timeRange1;
    CMTimeRange timeRange2;
    NSURL *recordedVideoURL;
}
  @property(nonatomic,strong)    NSURL *recordedVideoURL;
@property(nonatomic,weak)     IBOutlet UIView *overLayview;
@property(nonatomic,weak)     id lastSelectedAssest;
  @property(nonatomic,strong)      NSDate *startTime;
  @property(nonatomic,strong)  NSMutableArray * arrSeconds;
@property(assign)     CMTime currentTime;
@property(assign) CMTimeRange timeRange1;
@property(assign)CMTimeRange timeRange2;
@property(nonatomic,retain) UIImagePickerController *cameraPicker;

@property(nonatomic,strong)    NSMutableDictionary *dicTime;
@property(nonatomic,strong)  VideoPlayerViewController *myPlayerViewController;

@property(nonatomic,weak) IBOutlet   IBOutlet    UIView *viewPrimary;
@property(nonatomic,weak) IBOutlet   IBOutlet    UIButton *btn1;
@property(nonatomic,weak) IBOutlet   IBOutlet    UIButton *btn2;


@property(nonatomic,weak) IBOutlet   IBOutlet    UIImageView *imgViewPrimary;
@property(nonatomic,weak) IBOutlet   IBOutlet   UIImageView *imgViewInset;

@property (nonatomic, copy) NSArray *assets;
-(IBAction)btnPickTapped:(id)sender;

-(IBAction)btnVideoTapped1:(id)sender;
-(IBAction)btnVideoTapped2:(id)sender;

@end

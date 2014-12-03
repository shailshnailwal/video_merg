//
//  MainViewController.h
//  VideoInset
//
//  Created by Sumit Gupta on 8/20/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "CTAssetsPickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CTAssetsPageViewController.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CommonVC.h"
#import "VTime.h"

@interface MainViewController : CommonVC<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    MPMoviePlayerController *moviePlayer;
    CMTime                  startTime;
    NSMutableArray          *arrRanges;
    NSMutableDictionary     *playBackTime;
    
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIButton     *_cameraBtn;
    IBOutlet UIButton     *_mergeBtn;
    IBOutlet UIButton     *_addCameraBtn;
    
    NSURL *recordedVideoURL;
    
    /**/
    NSMutableArray  *_videoBtnList;
    CGRect          _floatingPlayerFrame;
    NSMutableArray  *_sequenceList;
    
    /***/
    AVCaptureVideoDataOutput *_capturedVideo;
}

@property(nonatomic,retain) UIImagePickerController *cameraPicker;
@property(nonatomic,strong) NSURL *recordedVideoURL;
//@property(nonatomic,strong) IBOutlet UIScrollView *scrollView;

@property(nonatomic,retain) NSMutableDictionary *playBackTime;
@property(nonatomic,retain) NSMutableArray *arrRanges;
@property(assign)    CMTime startTime;

@property(nonatomic,retain) MPMoviePlayerController *moviePlayer;

@property(nonatomic,weak) IBOutlet UIView *overlaye;
@property(nonatomic,weak) IBOutlet UIButton *btn1;
@property(nonatomic,weak) IBOutlet UIButton *btn2;

-(IBAction)showCamera:(id)sender;
-(IBAction)btnVideoItemPressed:(id)sender;
-(IBAction)btnMergePressed:(id)sender;
-(IBAction)addCameraVideo:(UIButton *)sender;
- (void) mergeVideosOneURLWorking:(NSURL *)videoOneURL andVideoTwoURL:(NSURL *)videoTwoURL ;
@end

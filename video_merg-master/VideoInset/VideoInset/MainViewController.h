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
#import <AVFoundation/AVFoundation.h>
#import "CTAssetsPageViewController.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>

#import "CommonVC.h"
#import "MediaButton.h"
#import "VTime.h"

@interface MainViewController : CommonVC<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate>
{
    MPMoviePlayerController *moviePlayer;
    CMTime                  startTime;
    NSMutableArray          *arrRanges;
    NSMutableDictionary     *playBackTime;
    
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIButton     *_cameraBtn;
    IBOutlet UIButton     *_mergeBtn;
    IBOutlet UIButton     *_addCameraBtn;
    IBOutlet UIImageView  *_imageView;
    
    NSURL *recordedVideoURL;
    
    /**/
    NSMutableArray  *_videoBtnList;
    CGRect          _floatingPlayerFrame;
    NSMutableArray  *_sequenceList;
    
    /***/
    AVCaptureVideoDataOutput *_capturedVideo;
    AVCaptureSession *_captureSession;
    AVCaptureMovieFileOutput *_capturedFile;
    
    BOOL _isImage;
    int _totalPicked;
    int _imagePicked;
}

@property(nonatomic,retain) UIImagePickerController *cameraPicker;
@property(nonatomic,strong) NSURL *recordedVideoURL;
//@property(nonatomic,strong) IBOutlet UIScrollView *scrollView;

@property(nonatomic,retain) NSMutableDictionary *playBackTimeInfo;
@property(nonatomic,retain) NSMutableArray *arrRanges;
@property(assign)    CMTime startTime;

@property(nonatomic,retain) MPMoviePlayerController *moviePlayer;

@property(nonatomic,weak) IBOutlet UIView *overlaye;
@property(nonatomic,weak) IBOutlet UIButton *btn1;
@property(nonatomic,weak) IBOutlet UIButton *btn2;

-(IBAction)showCamera:(id)sender;
-(IBAction)btnVideoItemPressed:(MediaButton *)sender;
-(IBAction)btnMergePressed:(id)sender;
-(IBAction)addCameraVideo:(UIButton *)sender;
- (void) mergeVideosOneURLWorking:(NSURL *)videoOneURL andVideoTwoURL:(NSURL *)videoTwoURL ;
@end

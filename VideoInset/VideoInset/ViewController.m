//
//  ViewController.m
//  VideoInset
//
//  Created by Sumit Gupta on 8/13/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImagePickerController+oritation.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize recordedVideoURL;
@synthesize startTime;
@synthesize overLayview;
@synthesize arrSeconds;
@synthesize  timeRange1;
@synthesize  timeRange2;
@synthesize cameraPicker;
@synthesize myPlayerViewController;
@synthesize assets,imgViewPrimary,imgViewInset;
@synthesize viewPrimary;
@synthesize dicTime;
- (void)viewDidLoad
{
    [super viewDidLoad];
    dicTime=[[NSMutableDictionary alloc] init];
    self.arrSeconds=[[NSMutableArray alloc] init];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(IBAction)btnCameraTapped:(id)sender
{
    
    //    self.overLayview.frame=CGRectMake(300, 300, self.view.frame.size.width, self.view.frame.size.height);
//    
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.delegate = self;
//    //imagePicker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
//    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
//    [self presentViewController:imagePicker animated:YES completion:nil];
//    return;
    
    self.cameraPicker = [[UIImagePickerController alloc] init];
    self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraPicker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
    self.cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    self.cameraPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    self.cameraPicker.showsCameraControls = NO;
    self.cameraPicker.navigationBarHidden = YES;
    self.cameraPicker.toolbarHidden = YES;
    
    // self.cameraPicker.wantsFullScreenLayout = NO;
    
//    [self.cameraPicker shouldAutorotate];
    
    // Insert the overlay
    // self.overlay = [[OverlayViewController alloc] initWithNibName:@"Overlay" bundle:nil];
    
    self.cameraPicker.cameraOverlayView = self.view;
    self.cameraPicker.delegate = self;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation == UIDeviceOrientationLandscapeLeft)
    {
        CGAffineTransform transform = self.view.transform;
        transform = CGAffineTransformRotate(transform, (M_PI/2.0));
        self.cameraPicker.cameraOverlayView.transform = transform;
    }
    else if(orientation == UIDeviceOrientationLandscapeRight)
    {
        self.cameraPicker.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,117.81);
    }
    

    
    //    [self presentModalViewController:self.cameraPicker animated:NO];
    [self presentViewController:self.cameraPicker animated:YES completion:^{
            [self.cameraPicker startVideoCapture];
    }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)btnPickTapped:(id)sender
{
    /*
     self.cameraPicker = [[UIImagePickerController alloc] init];
     self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
     self.cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
     self.cameraPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
     self.cameraPicker.showsCameraControls = NO;
     self.cameraPicker.navigationBarHidden = YES;
     self.cameraPicker.toolbarHidden = YES;
     //    self.cameraPicker.wantsFullScreenLayout = NO;
     [self.cameraPicker shouldAutorotate];
     
     // Insert the overlay
     //    self.overlay = [[OverlayViewController alloc] initWithNibName:@"Overlay" bundle:nil];
     
     self.cameraPicker.cameraOverlayView = self.view;
     self.cameraPicker.delegate = self;
     
     UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
     if(orientation == UIDeviceOrientationLandscapeLeft)
     {
     CGAffineTransform transform = self.view.transform;
     transform = CGAffineTransformRotate(transform, (M_PI/2.0));
     self.cameraPicker.cameraOverlayView.transform = transform;
     }
     else if(orientation == UIDeviceOrientationLandscapeRight)
     {
     self.cameraPicker.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,117.81);
     }
     
     //    [self presentModalViewController:self.cameraPicker animated:NO];
     [self presentViewController:self.cameraPicker animated:YES completion:^{
     
     }];
     return;
     
     */
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allVideos];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.selectedAssets       = [NSMutableArray arrayWithArray:self.assets];
    picker.title = @"Pick Videos";
    picker.showsNumberOfAssets = NO;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}


-(IBAction)btnDoneTapped:(id)sender
{
    
    [self.cameraPicker stopVideoCapture];
    
    
    [self addTimeRangeForAsses:self.lastSelectedAssest];
    
    //    [self    doExport];
    
}
-(void)doExport
{
    ALAsset *assest1=[self.assets objectAtIndex:0];
    ALAssetRepresentation *representation = [assest1 defaultRepresentation];
    NSURL *url1 = [representation url];
    
    ALAsset *assest2=[self.assets lastObject];
    ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
    NSURL *url2 = [representation2 url];
    
    //    for overlapping
    //[self videoOverlappingMethodWithVideoOneURL:url1 andVideoTwoURL:url2];
    
    
    // FOR MERGING
    [self mergeVideosOneURL:url1 andVideoTwoURL:url2];
    
    
    // [self oldImp];
}


- (void) mergeVideosOneURL:(NSURL *)videoOneURL andVideoTwoURL:(NSURL *)videoTwoURL {
    //Here we load our movie Assets using AVURLAsset
    
    NSLog(@"start export");
    //addedd ProgressHud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVMutableComposition*    mixComposition;
    AVMutableVideoComposition*    mainComposition;
    
    AVAsset *firstAsset;
    AVAsset *secondAsset;
    AVAsset *thirdAsset;
    if (videoOneURL!= nil && videoTwoURL!=nil) {
        
        //First Video
        //firstAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample1" ofType:@"m4v"]] options:nil];
        NSLog(@"First Asset = %@",firstAsset);
        
        firstAsset = [AVAsset assetWithURL:videoOneURL];
        
        //second Video
        //secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"m4v"]] options:nil];
        NSLog(@"second Asset = %@",secondAsset);
        secondAsset = [AVAsset assetWithURL:videoTwoURL];
        
        thirdAsset = [AVAsset assetWithURL:self.recordedVideoURL];
    }
    
    float seconds=5;
    if (firstAsset != nil && secondAsset != nil) {
        //Create AVMutableComposition object
        
        mixComposition = [[AVMutableComposition alloc] init];
        // create first track
        
        //Main Instruction Layer
        //crete Object of main Instruction layer and set timerange to it
        
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        
        AVMutableCompositionTrack *firstTrack =
        [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                    preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        CMTime firstTime=CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + seconds,firstAsset.duration.timescale);
        CMTimeRange firstRange=CMTimeRangeMake(kCMTimeZero, firstTime);
        
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstTime)
                            ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        //Duraton For Final Video should be max Duration of both video
        CMTime finalDuration;
        
        //InstructionLayer for first Track
        
        AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        CGAffineTransform scale = CGAffineTransformMakeScale(0.2f, 0.2f);
        
        CGAffineTransform move = CGAffineTransformMakeTranslation(00, 0);
        
        float s = 0.5;//size.width/size.height;
        float fpsValue=30;
        CGSize temp = CGSizeApplyAffineTransform(firstTrack.naturalSize, firstTrack.preferredTransform);
        CGSize size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        CGAffineTransform transform = firstTrack.preferredTransform;
        if (size.width > size.height) {
            [firstlayerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        } else {
            
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x =320; //(size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [firstlayerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        }
        [firstlayerInstruction setTransform:CGAffineTransformConcat(scale, move) atTime:kCMTimeZero];
        CGAffineTransform new2 = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0,0));
        [firstlayerInstruction setTransform:new2 atTime:firstRange.duration];
        
        
        UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
        BOOL  isFirstAssetPortrait_  = NO;
        CGAffineTransform firstTransform = firstTrack.preferredTransform;
        
        if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
        if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
        CGFloat FirstAssetScaleToFitRatio = 320.0/firstTrack.naturalSize.width;
        if(isFirstAssetPortrait_){
            FirstAssetScaleToFitRatio = 320.0/firstTrack.naturalSize.height;
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [firstlayerInstruction setTransform:CGAffineTransformConcat(firstTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
        }else{
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [firstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(firstTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
        }
        
        
        
        
        
        
        //second SIDE VIDEOS
        //InstructionLayer for second Track
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        CMTime secondTime=CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + seconds,secondAsset.duration.timescale);
        CMTimeRange secondRange=CMTimeRangeMake(firstRange.duration, secondTime);
        
        [secondTrack insertTimeRange:secondRange
                             ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                              atTime:firstRange.duration
                               error:nil];
        
        
        AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        
        CGAffineTransform secondScale = CGAffineTransformMakeScale(0.2f,0.2f);
        
        CGAffineTransform secondMove = CGAffineTransformMakeTranslation(0,0);
        
        //[secondlayerInstruction setOpacity:0.5 atTime:kCMTimeZero];
        
        
        temp = CGSizeApplyAffineTransform(secondTrack.naturalSize, secondTrack.preferredTransform);
        size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        
        transform = secondTrack.preferredTransform;
        
        if (size.width > size.height) {
            [secondlayerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        } else {
            float s = 0.5;//size.width/size.height;
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x =320; //(size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [secondlayerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        }
        
        
        
        [secondlayerInstruction setTransform:CGAffineTransformConcat(secondScale,secondMove) atTime:kCMTimeZero];
        
        
        
        
        
        
        finalDuration = CMTimeAdd(firstRange.duration, secondRange.duration);
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,finalDuration);
        
        
        
        //Now adding FirstInstructionLayer and SecondInstructionLayer to mainInstruction
        
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction,secondlayerInstruction, nil];
        
        
        
        
        // attach Main Instrcution To VideoCopositionn
        //we can attch multipe Instrction to it
        
        mainComposition = [AVMutableVideoComposition videoComposition];
        mainComposition.instructions = [NSArray arrayWithObjects:mainInstruction,nil];
        mainComposition.frameDuration = CMTimeMake(1, 30);
        mainComposition.renderSize = CGSizeMake(640, 480);
        
        
        //  Get path
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergeVideo.mov"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:myPathDocs error:NULL];
        NSURL*  url = [NSURL fileURLWithPath:myPathDocs];
        NSLog(@"URL:-  %@", [url description]);
        
        //create Exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainComposition;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
                NSLog(@"end export");
            });
        }];
    }else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Video Not Selected.PLease select videos to merege"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
    
}



- (void) mergeVideosOneURLWorking:(NSURL *)videoOneURL andVideoTwoURL:(NSURL *)videoTwoURL {
    //Here we load our movie Assets using AVURLAsset
    
    NSLog(@"start export");
    //addedd ProgressHud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVMutableComposition*    mixComposition;
    AVMutableVideoComposition*    mainComposition;
    
    AVAsset *firstAsset;
    AVAsset *secondAsset;
    AVAsset *thirdAsset;
    if (videoOneURL!= nil && videoTwoURL!=nil) {
        
        //First Video
        //firstAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample1" ofType:@"m4v"]] options:nil];
        NSLog(@"First Asset = %@",firstAsset);
        
        firstAsset = [AVAsset assetWithURL:videoOneURL];
        
        //second Video
        //secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"m4v"]] options:nil];
        NSLog(@"second Asset = %@",secondAsset);
        secondAsset = [AVAsset assetWithURL:videoTwoURL];
        
        thirdAsset = [AVAsset assetWithURL:self.recordedVideoURL];
    }
    
    float seconds=5;
    if (firstAsset != nil && secondAsset != nil) {
        //Create AVMutableComposition object
        
        mixComposition = [[AVMutableComposition alloc] init];
        // create first track
        
        //Main Instruction Layer
        //crete Object of main Instruction layer and set timerange to it
        
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        
        AVMutableCompositionTrack *firstTrack =
        [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                    preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        CMTime firstTime=CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + seconds,firstAsset.duration.timescale);
        CMTimeRange firstRange=CMTimeRangeMake(kCMTimeZero, firstTime);
        
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstTime)
                            ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        //Duraton For Final Video should be max Duration of both video
        CMTime finalDuration;
        
        //InstructionLayer for first Track
        
        AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        CGAffineTransform scale = CGAffineTransformMakeScale(0.2f, 0.2f);
        
        CGAffineTransform move = CGAffineTransformMakeTranslation(00, 0);
        
        float s = 0.5;//size.width/size.height;
        float fpsValue=30;
        CGSize temp = CGSizeApplyAffineTransform(firstTrack.naturalSize, firstTrack.preferredTransform);
        CGSize size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        CGAffineTransform transform = firstTrack.preferredTransform;
        if (size.width > size.height) {
            [firstlayerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        } else {
            
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x =320; //(size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [firstlayerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        }
        [firstlayerInstruction setTransform:CGAffineTransformConcat(scale, move) atTime:kCMTimeZero];
        CGAffineTransform new2 = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0,0));
        [firstlayerInstruction setTransform:new2 atTime:firstRange.duration];
        
        
        UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
        BOOL  isFirstAssetPortrait_  = NO;
        CGAffineTransform firstTransform = firstTrack.preferredTransform;
        
        if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
        if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
        CGFloat FirstAssetScaleToFitRatio = 320.0/firstTrack.naturalSize.width;
        if(isFirstAssetPortrait_){
            FirstAssetScaleToFitRatio = 320.0/firstTrack.naturalSize.height;
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [firstlayerInstruction setTransform:CGAffineTransformConcat(firstTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
        }else{
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [firstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(firstTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
        }
        
        
        
        
        
        
        //second SIDE VIDEOS
        //InstructionLayer for second Track
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        CMTime secondTime=CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + seconds,secondAsset.duration.timescale);
        CMTimeRange secondRange=CMTimeRangeMake(firstRange.duration, secondTime);
        
        [secondTrack insertTimeRange:secondRange
                             ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                              atTime:firstRange.duration
                               error:nil];
        
        
        AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        
        CGAffineTransform secondScale = CGAffineTransformMakeScale(0.2f,0.2f);
        
        CGAffineTransform secondMove = CGAffineTransformMakeTranslation(0,0);
        
        //[secondlayerInstruction setOpacity:0.5 atTime:kCMTimeZero];
        
        
        temp = CGSizeApplyAffineTransform(secondTrack.naturalSize, secondTrack.preferredTransform);
        size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        
        transform = secondTrack.preferredTransform;
        
        if (size.width > size.height) {
            [secondlayerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        } else {
            float s = 0.5;//size.width/size.height;
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x =320; //(size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [secondlayerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        }
        
        
        
        [secondlayerInstruction setTransform:CGAffineTransformConcat(secondScale,secondMove) atTime:kCMTimeZero];
        
        
        
        
        
        
        finalDuration = CMTimeAdd(firstRange.duration, secondRange.duration);
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,finalDuration);
        
        
        
        
        
        ///
        //        LEFT SIDE VIDEOS
        //InstructionLayer for second Track
        
        
        
        AVMutableCompositionTrack *thirdTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        CMTime thirdTime=CMTimeMakeWithSeconds(CMTimeGetSeconds(finalDuration) ,secondAsset.duration.timescale);
        CMTimeRange thirdRange=CMTimeRangeMake(kCMTimeZero, thirdTime);
        
        
        [thirdTrack insertTimeRange:thirdRange
                            ofTrack:[[thirdAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        
        AVMutableVideoCompositionLayerInstruction *thirdlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:thirdTrack];
        
        
        CGAffineTransform thirdScale = CGAffineTransformMakeScale(0.5f,0.5f);
        
        CGAffineTransform thirdMove = CGAffineTransformMakeTranslation(320,0);
        
        //[secondlayerInstruction setOpacity:0.5 atTime:kCMTimeZero];
        
        
        
        temp = CGSizeApplyAffineTransform(thirdTrack.naturalSize, thirdTrack.preferredTransform);
        size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        
        transform = thirdTrack.preferredTransform;
        
        if (size.width > size.height) {
            [thirdlayerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        } else {
            float s = 0.5;//size.width/size.height;
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x =320; //(size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [thirdlayerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        }
        
        
        //        [thirdlayerInstruction setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(2.9,60), CMTimeMakeWithSeconds(8.0, 60))];
        
        [thirdlayerInstruction setTransform:CGAffineTransformConcat(thirdScale,thirdMove) atTime:kCMTimeZero];
        
        
        
        
        
        
        //Now adding FirstInstructionLayer and SecondInstructionLayer to mainInstruction
        
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction,secondlayerInstruction,thirdlayerInstruction, nil];
        
        
        
        
        // attach Main Instrcution To VideoCopositionn
        //we can attch multipe Instrction to it
        
        mainComposition = [AVMutableVideoComposition videoComposition];
        mainComposition.instructions = [NSArray arrayWithObjects:mainInstruction,nil];
        mainComposition.frameDuration = CMTimeMake(1, 30);
        mainComposition.renderSize = CGSizeMake(640, 480);
        
        
        //  Get path
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergeVideo.mov"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:myPathDocs error:NULL];
        NSURL*  url = [NSURL fileURLWithPath:myPathDocs];
        NSLog(@"URL:-  %@", [url description]);
        
        //create Exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainComposition;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
                NSLog(@"end export");
            });
        }];
    }else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Video Not Selected.PLease select videos to merege"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
    
}

-(void)oldImp
{
    
    /*
     ALAsset *assest1=[self.assets objectAtIndex:0];
     ALAssetRepresentation *representation = [assest1 defaultRepresentation];
     NSURL *url1 = [representation url];
     
     //Create an AVAsset from the given URL
     NSDictionary *asset_options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
     AVURLAsset* firstAsset = [[AVURLAsset alloc] initWithURL:url1 options:asset_options];//[AVURLAsset URLAssetWithURL:url options:asset_options];
     
     
     
     ALAsset *assest2=[self.assets objectAtIndex:1];
     ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
     NSURL *url2 = [representation2 url];
     //Create an AVAsset from the given URL
     NSDictionary *asset_options2 = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
     AVURLAsset * secondAsset  = [[AVURLAsset alloc] initWithURL:url2 options:asset_options2];//[AVURLAsset
     
     
     */
    
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1,24);
    videoComposition.renderScale = 1.0;
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    float time = 0;
    CMTime sTime;
    CMTime eTime ;
    
    NSMutableArray *arrInstructions=[[NSMutableArray alloc] init];
    for (int i = 0; i<self.arrSeconds.count; i++)
    {
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
        
        NSDictionary *dicObje = [self.arrSeconds objectAtIndex:i ] ;
        NSString *strSeconds;
        NSArray *arr=[dicObje allKeys];
        if (arr.count>0 ) {
            strSeconds=[arr objectAtIndex:0];
        }
        
        ALAsset *assest2=[dicObje objectForKey:strSeconds] ;
        ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
        NSURL *url2 = [representation2 url];
        //Create an AVAsset from the given URL
        NSDictionary *asset_options2 = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset * sourceAsset  = [[AVURLAsset alloc] initWithURL:url2 options:asset_options2];//[AVURLAsset
        
        if (i==0) {
            sTime=kCMTimeZero;
        }
        CMTime timeToAdd   = CMTimeMakeWithSeconds([strSeconds floatValue],1);
        
        eTime  = CMTimeAdd(sTime,timeToAdd);
        NSError *error = nil;
        BOOL ok = NO;
        AVAssetTrack *sourceVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        float fpsValue=30;
        CGSize temp = CGSizeApplyAffineTransform(sourceVideoTrack.naturalSize, sourceVideoTrack.preferredTransform);
        CGSize size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        CGAffineTransform transform = sourceVideoTrack.preferredTransform;
        
        
        videoComposition.renderSize = sourceVideoTrack.naturalSize;
        //        videoComposition.renderSize = CGSizeMake(480, 320);
        NSLog(@"size %f %f",sourceVideoTrack.naturalSize.height,sourceVideoTrack.naturalSize.width);
        
        if (size.width > size.height) {
            [layerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(time, fpsValue)];
        } else {
            float s = 0.5;//size.width/size.height;
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x = (size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [layerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(time, fpsValue)];
        }
        
        //        CMTimeMakeWithSeconds(CMTimeGetSeconds(cmtime) + 10, sourceAsset.duration.timescale);
        CMTimeRange timeRange=CMTimeRangeMake(sTime, eTime);
        
        ok = [compositionVideoTrack insertTimeRange:timeRange ofTrack:sourceVideoTrack atTime:timeRange.start error:&error];
        
        if (!ok) {
            // Deal with the error.
            NSLog(@"something went wrong");
        }
        
        NSLog(@"\n source asset duration is %f \n source vid track timerange is %f %f \n composition duration is %f \n composition vid track time range is %f %f",CMTimeGetSeconds([sourceAsset duration]), CMTimeGetSeconds(sourceVideoTrack.timeRange.start),CMTimeGetSeconds(sourceVideoTrack.timeRange.duration),CMTimeGetSeconds([composition duration]), CMTimeGetSeconds(compositionVideoTrack.timeRange.start),CMTimeGetSeconds(compositionVideoTrack.timeRange.duration));
        
        time += CMTimeGetSeconds(timeRange.duration);
        [arrInstructions addObject:layerInstruction];
        sTime=eTime;
    }
    
    time=0;
    
    //************************************************
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    
    ALAsset *assest2=[self.assets objectAtIndex:0] ;
    ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
    NSURL *url2 = [representation2 url];
    //Create an AVAsset from the given URL
    NSDictionary *asset_options2 = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset * sourceAsset  = [[AVURLAsset alloc] initWithURL:url2 options:asset_options2];//[AVURLAsset
    
    sTime=kCMTimeZero;
    
    NSError *error = nil;
    BOOL ok = NO;
    AVAssetTrack *sourceVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    float fpsValue=30;
    
    eTime  = sourceAsset.duration;
    
    
    CGSize temp = CGSizeApplyAffineTransform(sourceVideoTrack.naturalSize, sourceVideoTrack.preferredTransform);
    CGSize size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
    CGAffineTransform transform = sourceVideoTrack.preferredTransform;
    
    
    //    videoComposition.renderSize = sourceVideoTrack.naturalSize;
    //        videoComposition.renderSize = CGSizeMake(480, 320);
    NSLog(@"size %f %f",sourceVideoTrack.naturalSize.height,sourceVideoTrack.naturalSize.width);
    
    if (size.width > size.height) {
        [layerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(time, fpsValue)];
    } else {
        float s = 0.5;//size.width/size.height;
        CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
        float x =videoComposition.renderSize.width/2; //(size.height - size.width*s)/2;
        CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
        [layerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(time, fpsValue)];
    }
    
    //        CMTimeMakeWithSeconds(CMTimeGetSeconds(cmtime) + 10, sourceAsset.duration.timescale);
    CMTimeRange timeRange=CMTimeRangeMake(sTime, eTime);
    
    ok = [compositionVideoTrack insertTimeRange:timeRange ofTrack:sourceVideoTrack atTime:timeRange.start error:&error];
    
    if (!ok) {
        // Deal with the error.
        NSLog(@"something went wrong");
    }
    
    NSLog(@"\n source asset duration is %f \n source vid track timerange is %f %f \n composition duration is %f \n composition vid track time range is %f %f",CMTimeGetSeconds([sourceAsset duration]), CMTimeGetSeconds(sourceVideoTrack.timeRange.start),CMTimeGetSeconds(sourceVideoTrack.timeRange.duration),CMTimeGetSeconds([composition duration]), CMTimeGetSeconds(compositionVideoTrack.timeRange.start),CMTimeGetSeconds(compositionVideoTrack.timeRange.duration));
    
    [arrInstructions addObject:layerInstruction];
    // ***********************************************
    
    
    
    
    instruction.layerInstructions = [NSArray arrayWithArray:arrInstructions];
    instruction.timeRange = compositionVideoTrack.timeRange;
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:@"overlapVideo.mov"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
    }
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.detailsLabelText=@"Processing...";
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    [exporter setVideoComposition:videoComposition];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:exporter];
             [hud hide:YES];
         });
     }];
}


#pragma mark - Private Methods

- (void)videoOverlappingMethodWithVideoOneURL:(NSURL *)videoOneURL andVideoTwoURL:(NSURL *)videoTwoURL {
    
    
    NSLog(@"start export");
    //addedd ProgressHud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVMutableComposition*    mixComposition;
    AVMutableVideoComposition*    mainComposition;
    
    AVAsset *firstAsset;
    AVAsset *secondAsset;
    if (videoOneURL!= nil && videoTwoURL!=nil) {
        
        
        //First Video
        //firstAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample1" ofType:@"m4v"]] options:nil];
        NSLog(@"First Asset = %@",firstAsset);
        
        firstAsset = [AVAsset assetWithURL:videoOneURL];
        
        //second Video
        //secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"m4v"]] options:nil];
        NSLog(@"second Asset = %@",secondAsset);
        secondAsset = [AVAsset assetWithURL:videoTwoURL];
    }
    
    if (firstAsset != nil && secondAsset != nil) {
        
        //Create AVMutableComposition object
        mixComposition = [[AVMutableComposition alloc] init];
        
        // create first track
        AVMutableCompositionTrack *firstTrack =
        [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                    preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
                            ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        //create second track
        
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration)
                             ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                              atTime:kCMTimeZero
                               error:nil];
        
        //Main Instruction Layer
        //crete Object of main Instruction layer and set timerange to it
        
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        //Duraton For Final Video should be max Duration of both video
        CMTime finalDuration;
        CMTime result;
        
        NSLog(@"values =%f and %f",CMTimeGetSeconds(firstAsset.duration),CMTimeGetSeconds(secondAsset.duration));
        
        if (CMTimeGetSeconds(firstAsset.duration) == CMTimeGetSeconds(secondAsset.duration)) {
            
            finalDuration = firstAsset.duration;
            
        }else if (CMTimeGetSeconds(firstAsset.duration) > CMTimeGetSeconds(secondAsset.duration)) {
            
            finalDuration = firstAsset.duration;
            result = CMTimeSubtract(firstAsset.duration, secondAsset.duration);
            
        }else {
            
            finalDuration = secondAsset.duration;
            result = CMTimeSubtract(secondAsset.duration, firstAsset.duration);
            
        }
        
        //CMTime duration = MAX(secondAsset.duration , firstAsset.duration);
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,finalDuration);
        
        //InstructionLayer for first Track
        
        AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        
        CGAffineTransform scale = CGAffineTransformMakeScale(0.5f, 0.5f);
        CGAffineTransform move = CGAffineTransformMakeTranslation(320, 0);
        
        
        float fpsValue=30;
        
        
        CGSize temp = CGSizeApplyAffineTransform(firstTrack.naturalSize, firstTrack.preferredTransform);
        CGSize size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        
        CGAffineTransform transform = firstTrack.preferredTransform;
        
        if (size.width > size.height) {
            [firstlayerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        } else {
            float s = 0.5;//size.width/size.height;
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x =320; //(size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [firstlayerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        }
        
        
        [firstlayerInstruction setTransform:CGAffineTransformConcat(scale, move) atTime:kCMTimeZero];
        
        
        
        
        
        //        LEFT SIDE VIDEOS
        
        
        
        //InstructionLayer for second Track
        
        AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        
        CGAffineTransform secondScale = CGAffineTransformMakeScale(0.5f,0.5f);
        
        CGAffineTransform secondMove = CGAffineTransformMakeTranslation(0,0);
        
        //[secondlayerInstruction setOpacity:0.5 atTime:kCMTimeZero];
        
        
        
        temp = CGSizeApplyAffineTransform(secondTrack.naturalSize, secondTrack.preferredTransform);
        size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        
        transform = secondTrack.preferredTransform;
        
        if (size.width > size.height) {
            [secondlayerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        } else {
            float s = 0.5;//size.width/size.height;
            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
            float x =320; //(size.height - size.width*s)/2;
            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
            [secondlayerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(0, fpsValue)];
        }
        
        
        [secondlayerInstruction setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(2.9,60), CMTimeMakeWithSeconds(8.0, 60))];
        
        [secondlayerInstruction setTransform:CGAffineTransformConcat(secondScale,secondMove) atTime:kCMTimeZero];
        
        
        
        
        
        
        //Now adding FirstInstructionLayer and SecondInstructionLayer to mainInstruction
        
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction,secondlayerInstruction, nil];
        
        // attach Main Instrcution To VideoCopositionn
        //we can attch multipe Instrction to it
        
        mainComposition = [AVMutableVideoComposition videoComposition];
        mainComposition.instructions = [NSArray arrayWithObjects:mainInstruction,nil];
        mainComposition.frameDuration = CMTimeMake(1, 30);
        mainComposition.renderSize = CGSizeMake(640, 480);
        
        //  Get path
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergeVideo.mov"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:myPathDocs error:NULL];
        NSURL*  url = [NSURL fileURLWithPath:myPathDocs];
        NSLog(@"URL:-  %@", [url description]);
        
        //create Exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainComposition;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
                NSLog(@"end export");
            });
        }];
    }else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Video Not Selected.PLease select videos to merege"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
- (IBAction)buttonTapped:(UIButton *)sender
{
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"X"]) {
        [sender setTitle:@"A very long title for this button"
                forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"X" forState:UIControlStateNormal];
    }
}

//here you have the outputURL of the final overlapped vide0. add your desired task here.
- (void)exportDidFinish:(AVAssetExportSession*)session
{
    //     15:34:13.486
    //     15:36:09.807
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSLog(@"export did finish...");
    NSLog(@"%li", (long)session.status);
    NSLog(@"%@", session.error);
    NSURL *vedioURL = session.outputURL.filePathURL;
    NSLog(@"vurl %@",vedioURL);
    MPMoviePlayerViewController *videoPlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:vedioURL];
    [self presentMoviePlayerViewControllerAnimated:videoPlayerView];
    [videoPlayerView.moviePlayer play];
}
-(IBAction)btnVideoTapped1:(id)sender
{
    [self removeBorderToButton:self.btn2];
    [self addBorderToButton:(UIButton*)sender];
    
    CMTimeRange timeRange= CMTimeRangeMake(self.currentTime, self.myPlayerViewController.player.currentTime);
    
    self.currentTime=self.myPlayerViewController.player.currentTime;
    
    timeRange2=timeRange;
    
    ALAsset *assest1=[self.assets objectAtIndex:0];
    ALAssetRepresentation *representation2 = [assest1 defaultRepresentation];
    NSURL *url2 = [representation2 url];
    
    self.lastSelectedAssest=assest1;
    
    
    [self.myPlayerViewController setURL:url2];
    [self.myPlayerViewController.player play];
    
    ALAsset *assest2=[self.assets objectAtIndex:1];
    [self addTimeRangeForAsses:assest2];
}
-(IBAction)btnVideoTapped2:(id)sender
{
    [self addBorderToButton:(UIButton*)sender];
    [self removeBorderToButton:self.btn1];
    
    ALAsset *assest2=[self.assets objectAtIndex:1];
    
    self.lastSelectedAssest=assest2;
    ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
    NSURL *url2 = [representation2 url];
    
    [self.myPlayerViewController setURL:url2];
    [self.myPlayerViewController.player play];
    
    
    ALAsset *assest1=[self.assets objectAtIndex:0];
    [self addTimeRangeForAsses:assest1];
    
    
    //    self.arrSeconds
    
    //
    //    CMTimeRange timeRange= CMTimeRangeMake(self.currentTime, self.myPlayerViewController.player.currentTime);
    //    self.currentTime=self.myPlayerViewController.player.currentTime;
    //    timeRange1=timeRange;
    //
    //    if ([[dicTime allKeys] count]==0) {
    //        CMTimeRange timeRange= CMTimeRangeMake(self.currentTime, self.myPlayerViewController.player.currentTime);
    //        self.currentTime=self.myPlayerViewController.player.currentTime;
    //        timeRange1=timeRange;
    //
    //     //   [self.dicTime setObject:<#(id)#> forKey:<#(id<NSCopying>)#>]
    //    }
    
    
}

-(void)addTimeRangeForAsses:(id)assest
{
    NSDate *now=[NSDate date];
    float secondsPassed=[now timeIntervalSinceDate: self.startTime];
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:assest,[NSString stringWithFormat:@"%f",secondsPassed], nil];
    [self.arrSeconds addObject:dic];
    self.startTime=now;
    
    
}

-(void)addBorderToButton:(UIButton*)btn
{
    [[btn layer] setBorderWidth:5.0f];
    [[btn layer] setBorderColor:[UIColor greenColor].CGColor];
}

-(void)removeBorderToButton:(UIButton*)btn
{
    [[btn layer] setBorderWidth:0.0f];
    [[btn layer] setBorderColor:[UIColor greenColor].CGColor];
}

#pragma CTAssetsPickerController Delegates
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assetsSelected
{

    self.assets = [NSMutableArray arrayWithArray:assetsSelected];
    
    if ([assetsSelected count]==2) {
        ALAsset *assest1=[assetsSelected objectAtIndex:0];
        imgViewPrimary.image=[UIImage imageWithCGImage:assest1.thumbnail scale:1.0 orientation:UIImageOrientationUp];
        [self.btn1 setImage:[UIImage imageWithCGImage:assest1.thumbnail scale:1.0 orientation:UIImageOrientationUp] forState:UIControlStateNormal];
        
        ALAsset *assest2=[assetsSelected objectAtIndex:1];
        [self.btn2 setImage:[UIImage imageWithCGImage:assest2.thumbnail scale:1.0 orientation:UIImageOrientationUp] forState:UIControlStateNormal];
        self.currentTime=kCMTimeZero;
        // my video player
        VideoPlayerViewController *player = [[VideoPlayerViewController alloc] init];
        ALAssetRepresentation *representation = [assest1 defaultRepresentation];
        NSURL *url1 = [representation url];
        player.URL = url1;
        player.view.frame = self.viewPrimary.frame;
        [self.overLayview addSubview:player.view];
        self.myPlayerViewController = player;
        
        
        [self removeBorderToButton:self.btn2];
        [self addBorderToButton:self.btn1];
        
        self.startTime=[NSDate date];
        
        self.lastSelectedAssest=assest1;
        //add camera
        
        //        self.cameraPicker = [[UIImagePickerController alloc] init];
        //        self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        self.cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        //        self.cameraPicker.showsCameraControls = YES;
        //        self.cameraPicker.delegate = self;
        //        [self.cameraPicker.view setFrame:CGRectMake(self.viewPrimary.frame.size.width,0, 200,200)];
        //        [self.navigationController presentViewController:self.cameraPicker animated:YES completion:^{
        //        }];
        
            [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [self btnCameraTapped:nil];
            }];
    }
    else
    {
        //DO NOTHING FOR NOW
    }
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        recordedVideoURL=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [recordedVideoURL path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
    }
    
    NSLog(@"started");
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self    doExport];
    }];
    
}
@end

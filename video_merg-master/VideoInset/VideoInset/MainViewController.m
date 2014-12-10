//
//  MainViewController.m
//  VideoInset
//
//  Created by Sumit Gupta on 8/20/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import "MainViewController.h"

#define NORMAL_COLOR [UIColor colorWithRed:130/255.0 green:160/255.0 blue:170/255.0 alpha:1.0]
#define SELECTED_COLOR [UIColor colorWithRed:160/255.0 green:130/255.0 blue:170/255.0 alpha:1.0]

#define FLOATING_VIDEO_SCALE_FACTOR .12
#define MAIN_VIDEO_SCALE_FACTOR 1.5
#define IMAGE_TIME 3.0


@implementation MainViewController

@synthesize overlaye;
@synthesize moviePlayer,arrRanges;
@synthesize playBackTimeInfo;
@synthesize recordedVideoURL;
@synthesize startTime;
@synthesize cameraPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrRanges=[[NSMutableArray alloc] init ];
    
    self.playBackTimeInfo=[[NSMutableDictionary alloc] init];
    
    _videoBtnList = [[NSMutableArray alloc] init];
    _sequenceList = [[NSMutableArray alloc] init];
    
    [self.playBackTimeInfo setObject:@"0" forKey:@"AS1"];
    [self.playBackTimeInfo setObject:@"0" forKey:@"AS2"];
    
    _mergeBtn.superview.layer.borderWidth  = 2.0f;
    _mergeBtn.superview.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    _mergeBtn.superview.layer.cornerRadius = 5.0f;
    
    _cameraBtn.superview.layer.borderWidth  = 2.0f;
    _cameraBtn.superview.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    _cameraBtn.superview.layer.cornerRadius = 5.0f;
    
    _floatingPlayerFrame = CGRectMake(40, 65, 220, 180);
    
    
//    _capturedVideo = [[AVCaptureVideoDataOutput alloc] init];
//    [_capturedVideo setSampleBufferDelegate:self queue:NULL];
}

- (void)viewWillAppear:(BOOL)animated{
    
//    if ([self respondsToSelector:@selector(orientationDidChangedFromOrientation:toOrientation:)]) {
//        
//        [self orientationDidChangedFromOrientation:0 toOrientation:[UIApplication sharedApplication].statusBarOrientation];
//    }
    
    _mergeBtn.superview.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    App_Delegate.orientationDelegate = self;
    //[self showCamera];
//    [self showSelectedItems];
    
    // adding observer for getting camera failur message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureFailed:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    App_Delegate.orientationDelegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
}

- (void) showSelectedItems{
    
    AppDelegate *appDel=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _scrollView.hidden=NO;
    
    int count = 0;
    
    int totalWidth = 45;
    UIView *view = nil;
    
    for(id obj in appDel.assets)
    {
        
        [self.playBackTimeInfo setObject:@"0" forKey:[NSString stringWithFormat:@"AS%d",count + 1]];
        
        ALAsset *asset1=obj;
        
        BOOL isImage = [self isImageAsset:asset1];
        
//        NSLog(@"Asset orientation = %@", NSStringFromCGSize(assest1.defaultRepresentation.dimensions));
        
        MediaButton *btn=[[MediaButton alloc]initWithFrame:CGRectMake(0, 2, 36, 54)];
        [btn setImage:[UIImage imageWithCGImage:asset1.thumbnail scale:1.0 orientation:UIImageOrientationUp] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btnVideoItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setTag:count];
//        NSLog(@"Btn Tag is :%ld",(long)btn.tag);
        //btn.tag=count;
        if (isImage) {
            
            btn.mediaButtonType = MediaButtonTypeImage;
        }
        else{
            
            btn.mediaButtonType = MediaButtonTypeVideo;
        }
        
        view = [[UIView alloc] initWithFrame:CGRectMake(count * totalWidth, 0, totalWidth - 2, _scrollView.frame.size.height)];
        [view addSubview:btn];
        btn.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
        
        [_scrollView addSubview:view];
        
        view.backgroundColor = NORMAL_COLOR;
        
        count ++;
        
        [_videoBtnList addObject:btn];
    }
    
    _scrollView.contentSize = CGSizeMake(totalWidth * count, _scrollView.contentSize.height);
}

- (void)goBack:(UIButton *)backButton{
    
    NSLog(@"---------------");
    [super goBack:backButton];
}

-(UIViewController*) getRootViewController {
    
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (BOOL) isImageAsset:(ALAsset *)asset{
    
    return asset && [asset isKindOfClass:[ALAsset class]] && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto];
}

-(IBAction)showCamera:(id)sender{
    
    AppDelegate *appDel=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    ALAsset *assest1=[appDel.assets objectAtIndex:0];
    ALAssetRepresentation *representation = [assest1 defaultRepresentation];
    NSURL *url1 = [representation url];
    
    [self.btn1 setImage:[UIImage imageWithCGImage:assest1.thumbnail scale:1.0 orientation:UIImageOrientationUp] forState:UIControlStateNormal];
    
    if (appDel.assets.count > 1) {
        
        ALAsset *assest2=[appDel.assets objectAtIndex:1];
        [self.btn2 setImage:[UIImage imageWithCGImage:assest2.thumbnail scale:1.0 orientation:UIImageOrientationUp] forState:UIControlStateNormal];
    }
    
    
    [self removeBorderToButton:self.btn2];
    [self addBorderToButton:self.btn1];
    
    self.startTime = kCMTimeZero;
    self.btn1.enabled = false;
    self.btn2.enabled = true;

#if !TARGET_IPHONE_SIMULATOR
    self.cameraPicker                       = [[UIImagePickerController alloc] init];
    self.cameraPicker.sourceType            = UIImagePickerControllerSourceTypeCamera;
    self.cameraPicker.mediaTypes            = [NSArray arrayWithObjects:(NSString*)kUTTypeMovie, (NSString *)kUTTypeAudio, nil];
    self.cameraPicker.cameraCaptureMode     = UIImagePickerControllerCameraCaptureModeVideo;
    self.cameraPicker.cameraDevice          = UIImagePickerControllerCameraDeviceRear;
    self.cameraPicker.showsCameraControls   = NO;
    self.cameraPicker.navigationBarHidden   = YES;
    self.cameraPicker.toolbarHidden         = YES;
    self.cameraPicker.delegate              = self;
    
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation == UIDeviceOrientationLandscapeLeft){
        
        CGAffineTransform transform = self.overlaye.transform;
        transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
    }
    else if(orientation == UIDeviceOrientationLandscapeRight){
        
        self.cameraPicker.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,117.81);
    }
    
    [self presentViewController:self.cameraPicker animated:YES completion:^{
        
        CGRect frame = self.overlaye.frame;
        frame.origin.x = self.cameraPicker.view.frame.size.width;
        frame.origin.y = self.cameraPicker.view.frame.size.height - frame.size.height;
        self.overlaye.frame = frame;
        self.cameraPicker.cameraOverlayView = self.overlaye;
        
        [self settingFloatingPlayerWithAssetURL:url1];
        
        _cameraBtn.superview.hidden = YES;
        _mergeBtn.superview.hidden  = NO;
        
        /**/
        [self showSelectedItems];
        [self performSelector:@selector(showOptions) withObject:nil afterDelay:.2f];
    }];
#endif
}

- (void) showOptions{
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         
                         CGRect frame   = self.overlaye.frame;
                         frame.origin.x = self.cameraPicker.view.frame.size.width - frame.size.width;
                         self.overlaye.frame = frame;
                     } completion:^(BOOL finished) {
                         
                         [self performSelector:@selector(startProcss) withObject:nil afterDelay:1.0];
                     }
     ];
}

- (void) startProcss{
    
    [self btnVideoItemPressed:_videoBtnList.firstObject];
    [self.cameraPicker startVideoCapture];
//    [self initCapture];
}


- (void) captureFailed:(NSNotification *)notification{
    
    NSLog(@"Camera failed");
    [self performSelector:@selector(retry) withObject:nil afterDelay:1.0];
}

// In case camera failed to capture video, make a retry
- (void) retry{
    
#if !TARGET_IPHONE_SIMULATOR
    [self.cameraPicker startVideoCapture];
#endif
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ALAsset *assest1=[appDel.assets objectAtIndex:0];
    ALAssetRepresentation *representation = [assest1 defaultRepresentation];
    NSURL *url1 = [representation url];
    
    [self settingFloatingPlayerWithAssetURL:url1];
}

- (void) settingFloatingPlayerWithAssetURL:(NSURL *)url{
    
    if (moviePlayer) {
        
        [moviePlayer.view removeFromSuperview];
        moviePlayer = nil;
    }
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
    
    [[moviePlayer view] setFrame:_floatingPlayerFrame];
    
    [[self overlaye] addSubview: [moviePlayer view]];
    
    moviePlayer.fullscreen=NO;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
}

-(void)addBorderToButton:(UIButton*)btn{
    
    [[btn layer] setBorderWidth:5.0f];
    [[btn layer] setBorderColor:[UIColor greenColor].CGColor];
}

-(void)removeBorderToButton:(UIButton*)btn{
    
    [[btn layer] setBorderWidth:0.0f];
    [[btn layer] setBorderColor:[UIColor greenColor].CGColor];
}


-(IBAction)addCameraVideo:(UIButton *)sender{
    
    [moviePlayer pause];
}

-(IBAction)btnVideoItemPressed:(MediaButton *)sender{
    
    UIButton *btn=(UIButton*)sender;
    
    [_sequenceList addObject:[NSNumber numberWithInt:(int)btn.tag]];
    
    ALAsset *asset = [App_Delegate.assets objectAtIndex:btn.tag];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSURL *url = [representation url];
    
    _isImage = [self isImageAsset:asset];

    CMTime currentTime;//CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + self.moviePlayer.currentPlaybackTime,600);
    
    VTime *timeRange=[[VTime alloc] init];
    [self.arrRanges addObject:timeRange];
    
    if (_isImage) {
        
        _imageView.hidden = NO;
        [moviePlayer view].hidden = YES;
        _imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        
        _imagePicked ++;
        
        NSLog(@"--------- %d", _imagePicked);
        NSString *keyString = nil;
        UIButton *button = nil;
        
        for (int i = 0; _videoBtnList && i < _videoBtnList.count; i ++) {
            
            button = [_videoBtnList objectAtIndex:i];
            keyString = [NSString stringWithFormat:@"AS%ld", (long)(button.tag + 1)];
            
            if ([keyString isEqualToString:[NSString stringWithFormat:@"AS%ld", (long)(btn.tag + 1)]]) {
                
                btn.enabled=NO;
                [self addBorderToButton:btn];
            }
            else{
                
                [self removeBorderToButton:button];
                button.enabled = YES;
            }
        }
        
        [moviePlayer pause];
    }
    else{
        
        
        _imageView.hidden = YES;
        [moviePlayer view].hidden = NO;
        
        currentTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + self.moviePlayer.currentPlaybackTime,600);
        
        timeRange.startTime = self.startTime;
        timeRange.endTime = currentTime;
        
        NSString *keyString = nil;
        UIButton *button = nil;
        
        for (int i = 0; _videoBtnList && i < _videoBtnList.count; i ++) {
            
            button = [_videoBtnList objectAtIndex:i];
            keyString = [NSString stringWithFormat:@"AS%ld", (long)(button.tag + 1)];
            
            if ([keyString isEqualToString:[NSString stringWithFormat:@"AS%ld", (long)(btn.tag + 1)]]) {
                
                btn.enabled=NO;
                [self addBorderToButton:btn];
            }
            else{
                
                [self.playBackTimeInfo setObject:[NSString stringWithFormat:@"%f",self.moviePlayer.currentPlaybackTime] forKey:keyString];
                
                [self removeBorderToButton:button];
                button.enabled = YES;
            }
        }
        
        [self.moviePlayer setContentURL:url];
        float lastPlayBack=[[self.playBackTimeInfo objectForKey:[NSString stringWithFormat:@"AS%ld", (long)(btn.tag + 1)]] floatValue];
        self.moviePlayer.initialPlaybackTime = lastPlayBack;
        
        self.startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + lastPlayBack + 2 * _imagePicked, 600);
        [self.moviePlayer play];
        
//        NSLog(@"time ranges %@",self.arrRanges);
        
        _totalPicked ++;
    }
//    NSLog(@"-------  get button tag = %@", timeRange);
}


-(IBAction)btnMergePressed:(id)sender{
    
    [self.moviePlayer stop];
    [self.cameraPicker stopVideoCapture];
}

-(void)doExport{
    
    ALAsset *assest1=[App_Delegate.assets objectAtIndex:0];
    ALAssetRepresentation *representation = [assest1 defaultRepresentation];
    NSURL *url1 = [representation url];
    
    ALAsset *assest2=[App_Delegate.assets lastObject];
    ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
    NSURL *url2 = [representation2 url];
    
    [self mergeVideosOneURLWorking:url1 andVideoTwoURL:url2];
    
//    [self mergeAndSave];
}

- (void) mergeVideosOneURLWorking:(NSURL *)videoOneURL andVideoTwoURL:(NSURL *)videoTwoURL {
    //Here we load our movie Assets using AVURLAsset
//-(void) mergeVideoURLsFromURLList:(NSArray *)urlList{
    
    NSLog(@"start export");
    //addedd ProgressHud
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    AVAsset *sourceAsset;
    AVAsset *firstAsset;
    AVAsset *secondAsset;
    AVAsset *thirdAsset = [AVAsset assetWithURL:self.recordedVideoURL];
    
    MBProgressHUD*hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Processing...";
    
    AVMutableComposition* mixComposition;
    AVMutableVideoComposition* mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.frameDuration   = CMTimeMake(1, 30);
//    mainComposition.renderSize      = CGSizeMake(568, 360);
    mainComposition.renderSize      = thirdAsset.naturalSize;
    
    NSLog(@"size of main video = %@", NSStringFromCGSize(thirdAsset.naturalSize));
    NSLog(@"size of main video = %@", NSStringFromCGSize(screenFrame.size));
    
    
    if (videoOneURL!= nil && videoTwoURL!=nil) {
        
        //First Video
        //firstAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample1" ofType:@"m4v"]] options:nil];
//        NSLog(@"First Asset = %@",firstAsset);
        
        firstAsset = [AVAsset assetWithURL:videoOneURL];
        
        //second Video
        //secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"m4v"]] options:nil];
//        NSLog(@"second Asset = %@",secondAsset);
        secondAsset = [AVAsset assetWithURL:videoTwoURL];
    }
    
    CGSize temp ;
    CGSize size ;
    CGAffineTransform transform ;
    
    if (_sequenceList && self.recordedVideoURL)
    {
        //Create AVMutableComposition object
        
        mixComposition      = [AVMutableComposition composition];
        
        // create first track
        
        //Main Instruction Layer
        //crete Object of main Instruction layer and set timerange to it
        
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        NSMutableArray *arrInstructions=[[NSMutableArray alloc] init ];
        float seconds=5;
        CMTime atTime=CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + seconds,firstAsset.duration.timescale);
        
        float secondsTotal=seconds;
        float secondPassed=0;
        CMTime start=kCMTimeZero;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0,
                                       0,
                                       mainComposition.renderSize.width,
                                       mainComposition.renderSize.height);
        videoLayer.frame = CGRectMake(0,
                                      0,
                                      mainComposition.renderSize.width,
                                      mainComposition.renderSize.height);
        [parentLayer addSublayer:videoLayer];
        
        parentLayer.backgroundColor = [UIColor redColor].CGColor;
        videoLayer.backgroundColor  = [UIColor yellowColor].CGColor;
        
        int i=0;
//        for (int k=0;k<3;k++) {
        int imageNumber = 0;
        for (VTime *timeRange in self.arrRanges) {
            
            NSNumber *currentVideoIndex = [_sequenceList objectAtIndex:i];
            
            ALAsset *assest2=[App_Delegate.assets objectAtIndex:currentVideoIndex.integerValue];
            
            MediaButton *mButton = [_videoBtnList objectAtIndex:currentVideoIndex.intValue];
            
            if (mButton.mediaButtonType == MediaButtonTypeVideo) {
                
                CMTime sTime = timeRange.startTime;
                CMTime eTime = timeRange.endTime;
                ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
                NSURL *url = [representation2 url];
                
                sourceAsset = [AVAsset assetWithURL:url];
                
                seconds = CMTimeGetSeconds(eTime) - CMTimeGetSeconds(sTime);
                
                atTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + secondPassed,sourceAsset.duration.timescale);
                
//                NSLog(@"--------- added at time = %lld", atTime.value);
                
                secondPassed = secondPassed + seconds;
                
                NSLog(@"seconds passed = %f", secondPassed);
                
                AVMutableCompositionTrack *firstTrack =
                [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                            preferredTrackID:kCMPersistentTrackID_Invalid];
                
                AVMutableCompositionTrack *firstTrackAudio =
                [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                            preferredTrackID:kCMPersistentTrackID_Invalid];
                
                CMTimeRange firstRange = CMTimeRangeFromTimeToTime(sTime, eTime);
                
                [firstTrack insertTimeRange:firstRange
                                    ofTrack:[[sourceAsset tracksWithMediaType:AVMediaTypeVideo]
                                             objectAtIndex:0]
                                     atTime:atTime
                                      error:nil];
                
                [firstTrackAudio insertTimeRange:firstRange
                                         ofTrack:[[sourceAsset tracksWithMediaType:AVMediaTypeAudio]
                                                  objectAtIndex:0]
                                          atTime:atTime
                                           error:nil];
                
                
                //Duraton For Final Video should be max Duration of both video
                //InstructionLayer for first Track
                
                AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
                
                CGAffineTransform scale  = CGAffineTransformMakeScale(FLOATING_VIDEO_SCALE_FACTOR,
                                                                      FLOATING_VIDEO_SCALE_FACTOR);
                
                CGAffineTransform rotate = CGAffineTransformMakeRotation(0 * M_PI/180.0);
                CGAffineTransform move   = CGAffineTransformMakeTranslation(10, 10);
                
                // Rotate video if it was made in different orientation
                if (assest2.defaultRepresentation.dimensions.width < assest2.defaultRepresentation.dimensions.height) {
                    
                    rotate = CGAffineTransformMakeRotation(90 * M_PI/180.0);
                    move   = CGAffineTransformMakeTranslation(10 + assest2.defaultRepresentation.dimensions.width * FLOATING_VIDEO_SCALE_FACTOR, 10);
                }
                
                CGAffineTransform mix = CGAffineTransformConcat(scale, rotate);
                mix = CGAffineTransformConcat(mix, move);
                
                [firstlayerInstruction setTransform:mix atTime:atTime];
                
                start=CMTimeAdd(sTime, firstRange.duration);
                CMTime at2=CMTimeAdd(atTime, firstRange.duration);
                
                CGAffineTransform new2 = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0,0));
                
                NSLog(@"%lld ------", at2.value);
                
                [firstlayerInstruction setTransform:new2 atTime:at2];
                
                [arrInstructions addObject:firstlayerInstruction];
                secondsTotal=secondsTotal+seconds;
            }
            else if(mButton.mediaButtonType == MediaButtonTypeImage){
             
                imageNumber ++;
                
                seconds = IMAGE_TIME;
                
                atTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + secondPassed,600);
                
                secondPassed = secondPassed + seconds;
                secondsTotal=secondsTotal+seconds;
                
                
//                NSLog(@"seconds pass for image = %f", secondPassed);
                
                
                /*water mark*/
                
                CALayer *watermarkLayer = [CALayer layer];
                
                
                NSLog(@"image frames = %@", NSStringFromCGRect(watermarkLayer.frame));
                
                
//                watermarkLayer.frame  = CGRectMake(5, 0, 320, 480);
//                watermarkLayer.bounds = CGRectMake(5, 0, 320, 480);
                
                watermarkLayer.frame = CGRectMake(0, 0, mButton.imageView.image.size.width, mButton.imageView.image.size.height);
               
                
//                if (i % 2 == 0) {
//                    
//                    watermarkLayer.contents = (id) [UIImage imageNamed:@"Cartoon-hd-blooms-wallpapers.jpg"].CGImage;
//                }
//                else{
//                    
//                     watermarkLayer.contents = (id) [UIImage imageNamed:@"1407887392_542709.jpg"].CGImage;
//                }
                
                watermarkLayer.contents = (id) mButton.imageView.image.CGImage;
                watermarkLayer.opacity  = 0.0;
                watermarkLayer.backgroundColor = [UIColor clearColor].CGColor;
                
//                watermarkLayer.position =
//                CGPointMake(10,
//                            mainComposition.renderSize.height);
                
                
                
                
                
                /**/
                
//                CGAffineTransform scale  = CGAffineTransformMakeScale(FLOATING_VIDEO_SCALE_FACTOR,
//                                                                      FLOATING_VIDEO_SCALE_FACTOR);
                
                CATransform3D scale = CATransform3DMakeScale(1, 1, 1);
//                CGAffineTransform rotate = CGAffineTransformMakeRotation(0 * M_PI/180.0);
                CATransform3D rotate   = CATransform3DMakeRotation(0 * M_PI / 180.0, 0, 0, 1);
//                CGAffineTransform move   = CGAffineTransformMakeTranslation(10, 10);
                
                NSLog(@"%@------------ %@", NSStringFromCGRect(screenFrame), NSStringFromCGSize(mButton.imageView.image.size));
                
                CATransform3D move = CATransform3DMakeTranslation(10, mainComposition.renderSize.height - mButton.imageView.image.size.height - 10, 0);
                
                if (mButton.imageView.image.size.width < mButton.imageView.image.size.height) {
                    
//                    rotate = CGAffineTransformMakeRotation(90 * M_PI/180.0);
                    
                    rotate = CATransform3DMakeRotation(90 * M_PI / 180.0, 0, 0, 1);
//                    move   = CGAffineTransformMakeTranslation(10 + assest2.defaultRepresentation.dimensions.width * FLOATING_VIDEO_SCALE_FACTOR, 10);
                    
                    move = CATransform3DMakeTranslation(10 + mButton.imageView.image.size.width * FLOATING_VIDEO_SCALE_FACTOR, 10, 0);
                }
                
                CATransform3D mix = CATransform3DConcat(scale, rotate);
                mix = CATransform3DConcat(mix, move);
                
                watermarkLayer.transform = mix;
                
                /**/
                
                [parentLayer addSublayer:watermarkLayer];
                
                
                CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                
                fadeAnimation.fromValue = [NSNumber numberWithFloat:(float)0.0];
                fadeAnimation.toValue   = [NSNumber numberWithFloat:(float)1];
                fadeAnimation.additive  = NO;
                fadeAnimation.beginTime = secondPassed - seconds;
                fadeAnimation.duration  = IMAGE_TIME;
                fadeAnimation.fillMode  = kCAFillModeBoth;
                fadeAnimation.removedOnCompletion = YES;
                [watermarkLayer addAnimation:fadeAnimation forKey:nil];
                
                mainComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                 inLayer:parentLayer];
                
                /**/
            }
            
            i ++;
        }
        
        //  finalDuration = CMTimeAdd(firstRange.duration, secondRange.duration);
        CMTimeRange rangeFinal=CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(CMTimeGetSeconds(kCMTimeZero) + secondsTotal,sourceAsset.duration.timescale));
        
        mainInstruction.timeRange =rangeFinal;
        
        ///
        //        LEFT SIDE VIDEOS
        //InstructionLayer for second Track
 
        AVMutableCompositionTrack *thirdTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        AVMutableCompositionTrack *thirdTrackAudio = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        
        NSLog(@"Audio check = %f", thirdTrackAudio.preferredVolume);
        
        CMTime thirdTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(rangeFinal.duration) ,secondAsset.duration.timescale);
        CMTimeRange thirdRange = CMTimeRangeMake(kCMTimeZero, thirdTime);
        
        [thirdTrack insertTimeRange:thirdRange
                            ofTrack:[[thirdAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        [thirdTrackAudio insertTimeRange:thirdRange
                            ofTrack:[[thirdAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        
        ////// Background Audio Mixing ///////
        NSURL *audio_url = nil;
//        audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"song" ofType:@"mp3"]];
        
        if (App_Delegate.audio && [App_Delegate.audio isKindOfClass:[MPMediaItem class]]) {
            
            audio_url = [App_Delegate.audio valueForProperty:MPMediaItemPropertyAssetURL];
            AVURLAsset  *audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
            
            //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
            AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [b_compositionAudioTrack insertTimeRange:thirdRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
        /////////////
        
        
        AVMutableVideoCompositionLayerInstruction *thirdlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:thirdTrack];
        
//        AVMutableVideoCompositionLayerInstruction *thirdlayerInstructionBackground = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:thirdTrackBackgoundAudio];
        
        CGAffineTransform thirdScale = CGAffineTransformMakeScale(MAIN_VIDEO_SCALE_FACTOR,
                                                                  MAIN_VIDEO_SCALE_FACTOR);
        
        // for iPhone 5
        CGAffineTransform thirdMove = CGAffineTransformMakeTranslation(500,0);
        CGAffineTransform forth     = CGAffineTransformMakeRotation(90 * M_PI / 180.0);
        
        //[secondlayerInstruction setOpacity:0.5 atTime:kCMTimeZero];
        temp = CGSizeApplyAffineTransform(thirdTrack.naturalSize, thirdTrack.preferredTransform);

        size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
        transform = thirdTrack.preferredTransform;
        
        CGAffineTransform new1 = CGAffineTransformConcat(thirdScale,forth);
        CGAffineTransform new2 = CGAffineTransformConcat(new1,thirdMove);
        
        [thirdlayerInstruction setTransform:new2 atTime:kCMTimeZero];
        
        [arrInstructions addObject:thirdlayerInstruction];
//        [arrInstructions addObject:thirdlayerInstructionBackground];
        
        
        //Now adding FirstInstructionLayer and SecondInstructionLayer to mainInstruction
        mainInstruction.layerInstructions = [NSArray arrayWithArray:arrInstructions];
        
        
        // attach Main Instrcution To VideoCopositionn
        //we can attch multipe Instrction to it
        
//        mainComposition = [AVMutableVideoComposition videoComposition];
        mainComposition.instructions = [NSArray arrayWithObjects:mainInstruction,nil];
        
        //  Get path        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergeVideo.mov"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:myPathDocs error:NULL];
        NSURL*  mainURL = [NSURL fileURLWithPath:myPathDocs];
//        NSLog(@"URL:-  %@", [mainURL description]);
        
        //create Exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = mainURL;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainComposition;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self exportDidFinish:exporter];
//                [self mergeAndSave];
                
                NSLog(@"end export");
            });
        }];
    }
    else {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Video Not Selected.PLease select videos to merege"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)mergeAndSave
{
    //Create AVMutableComposition Object which will hold our multiple AVMutableCompositionTrack or we can say it will hold our video and audio files.
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Now first load your audio file using AVURLAsset. Make sure you give the correct path of your videos.
    NSURL *audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"song" ofType:@"mp3"]];
    AVURLAsset  *audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Now we will load video file.
    
//    ALAsset *assest2=[App_Delegate.assets objectAtIndex:0];
//    ALAssetRepresentation *representation2 = [assest2 defaultRepresentation];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo.mov"]];
    
    ALAsset *asset = [App_Delegate.assets objectAtIndex:0];
    
    NSURL *video_url = asset.defaultRepresentation.url;
    
//    NSURL *video_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Video" ofType:@"m4v"]];
    AVURLAsset  *videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //decide the path where you want to store the final video created with audio and video merge.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo.mov"]];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]){
//        
//        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
//    }
    
    //Now create an AVAssetExportSession object that will save your final video at specified path.
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [self exportDidFinish:_assetExport];
         });
     }
     ];
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
//                             [NSString stringWithFormat:@"mergeVideo.mov"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:myPathDocs error:NULL];
    NSURL*  mainURL = [NSURL fileURLWithPath:myPathDocs];
    //        NSLog(@"URL:-  %@", [mainURL description]);
    
    //create Exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = mainURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
//    exporter.videoComposition = mainComposition;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self exportDidFinish:exporter];
            NSLog(@"end export");
        });
    }];
}

//here you have the outputURL of the final overlapped vide0. add your desired task here.
- (void)exportDidFinish:(AVAssetExportSession*)session
{
    
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"export did finish...");
    NSLog(@"%li", (long)session.status);
    NSLog(@"%@", session.error);
    NSURL *vedioURL = session.outputURL.filePathURL;
    NSLog(@"vurl %@",vedioURL);
    
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:.3f];
    
    MPMoviePlayerViewController *videoPlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:vedioURL];
    
    [self presentMoviePlayerViewControllerAnimated:videoPlayerView];
    
    
    [videoPlayerView.moviePlayer play];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Media Picker
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
        
        [self doExport];
    }];
    
}

#pragma mark- Orientation Fixing
//- (void)orientationDidChangedFromOrientation:(UIInterfaceOrientation)oldOrientation toOrientation:(UIInterfaceOrientation)currentOrientation{
//    
//    CGRect screenRect = [UIScreen mainScreen].bounds;
//    CGRect frame = self.overlaye.frame;
//    
//    if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
//        
//        NSLog(@"Seedha");
//        frame.origin.x = screenRect.size.width - frame.size.width;
//    }
//    else{
//        
//        NSLog(@"teda");
//        frame.origin.x = screenRect.size.height - frame.size.width;
//    }
//    
//    self.overlaye.frame = frame;
//}

#pragma mark-
- (void)initCapture {
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:NULL];
    
    _capturedVideo = [[AVCaptureVideoDataOutput alloc] init];
    [_capturedVideo setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    _capturedFile = [[AVCaptureMovieFileOutput alloc] init];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    
    [_capturedVideo setVideoSettings:videoSettings];
    
    _captureSession = [[AVCaptureSession alloc] init];
    
    [_captureSession addInput:captureInput];
    [_captureSession addOutput:_capturedFile];
    [_captureSession addOutput:_capturedVideo];
    
    [_captureSession beginConfiguration];
    [_captureSession setSessionPreset:AVCaptureSessionPresetLow];
    [_captureSession commitConfiguration];
    
    [self performSelector:@selector(startRecording) withObject:nil afterDelay:10.0];
    [self performSelector:@selector(stopRecording) withObject:nil afterDelay:15.0];
    
    [_captureSession startRunning];
}


- (void) startRecording
{
    [_capturedFile startRecordingToOutputFileURL:[self tempFileURL] recordingDelegate:self];
    
}

- (void) stopRecording
{
    if([_capturedFile isRecording])
        [_capturedFile stopRecording];
    
}


- (NSURL *) tempFileURL
{
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"camera.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath])
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
        return outputURL;
}
    
    
    
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"start record video");
}
    
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"end record");
}
    
    
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // do stuff with sampleBuffer
}
@end

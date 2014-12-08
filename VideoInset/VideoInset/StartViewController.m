//
//  StartViewController.m
//  VideoInset
//
//  Created by Sumit Gupta on 8/20/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import "StartViewController.h"
@implementation StartViewController

@synthesize cameraPicker;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController) {
        
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnPickVideosPressed:(id)sender
{
    
    AppDelegate *appDel=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
//    picker.assetsFilter         = [ALAssetsFilter allVideos];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.selectedAssets       = [NSMutableArray arrayWithArray:appDel.assets];
    picker.title = @"Pick Videos";
    picker.showsNumberOfAssets = NO;
    [self presentViewController:picker animated:YES completion:nil];
    
}


#pragma CTAssetsPickerController Delegates
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assetsSelected
{
    AppDelegate *appDel=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDel.assets = [NSMutableArray arrayWithArray:assetsSelected];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"toMainView" sender:self];
        //[self showCamera];
    }];
}


-(void)showCamera
{
    
    //    self.overLayview.frame=CGRectMake(300, 300, self.view.frame.size.width, self.view.frame.size.height)q;
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
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MainViewController *controller = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MainViewController"];
    
    self.cameraPicker.cameraOverlayView = controller.view;
    self.cameraPicker.delegate          = controller;
    controller.cameraPicker             = self.cameraPicker;

    //    [self presentModalViewController:self.cameraPicker animated:NO];
//    [self presentViewController:self.cameraPicker animated:YES completion:^{
//        [self.cameraPicker startVideoCapture];
//    }];
    
    [self.navigationController presentViewController:self.cameraPicker animated:YES completion:^{
          [self.cameraPicker startVideoCapture];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

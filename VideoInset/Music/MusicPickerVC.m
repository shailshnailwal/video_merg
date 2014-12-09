//
//  MusicPickerVC.m
//  VideoInset
//
//  Created by Enuke New Mac on 09/12/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import "MusicPickerVC.h"

@interface MusicPickerVC ()

@end

@implementation MusicPickerVC

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
    _musicPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    _musicPicker.delegate = self;
    _musicPicker.allowsPickingMultipleItems = NO;
    [self presentViewController:_musicPicker animated:NO completion:nil];
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    MPMediaItem *item = [mediaItemCollection representativeItem];
    App_Delegate.audio = item;
//    player=[[AVAudioPlayer alloc]initWithContentsOfURL:[item     valueForProperty:MPMediaItemPropertyAssetURL] error:nil];
//    [player play];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

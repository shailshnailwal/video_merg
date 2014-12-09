//
//  MusicPickerVC.h
//  VideoInset
//
//  Created by Enuke New Mac on 09/12/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPickerVC : UIViewController<MPMediaPickerControllerDelegate>{
    
    MPMediaPickerController *_musicPicker;
}

@end

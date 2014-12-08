//
//  MediaButton.h
//  VideoInset
//
//  Created by Enuke New Mac on 05/12/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    
    MediaButtonTypeImage = 1,
    MediaButtonTypeVideo
} MediaButtonType;

@interface MediaButton : UIButton{
    
    MediaButtonType _mediaButtonType;
}

@property(nonatomic, assign) MediaButtonType mediaButtonType;
@end

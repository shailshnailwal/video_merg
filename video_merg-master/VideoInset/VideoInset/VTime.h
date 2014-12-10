//
//  VTime.h
//  VideoInset
//
//  Created by Sumit Gupta on 8/13/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CTAssetsPageViewController.h"


@interface VTime : NSObject
{
    CMTime endTime;
    CMTime startTime;
}
@property(assign)     CMTime endTime;
@property(assign)     CMTime startTime;
@end

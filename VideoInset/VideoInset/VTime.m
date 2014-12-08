//
//  VTime.m
//  VideoInset
//
//  Created by Sumit Gupta on 8/13/14.
//  Copyright (c) 2014 Sumit Gupta. All rights reserved.
//

#import "VTime.h"

@implementation VTime

@synthesize endTime;
@synthesize startTime;

- (NSString *)description{
    
    NSString *description = [NSString stringWithFormat:@"%f to %f", startTime.value, endTime.value];
    
    return description;
}
@end

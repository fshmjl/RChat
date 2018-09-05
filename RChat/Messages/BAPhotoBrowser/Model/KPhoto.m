//
//  KPhoto.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KPhoto.h"

@implementation KPhoto

- (BOOL)isEmpty {
    if (self.videoUrl == nil && self.defaultImage == nil && self.imageUrl == nil && self.thumbUrl == nil) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isVideo {
    if (self.videoUrl != nil) {
        return YES;
    }
    return NO;
}

@end

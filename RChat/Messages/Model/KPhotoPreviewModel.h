//
//  KPhotoPreviewModel.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/14.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPhotoPreviewModel : NSObject

//@property (nonatomic, strong) NSData      *imageData;

@property (nonatomic, strong) id          content;

@property (nonatomic, strong) NSString    *videoUrl;

@property (nonatomic, strong) NSString    *thumbUrl;

@property (nonatomic, strong) NSString    *imageUrl;

@property (nonatomic, strong) NSString    *messageId;

@property (nonatomic, strong) UIImageView *tapImageView;

@end

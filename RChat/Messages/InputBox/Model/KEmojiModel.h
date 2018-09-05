//
//  KEmojiModel.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/28.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KEmojiModel : NSObject
// 表情id
@property (nonatomic, strong) NSString *emojiID;
// 表情名
@property (nonatomic, strong) NSString *emojiName;

@property (nonatomic, strong) NSString *name;

//@property (nonatomic, strong, readonly) UIImage *image;

@end



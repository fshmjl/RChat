//
//  KEmojiGroup.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/28.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface KEmojiGroup : NSObject
// 表情类型
@property (nonatomic, assign) KEmojiType emojiType;
// 表情组id
@property (nonatomic, copy) NSString    *groupID;
// 表情组名
@property (nonatomic, copy) NSString    *groupName;

@end

@class KEmojiModel;
@interface KEmojiGroupManager : NSObject

@property (nonatomic, strong) NSArray *emojiGroup;

@property (nonatomic, strong) NSMutableArray<KEmojiModel *> *currentEmojiList;

@property (nonatomic, strong) KEmojiGroup *currentGroup;

+ (instancetype)shareManager;


@end

//
//  KEmojiGroup.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/28.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KEmojiGroup.h"

#import "KEmojiModel.h"

static KEmojiGroupManager *manager = nil;

@implementation KEmojiGroup

//- (void)setGroupID:(NSString *)groupID {
//    self.emojiArray = [[NSUserDefaults standardUserDefaults] objectForKey:groupID];
//    if (!self.emojiArray) {
//        NSArray *array = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:groupID ofType:@"plist"]];
//        [[NSUserDefaults standardUserDefaults] setObject:array forKey:groupID];
//    }
//}


@end

@implementation KEmojiGroupManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [KEmojiGroupManager shareManager];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        kWeakSelf;
        NSLock *lock = [NSLock new];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            [weakSelf emojiGroup];
            weakSelf.currentEmojiList = [NSMutableArray array];
            NSArray *emojiList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:weakSelf.currentGroup.groupID ofType:@"plist"]];
            for (NSDictionary *dic in emojiList) {
                [lock lock];
                KEmojiModel *model = [KEmojiModel new];
                model.emojiName    = dic[@"face_name"];
                model.name         = dic[@"name"];
                model.emojiID      = dic[@"facd_id"];
                [weakSelf.currentEmojiList addObject:model];
                [lock unlock];
            }
        });
    }
    return self;
}
// 表情的组数
- (NSArray *)emojiGroup {
    
    if (!_emojiGroup) {
        KEmojiGroup *group = [KEmojiGroup new];
        group.emojiType    = KEmojiTypeNomarl;
        group.groupID      = @"normal_emoji";
        group.groupName    = @"emoji_normal";
        _emojiGroup        = [NSArray arrayWithObjects:group, nil];
    }
    return _emojiGroup;
}

- (KEmojiGroup *)currentGroup {
    if (!_currentGroup) {
        _currentGroup = [self.emojiGroup firstObject];
    }
    return _currentGroup;
}


@end

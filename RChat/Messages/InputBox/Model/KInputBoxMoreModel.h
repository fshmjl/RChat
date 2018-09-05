//
//  KInputBoxMoreModel.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/9.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KInputBoxMoreModel : NSObject

@property (nonatomic, strong) NSString *extendId;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *imageName;

@end

@interface KInputBoxMoreManager : NSObject

@property (nonatomic, strong) NSMutableArray *moreItemModels;

@end

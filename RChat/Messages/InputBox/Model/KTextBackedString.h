//
//  KTextBackedString.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const KTextBackedStringAttributeName;

@interface KTextBackedString : NSObject <NSCoding, NSCopying>
@property (nullable, nonatomic, copy) NSString *string;

+ (nullable instancetype)stringWithString:(nullable NSString *)string;

@end

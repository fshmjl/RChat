//
//  KTextBackedString.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KTextBackedString.h"


NSString *const KTextBackedStringAttributeName = @"PPTextBackedString";

@implementation KTextBackedString

+ (instancetype)stringWithString:(NSString *)string
{
    KTextBackedString *one = [[self alloc] init];
    one.string = string;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _string = [aDecoder decodeObjectForKey:@"string"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) one = [[self.class alloc] init];
    one.string = self.string;
    return one;
}



@end

//
//  UIView+KExtension.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/2.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "UIView+KExtension.h"

@implementation UIView (KExtension)
// 给view的最大的x赋值，并重新定义view的位置
- (void)setKMax_x:(CGFloat)kMax_x {
    self.frame = CGRectMake(kMax_x - self.mj_w, self.mj_y, self.mj_w, self.mj_h);
}

- (CGFloat)kMax_x {
    return self.mj_w + self.mj_x;
}
// 给view的最大的y赋值，并重新定义view的位置
- (void)setKMax_y:(CGFloat)kMax_y {
    self.frame = CGRectMake(self.mj_x, kMax_y - self.mj_h, self.mj_w, self.mj_h);
}

- (CGFloat)kMax_y {
    return self.mj_y + self.mj_h;
}

@end

//
//  UIScrollView+Addition.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "UIScrollView+Addition.h"

@implementation UIScrollView (Addition)

- (CGPoint)maximumContentOffset {
    CGRect bounds             = self.bounds;
    CGSize contentSize        = self.contentSize;
    UIEdgeInsets contentInset = self.contentInset;
    
    CGFloat x = MAX(-contentInset.left, contentSize.width + contentInset.right - bounds.size.width);
    CGFloat y = MAX(-contentInset.top, contentSize.height + contentInset.bottom - bounds.size.height);
    
    return CGPointMake(x, y);
}


@end

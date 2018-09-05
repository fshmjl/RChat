//
//  NSString+Size.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

- (CGSize)kSizeWithFont:(UIFont *)font;
- (CGSize)kSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;


@end

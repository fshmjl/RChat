//
//  NSString+Size.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGSize)kSizeWithFont:(UIFont *)font
{
    return [self kSizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 1) lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)kSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    if (font) {
        attributes[NSFontAttributeName] = font;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}



@end

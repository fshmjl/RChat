//
//  NSAttributedString+Addition.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KTextBackedString;

@interface NSAttributedString (Addition)

- (NSRange)rangeOfAll;

- (nullable NSString *)plainTextForRange:(NSRange)range;

@end

@interface NSMutableAttributedString (Addition)

- (void)setTextBackedString:(nullable KTextBackedString *)textBackedString range:(NSRange)range;

@end

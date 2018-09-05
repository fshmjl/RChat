//
//  KEmojiCollectionViewCell.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/10.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KEmojiCollectionViewCell.h"



@implementation KEmojiCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self imageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self imageView];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        self.backgroundColor = [ColorTools colorWithHexString:@"0xeeeeee"];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.mj_w - ITEM_WIDTH + 10)/2., (self.mj_w - ITEM_HEIGHT + 10)/2., ITEM_WIDTH -10 , ITEM_HEIGHT - 10)];
        _imageView.backgroundColor = self.backgroundColor;
        [self addSubview:_imageView];
    }
    return _imageView;
}


@end

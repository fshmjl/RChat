//
//  KInputBoxMoreUnitView.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/10.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxMoreUnitView.h"


#import "KInputBoxMoreModel.h"

@implementation KInputBoxMoreUnitView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.box = [[UIView alloc] initWithFrame:CGRectMake(5, 10, self.mj_w - 10, self.mj_w - 10)];
    self.box.layer.cornerRadius  = 5;
    self.box.layer.masksToBounds = YES;
    self.box.layer.borderColor   = [UIColor lightTextColor].CGColor;
    self.box.layer.borderWidth   = 1;
    self.box.backgroundColor     = [UIColor whiteColor];
    [self addSubview:self.box];
    
    CGFloat width  = self.box.mj_w - 22;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.box.mj_w - width) / 2, (self.box.mj_h - width) / 2, width, width)];
    [self.box addSubview:self.imageView];
    self.imageView.userInteractionEnabled = YES;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.box.kMax_y + 5, INPUT_BOX_MORE_ITEM_WIDTH, 20)];
    self.titleLabel.textColor     = [UIColor lightGrayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font          = [UIFont systemFontOfSize:14];
    [self addSubview:self.titleLabel];

}

- (void)setMoreModel:(KInputBoxMoreModel *)moreModel
{
    _moreModel = moreModel;
    if (moreModel.imageName) {
        self.imageView.image = [UIImage imageNamed:moreModel.imageName];
    }
    self.titleLabel.text     = moreModel.name;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end

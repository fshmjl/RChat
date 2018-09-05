//
//  KRecordView.m
//  RecordTest
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 eims-1. All rights reserved.
//

#import "KRecordView.h"

@implementation KRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.titleLabel.textColor = [UIColor darkGrayColor];
        self.titleLabel.userInteractionEnabled = YES;
        self.titleLabel.text = @"按住 说话";
        [self.titleLabel sizeToFit];
        [self addSubview:self.titleLabel];
        self.titleLabel.frame = CGRectMake((self.mj_w - self.titleLabel.size.width)/2, (self.mj_h - self.titleLabel.size.height)/2, self.titleLabel.size.width, self.titleLabel.size.height);
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

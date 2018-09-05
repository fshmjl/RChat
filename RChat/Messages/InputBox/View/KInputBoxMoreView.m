//
//  KInputBoxMoreView.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/7.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxMoreView.h"

#import "KInputBoxMoreItemView.h"
#import "KInputBoxMoreModel.h"
#import "KInputBoxMoreUnitView.h"

@interface KInputBoxMoreView()
// 页数
@property (nonatomic, assign) NSInteger pageNumber;
// moreItemView数组
@property (nonatomic, strong) NSMutableArray *moreItemViews;

@end

@implementation KInputBoxMoreView

- (NSMutableArray *)moreItemViews
{
    if (!_moreItemViews) {
        _moreItemViews = [NSMutableArray arrayWithCapacity:1];
        
        for (int i = 0; i < 2; i ++) {
            KInputBoxMoreItemView *moreItemView = [[KInputBoxMoreItemView alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, INPUT_BOX_MORE_VIEW_HEIGHT)];
            [_moreItemViews addObject:moreItemView];
        }
    }
    
    return _moreItemViews;
}

- (NSInteger)pageNumber
{
    if (!_pageNumber)
    {
        KInputBoxMoreManager *inputBoxMoreManager = [[KInputBoxMoreManager alloc] init];
        NSInteger page = inputBoxMoreManager.moreItemModels.count / 8;
        NSInteger remainder = inputBoxMoreManager.moreItemModels.count % 8;
        _pageNumber = page + remainder;
    }
    
    return _pageNumber;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

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
    self.backgroundColor = [ColorTools colorWithHexString:@"0xeeeeee"];
    self.topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, 1)];
    self.topLine.backgroundColor = KLineColor;
    [self addSubview:self.topLine];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, INPUT_BOX_MORE_VIEW_HEIGHT)];
    self.scrollView.contentSize = CGSizeMake(MSWIDTH, 0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, 15)];
    self.pageCtrl.backgroundColor = [UIColor clearColor];
    self.pageCtrl.pageIndicatorTintColor = [ColorTools colorWithHexString:@"0xd8d8d8"];
    self.pageCtrl.currentPageIndicatorTintColor = [ColorTools colorWithHexString:@"0x8e8e8e"];
    self.pageCtrl.hidesForSinglePage = YES;
    [self addSubview:self.pageCtrl];
    
    KInputBoxMoreItemView *moreItemView = self.moreItemViews.firstObject;
    [self.scrollView addSubview:moreItemView];
    
}

@end

//
//  KHorizontalPageFlowlayout.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/10.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KHorizontalPageFlowlayout.h"



@implementation KHorizontalPageFlowlayout

#pragma mark - Public
- (void)setColumnSpacing:(CGFloat)columnSpacing rowSpacing:(CGFloat)rowSpacing edgeInsets:(UIEdgeInsets)edgeInsets
{
    self.columnSpacing = columnSpacing;
    self.rowSpacing    = rowSpacing;
    self.edgeInsets    = edgeInsets;
}

- (void)setRowCount:(NSInteger)rowCount itemCountPerRow:(NSInteger)itemCountPerRow
{
    self.rowCount        = rowCount;
    self.itemCountPerRow = itemCountPerRow;
}

#pragma mark - 构造方法
+ (instancetype)KHorizontalPageFlowlayoutWithRowCount:(NSInteger)rowCount itemCountPerRow:(NSInteger)itemCountPerRow
{
    return [[self alloc] initWithRowCount:rowCount itemCountPerRow:itemCountPerRow];
}

- (instancetype)initWithRowCount:(NSInteger)rowCount itemCountPerRow:(NSInteger)itemCountPerRow
{
    self = [super init];
    if (self) {
        self.rowCount        = rowCount;
        self.itemCountPerRow = itemCountPerRow;
    }
    return self;
}


#pragma mark - 重写父类方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setColumnSpacing:0 rowSpacing:0 edgeInsets:UIEdgeInsetsZero];
    }
    return self;
}

/** 布局前做一些准备工作 */
- (void)prepareLayout
{
    [super prepareLayout];
    
    // 从collectionView中获取到有多少个item
    NSInteger itemTotalCount = [self.collectionView numberOfItemsInSection:0];
    
    // 遍历出item的attributes,把它添加到管理它的属性数组中去
    for (int i = 0; i < itemTotalCount; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexpath];
        [self.attributesArrayM addObject:attributes];
    }
}

- (void)invalidateLayout {
    [super invalidateLayout];
    [self.attributesArrayM removeAllObjects];
}

/** 计算collectionView的滚动范围 */
- (CGSize)collectionViewContentSize
{
    // 只支持水平方向上的滚动
    return CGSizeMake(self.pageNumber * MSWIDTH, 0);
}

/** 设置每个item的属性(主要是frame) */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger item = indexPath.item;
    CGFloat count = NORMARL_EMOJI_ROW_COUNT;
    CGFloat columnSpace = (MSWIDTH - (count * ITEM_WIDTH))/(count + 1);
    // 当前item所在的页
    NSInteger pageNumber = item / (self.rowCount * self.itemCountPerRow);
    NSInteger x = item % self.itemCountPerRow + pageNumber * self.itemCountPerRow;
    NSInteger y = item / self.itemCountPerRow - pageNumber * self.rowCount;
    
    // 计算出item的坐标
    CGFloat itemX = self.edgeInsets.right + (self.itemSize.width + self.columnSpacing) * x + columnSpace * pageNumber;
    CGFloat itemY = self.edgeInsets.top + (self.itemSize.height + self.rowSpacing) * y;
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    // 每个item的frame
    attributes.frame = CGRectMake(itemX, itemY, self.itemSize.width, self.itemSize.height);
    
    return attributes;
}


/** 返回collectionView视图中所有视图的属性数组 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attributesArrayM;
}

#pragma mark - Lazy
- (NSMutableArray *)attributesArrayM
{
    if (!_attributesArrayM) {
        _attributesArrayM = [NSMutableArray array];
    }
    return _attributesArrayM;
}

- (NSInteger)pageNumber {
    if (!_pageNumber) {
        // 从collectionView中获取到有多少个item
        NSInteger itemTotalCount = [self.collectionView numberOfItemsInSection:0];
        
        // 理论上每页展示的item数目
        NSInteger itemCount  = self.rowCount * self.itemCountPerRow;
        // 余数（用于确定最后一页展示的item个数）
        NSInteger remainder  = itemTotalCount % itemCount;
        // 除数（用于判断页数）
        _pageNumber = itemTotalCount / itemCount;
        _pageNumber = remainder == 0 ? _pageNumber : _pageNumber + 1;
    }
    return _pageNumber;
}

@end

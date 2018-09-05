//
//  KInputBoxEmojiView.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/10.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxEmojiView.h"

#import "KEmojiModel.h"
#import "KEmojiGroup.h"
#import "KEmojiCollectionViewCell.h"
#import "KHorizontalPageFlowlayout.h"

static NSString *identifier = @"kCell";

@interface KInputBoxEmojiView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, KInputBoxViewDelegate>
{
    // 一行显示的表情数量
    NSInteger rowCount;
    // 一页多少行
    NSInteger section;
    // 一页显示的表情数量
    NSInteger pageEmoji;
}

// 总页数
@property (nonatomic, assign) NSInteger totalPage;
// 当前页
@property (nonatomic, assign) NSInteger currentPage;
//
@property (nonatomic, strong) UIPageControl *pageCtrl;

@property (nonatomic, strong) NSMutableArray *dataSource;
// 最后选择的表情组
@property (nonatomic, strong) KEmojiGroup *lastEmojiGroup;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) KHorizontalPageFlowlayout *flowLayout;

@property (nonatomic, strong) KEmojiGroupManager *emojiManager;

@end


@implementation KInputBoxEmojiView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}


- (void)initView {
    
    self.backgroundColor = [ColorTools colorWithHexString:@"0xeeeeee"];
    self.dataSource = [NSMutableArray array];
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageCtrl];
    [self addSubview:self.menuView];

    _emojiManager = [KEmojiGroupManager shareManager];
    self.lastEmojiGroup = _emojiManager.currentGroup;
    [self updateDataSource:_emojiManager.currentGroup];
}


/**
 更新选择的表情组

 @param emojiGroup 最新选择的表情组
 */
- (void)updateDataSource:(KEmojiGroup *)emojiGroup {
    
    if ([self.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        if (@available(iOS 10.0, *)) {
            self.collectionView.prefetchingEnabled = YES;
        } else {
            // Fallback on earlier versions
        }
    }
    
//    [[NSUserDefaults standardUserDefaults] setObject:emojiGroup forKey:@"lastEmojiGroup"];
    // 一行个数
    rowCount = emojiGroup.emojiType == KEmojiTypeNomarl ? NORMARL_EMOJI_ROW_COUNT : GIF_EMOJI_ROW_COUNT;
    // 多少行
    section = emojiGroup.emojiType == KEmojiTypeNomarl ? 3 : 2;
    // 一页显示多少表情
    pageEmoji = emojiGroup.emojiType == KEmojiTypeNomarl ? (rowCount * section - 1) : rowCount * section;
    
    NSArray *emojiArray = _emojiManager.currentEmojiList;
    
    NSMutableArray *newDataSource = [NSMutableArray arrayWithArray:emojiArray];
    
    KEmojiModel *delete = [KEmojiModel new];// @{@"face_id":@"1000",@"face_name":@"[删除]", @"name":@"emoji_delete"};
    delete.emojiID = @"1000";
    delete.emojiName = @"[删除]";
    delete.name = @"emoji_delete";
    
    KEmojiModel *empty = [KEmojiModel new];
    empty.emojiID = @"0001";
    empty.emojiName = @"";
//    empty.name = @"";
    
//    NSDictionary *empty = @{@"face_id":@"",@"face_name":@""};
    // 余数
    NSInteger remainder = newDataSource.count % pageEmoji;
    // 余数不等于0就加一
    NSInteger addPage = remainder == 0 ? 0 : 1;
    NSInteger pageNum = newDataSource.count / pageEmoji + addPage;
    NSInteger index = pageEmoji + 1;
    
    for (int i = 1; i <= pageNum; i ++) {
        if ((i * index) > newDataSource.count) {
            int count = (int)newDataSource.count;
            for (int j = count; j <= i*index - 1; j ++) {
                if (j == i*index - 1) {
                    [newDataSource insertObject:delete atIndex:newDataSource.count];
                    break;
                }
                else {
                    [newDataSource insertObject:empty atIndex:j];
                }
            }
        }
        else {
            [newDataSource insertObject:delete atIndex:i*index - 1];
        }
    }
    
    self.pageCtrl.numberOfPages = pageNum;
    self.pageCtrl.currentPage   = 0;
    
    NSInteger count = _emojiManager.emojiGroup.count;

    if (self.dataSource.count > 0 && count > 1) {
        // 切换到第一个
        if (self.dataSource.count < newDataSource.count) {
            // 已经存在，直接重用
            NSMutableArray *reusable = [NSMutableArray array];
            for (int i = 0; i < self.dataSource.count; i ++) {
                [self.dataSource replaceObjectAtIndex:i withObject:newDataSource[i]];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [reusable addObject:indexPath];
            }
            
            kWeakSelf;
            [self.collectionView performBatchUpdates:^{
                [weakSelf.collectionView reloadItemsAtIndexPaths:reusable];
            } completion:^(BOOL finished) {
            }];
            // 不存在新增
            NSMutableArray *newCreate = [NSMutableArray array];
            for (int i = (int)self.dataSource.count; i < newDataSource.count; i ++) {
                [self.dataSource addObject:newDataSource[i]];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [newCreate addObject:indexPath];
            }
            [self.collectionView performBatchUpdates:^{
                [weakSelf.collectionView insertItemsAtIndexPaths:newCreate];
            } completion:^(BOOL finished) {
            }];
            [self.collectionView reloadData];
        }
        else {
            // 删除多余的
            NSInteger count = self.dataSource.count;
            NSMutableArray *deleteArr = [NSMutableArray array];
            for (NSInteger i = newDataSource.count; i < count; i ++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [deleteArr addObject:indexPath];
            }
            
            [self.collectionView performBatchUpdates:^{
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newDataSource.count, count - newDataSource.count)];
                [self.dataSource removeObjectsAtIndexes:set];
                [self.collectionView deleteItemsAtIndexPaths:deleteArr];
                [self.flowLayout invalidateLayout];
            } completion:^(BOOL finished) {
            }];
            
            // 重用已经存在的
            NSMutableArray *reusable = [NSMutableArray array];
            for (int i = 0; i < newDataSource.count; i ++) {
                [self.dataSource replaceObjectAtIndex:i withObject:newDataSource[i]];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [reusable addObject:indexPath];
            }
            
            kWeakSelf;
            [self.collectionView performBatchUpdates:^{
                [weakSelf.collectionView reloadItemsAtIndexPaths:reusable];
            } completion:^(BOOL finished) {
            }];
            [self.collectionView reloadData];
        }
    }
    else {
        self.dataSource = newDataSource;
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewCell代理

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    collectionView.contentOffset = CGPointMake(0, 0);
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KEmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    KEmojiModel *emojiModel = self.dataSource[indexPath.row];
//    NSString *imageName = emojiDic[@"name"];
//    if (imageName != nil && ![imageName isEqualToString:@""]) {
//        CGSize size = CGSizeMake(ITEM_WIDTH -10, ITEM_HEIGHT - 10);
//        UIImage * resultImage = [UIImage imageNamed:emojiModel.name];
//        UIGraphicsBeginImageContext(size);
//        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
//        UIGraphicsEndImageContext();
//        cell.imageView.image = resultImage;
    cell.imageView.image = [UIImage imageNamed:emojiModel.name];
//    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {

}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    KEmojiCollectionViewCell *kcell = (KEmojiCollectionViewCell *)cell;
    KEmojiModel *emojiModel = self.dataSource[indexPath.row];
    kcell.imageView.image = [UIImage imageNamed:emojiModel.name];;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    KEmojiCollectionViewCell *kcell = (KEmojiCollectionViewCell *)cell;
    kcell.imageView.image = nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KEmojiModel *emojiModel = self.dataSource[indexPath.row];
    if ([emojiModel.emojiName isEqualToString:@"[删除]"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(emojiViewDeleteEmoji)]) {
            [self.delegate emojiViewDeleteEmoji];
        }
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(emojiView:didSelectEmoji:emojiType:)]) {
            self.menuView.sendButton.backgroundColor = KBlueColor;
            [self.menuView.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [self.delegate emojiView:self didSelectEmoji:emojiModel emojiType:self.lastEmojiGroup.emojiType];
        }
    }
}

// 选择表情组
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView didSelectEmojiGroup:(KEmojiGroup *)emojiGroup {
    [self updateDataSource:emojiGroup];
}

// 点击发送
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView sendEmoji:(UIButton *)sendBut {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiView:sendEmoji:)]) {
        [self.delegate emojiView:self sendEmoji:@""];
    }
}

// 点击添加表情
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView clickAddAction:(UIButton *)addBut {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiMenuView:clickAddAction:)]) {
        [self.delegate emojiMenuView:menuView clickAddAction:addBut];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger pageNum = (NSInteger)scrollView.contentOffset.x / (NSInteger)MSWIDTH;
    NSInteger remainder1 = (NSInteger)scrollView.contentOffset.x % (NSInteger)MSWIDTH;
    if (remainder1 > MSWIDTH/2) {
        pageNum = pageNum + 1;
    }
    if (self.currentPage != pageNum) {
        self.currentPage = pageNum;
        self.pageCtrl.currentPage = pageNum;
    }
}

#pragma mark - 懒加载

- (KHorizontalPageFlowlayout *)flowLayout {
    if (!_flowLayout) {
        CGFloat count = NORMARL_EMOJI_ROW_COUNT;
        CGFloat columnSpace = (MSWIDTH - (count * ITEM_WIDTH))/(count + 1);
        _flowLayout = [[KHorizontalPageFlowlayout alloc] initWithRowCount:3 itemCountPerRow:NORMARL_EMOJI_ROW_COUNT];
        [_flowLayout setColumnSpacing:columnSpace rowSpacing:krowSpacing edgeInsets:UIEdgeInsetsMake(5, columnSpace, 5, columnSpace)];
        _flowLayout.estimatedItemSize = CGSizeMake(ITEM_WIDTH, ITEM_WIDTH);
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, INPUT_BOX_EMOJI_HEIGHT) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [ColorTools colorWithHexString:@"0xeeeeee"];
        _collectionView.bounces = YES;
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 10.0, *)) {
            _collectionView.prefetchDataSource = self;
            _collectionView.prefetchingEnabled = YES;
        } else {
            
            // Fallback on earlier versions
        }
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[KEmojiCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }
    return _collectionView;
}


- (UIPageControl *)pageCtrl {
    if (!_pageCtrl) {
        _pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.collectionView.kMax_y, MSWIDTH, INPUT_BOX_EMOJI_VIEW_HEIGHT - MENU_EMOJI_ITEM_HEIGHT - INPUT_BOX_EMOJI_HEIGHT)];
        _pageCtrl.currentPage = 0;
        _pageCtrl.pageIndicatorTintColor = [ColorTools colorWithHexString:@"0xd8d8d8"];
        _pageCtrl.currentPageIndicatorTintColor = [ColorTools colorWithHexString:@"0x8e8e8e"];
        _pageCtrl.enabled = false;
//        [_pageCtrl addTarget:self action:@selector(pageCtrlNumberChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageCtrl;
}

- (KInputBoxEmojiMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[KInputBoxEmojiMenuView alloc] initWithFrame:CGRectMake(0, self.pageCtrl.kMax_y, MSWIDTH, MENU_EMOJI_ITEM_HEIGHT + kTabbarSafeBottomMargin)];
        _menuView.delegate = self;
    }
    return _menuView;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

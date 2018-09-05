//
//  KInputBoxEmojiMenuView.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/28.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxEmojiMenuView.h"


#import "KEmojiGroup.h"

@interface KInputBoxEmojiMenuView()

@end

@implementation KInputBoxEmojiMenuView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.addButton];
    [self addSubview:self.scrollView];
    [self addSubview:self.sendButton];
    
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(MENU_EMOJI_ITEM_HEIGHT - 0.25, 5, 0.5, MENU_EMOJI_ITEM_HEIGHT - 10)];
    leftLine.backgroundColor = KLineColor;
    [self addSubview:leftLine];
    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(MSWIDTH - MENU_EMOJI_ITEM_HEIGHT - 20 - 0.25, 0, 0.5, MENU_EMOJI_ITEM_HEIGHT)];
    rightLine.backgroundColor = KLineColor;
    [self addSubview:rightLine];
    
    KEmojiGroupManager *emojiManager = [KEmojiGroupManager shareManager];
    
    NSArray *emojiGroups = [emojiManager emojiGroup];
    // 设置contentSize
    self.scrollView.contentSize = CGSizeMake(emojiGroups.count * MENU_EMOJI_ITEM_HEIGHT, 0);
    
    KEmojiGroup *lastEmojiGroup = emojiManager.currentGroup;
    
    __block NSInteger index = 0;
    if (emojiGroups.count == 1) {
        index = 0;
    }
    else {
        for (KEmojiGroup *group in emojiGroups)
        {
            if ([group.groupID isEqualToString:lastEmojiGroup.groupID])
            {
                break;
            }
            
            index ++;
        }
    }
    
    
    __block CGFloat originX = 0;
    kWeakSelf;
    // 添加表情组
    [emojiGroups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KEmojiGroup *emojiModel = obj;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(originX * idx, 0, MENU_EMOJI_ITEM_HEIGHT, MENU_EMOJI_ITEM_HEIGHT)];
        [button setImage:[UIImage imageNamed:emojiModel.groupName] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
        
        button.imageView.backgroundColor = [UIColor clearColor];
        button.backgroundColor = idx == index ? [ColorTools colorWithHexString:@"0xeeeeee"] : [UIColor whiteColor];
        button.tag = 10 + idx;
        [button addTarget:weakSelf action:@selector(didSelectEmojiGroup:) forControlEvents:UIControlEventTouchUpInside];
        [weakSelf.scrollView addSubview:button];
        originX = originX + MENU_EMOJI_ITEM_HEIGHT;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(originX - 0.25, 5, 0.5, MENU_EMOJI_ITEM_HEIGHT - 10)];
        line.backgroundColor = [ColorTools colorWithHexString:@"0xeeeeee"];
        [weakSelf.scrollView addSubview:line];
        if (idx == index) {
            weakSelf.lastSelectEemojiGroup = button;
            button.backgroundColor = [ColorTools colorWithHexString:@"0xeeeeee"];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteEmojiToEmpty) name:@"deleteEmojiToEmpty" object:nil];
    
}

- (void)deleteEmojiToEmpty
{
    [self.sendButton setBackgroundColor:[UIColor whiteColor]];
    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

// 选择的表情组
- (void)didSelectEmojiGroup:(UIButton *)sender
{
    if (![self.lastSelectEemojiGroup isEqual:sender])
    {
        NSArray *emojiGroups     = [[KEmojiGroupManager shareManager] emojiGroup];
        KEmojiGroup *emojiGroup  = emojiGroups[sender.tag - 10];
        sender.backgroundColor   = [ColorTools colorWithHexString:@"0xeeeeee"];
        self.lastSelectEemojiGroup.backgroundColor = [UIColor whiteColor];
        self.lastSelectEemojiGroup = sender;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(emojiMenuView:didSelectEmojiGroup:)])
        {
            [self.delegate emojiMenuView:self didSelectEmojiGroup:emojiGroup];
        }
    }
}

// 发送表情
- (void)sendEmojiAction:(UIButton *)sender
{
    sender.backgroundColor = [UIColor whiteColor];
    [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiMenuView:sendEmoji:)])
    {
        [self.delegate emojiMenuView:self sendEmoji:sender];
    }
}

// 点击添加表情
- (void)clickAddButtonAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiMenuView:clickAddAction:)])
    {
        [self.delegate emojiMenuView:self clickAddAction:sender];
    }
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(44, 0, MSWIDTH - 2*MENU_EMOJI_ITEM_HEIGHT - 20, MENU_EMOJI_ITEM_HEIGHT)];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
    }
    
    return _scrollView;
}

- (UIButton *)addButton
{
    if (!_addButton)
    {
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, MENU_EMOJI_ITEM_HEIGHT, MENU_EMOJI_ITEM_HEIGHT)];
        [_addButton setImage:[UIImage imageNamed:@"icon_inputBox_menu_add"] forState:UIControlStateNormal];
        [_addButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_addButton addTarget:self action:@selector(clickAddButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addButton;
}

- (UIButton *)sendButton
{
    if (!_sendButton)
    {
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(MSWIDTH-MENU_EMOJI_ITEM_HEIGHT - 20, 0, MENU_EMOJI_ITEM_HEIGHT+20, MENU_EMOJI_ITEM_HEIGHT)];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton addTarget:self action:@selector(sendEmojiAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sendButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

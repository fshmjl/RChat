//
//  KInputBoxMoreItemView.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/7.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxMoreItemView.h"


#import "KInputBoxMoreModel.h"
#import "KInputBoxMoreUnitView.h"

@implementation KInputBoxMoreItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self showEmojiGroupDetailFromIndex:0 count:8];
    }
    return self;
}

- (void)showEmojiGroupDetailFromIndex:(NSInteger)fromIndex count:(NSInteger)count
{
    KInputBoxMoreManager  *inputBoxMoreManager = [[KInputBoxMoreManager alloc] init];
    KInputBoxMoreUnitView *lastUnitView = nil;
    
    NSArray *moreModels = inputBoxMoreManager.moreItemModels;
    
    NSInteger cycleIndex = 0;
    NSInteger differenceValue = 0;
    if (count > moreModels.count)
    {
        differenceValue = count - moreModels.count;
    }
    count = count - differenceValue;
    
    for (NSInteger i = fromIndex; i < fromIndex + count ; i ++)
    {
        KInputBoxMoreUnitView *unitView = nil;
        if (cycleIndex < self.moreUnitViews.count)
        {
            unitView = [self.moreUnitViews objectAtIndex:cycleIndex];
        }
        else
        {
            if (cycleIndex % 4 != 0)
            {
                CGFloat originY = lastUnitView != nil ? lastUnitView.mj_y : INPUT_BOX_MORE_ITEM_H_INTERVAL;
                unitView = [[KInputBoxMoreUnitView alloc] initWithFrame:CGRectMake(lastUnitView.kMax_x + INPUT_BOX_MORE_ITEM_V_INTERVAL, originY, INPUT_BOX_MORE_ITEM_WIDTH, INPUT_BOX_MORE_ITEM_HEIGHT)];
            }
            else
            {
                CGFloat originY = lastUnitView != nil ? lastUnitView.kMax_y : INPUT_BOX_MORE_ITEM_H_INTERVAL;
                unitView = [[KInputBoxMoreUnitView alloc] initWithFrame:CGRectMake(INPUT_BOX_MORE_ITEM_V_INTERVAL, originY, INPUT_BOX_MORE_ITEM_WIDTH, INPUT_BOX_MORE_ITEM_HEIGHT)];
            }

            [self addSubview:unitView];
            [self.moreUnitViews addObject:unitView];
            lastUnitView = unitView;
        }

        cycleIndex += 1;
        [unitView addTarget:self action:@selector(didselecteMoreUnitView:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i >= inputBoxMoreManager.moreItemModels.count || i < 0)
        {
            [unitView setHidden:YES];
        }
        else
        {
            KInputBoxMoreModel *moreModel = moreModels[i];
            unitView.tag = i;
            [unitView setMoreModel:moreModel];
            [unitView setHidden:NO];
        }
    }
}

- (void)didselecteMoreUnitView:(KInputBoxMoreUnitView *)unitView
{
    KInputBoxMoreStatus inputBoxMoreStatus = unitView.tag + 1;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KInputBoxDidSelectedMoreView" object:nil userInfo:@{@"status":@(inputBoxMoreStatus)}];
    
}

@end

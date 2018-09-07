//
//  KSearchMessageViewController.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/21.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KSearchMessageViewController.h"

#import "NSDictionary+Json.h"

#import "KConversationModel.h"
#import "KChatViewController.h"
#import "KMessagesListTableViewCell.h"


static NSString *const cellIdentifier = @"kCellIdentifier";


@interface KSearchMessageViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray   *searchList;//满足搜索条件的数组
//@property (nonatomic, strong) KPlaceholderView *placeholderView;

@end

@implementation KSearchMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

/**
 初始化视图
 */
- (void)initView {
    
    _listView                     = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _listView.delegate            = self;
    _listView.dataSource          = self;
    _listView.backgroundColor     = KBGColor1;
    _listView.tableFooterView     = [UIView new];
    _listView.sectionIndexColor   = [UIColor blackColor];
    _listView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_listView];
    
    _listView.sd_layout.topSpaceToView(self.searchBar, 0).leftEqualToView(self.view).rightEqualToView(self.view).bottomEqualToView(self.view);
}

- (void)initData {
    _searchList = [NSMutableArray array];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 没有数据时，显示提示
    if (_searchList.count) {
       // [_placeholderView removeFromSuperview];
    }else {
       // [_listView addSubview:_placeholderView];
    }
    
    return _searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.searchList.count) {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.searchList.count) {
        UIView *headView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, 40)];
        headView.backgroundColor = [UIColor whiteColor];
        
        UILabel *tableHeaderTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 18)];
        tableHeaderTitle.font = [UIFont systemFontOfSize:14];
        tableHeaderTitle.textColor = KHex16Color2;
        tableHeaderTitle.text = @"联系人";
        [headView addSubview:tableHeaderTitle];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, headView.kMax_y-1, MSWIDTH-20, 1)];
        line.backgroundColor = KLineColor;
        [headView addSubview:line];
        return headView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    searchController.searchResultsController.view.hidden = NO;
    NSString *searchText = searchController.searchBar.text;
    if (searchText.length > 0) {
        
    }
    else {
        [self.searchList removeAllObjects];
        [self.listView reloadData];
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    for (id obj in [searchBar subviews])
    {
        if ([obj isKindOfClass:[UIView class]])
        {
            for (id obj2 in [obj subviews])
            {
                if ([obj2 isKindOfClass:[UIButton class]])
                {
                    UIButton *btn = (UIButton *)obj2;
                    [btn setTitle:@"取消" forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
        }
    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    UIButton *cancelBtn = [searchBar valueForKey:@"cancelButton"];
    cancelBtn.enabled = YES;
}

- (void)dealloc {
    NSLog(@"Search页面被释放");
}

@end

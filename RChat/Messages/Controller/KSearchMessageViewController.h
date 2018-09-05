//
//  KSearchMessageViewController.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/21.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "BaseViewController.h"

@interface KSearchMessageViewController : BaseViewController <UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) UINavigationController *navigationBarCtrl;

@end


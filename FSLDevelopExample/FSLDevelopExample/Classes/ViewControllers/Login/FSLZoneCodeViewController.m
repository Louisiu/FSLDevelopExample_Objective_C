//
//  FSLZoneCodeViewController.m
//  WeChat
//
//  Created by Fingal Liu on 2017/9/28.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import "FSLZoneCodeViewController.h"

@interface FSLZoneCodeViewController ()<UISearchBarDelegate>
/// viewModel
@property (nonatomic, readonly, strong) FSLZoneCodeViewModel *viewModel;
/// searchController
@property (nonatomic, readwrite, strong) UISearchController *searchController;

@end

@implementation FSLZoneCodeViewController

@dynamic viewModel;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UITextField *sbTextField = [self.searchController.searchBar valueForKey:@"searchField"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// 设置
    [self _setup];
    
    /// 设置导航栏
    [self _setupNavigationItem];
    
    /// 设置子控件
    [self _setupSubViews];
}
#pragma mark - 事件处理
- (void)_back{
    [self.viewModel.closeCommand execute:nil];
}


#pragma mark - 初始化
- (void)_setup{
    
}

#pragma mark - 设置导航栏
- (void)_setupNavigationItem{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem fsl_backItemWithTitle:@"返回" imageName:@"barbuttonicon_back_15x30" target:self action:@selector(_back)];
}

#pragma mark - 设置子控件
- (void)_setupSubViews{
    
    UIView *tableHeaderView = [[UIView alloc] init];
    tableHeaderView.backgroundColor = self.view.backgroundColor;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.hidesNavigationBarDuringPresentation = YES;
   
    /// 配置SearchBar
    UISearchBar *searchBar = self.searchController.searchBar;
    [searchBar fsl_configureSearchBar];
    [searchBar sizeToFit];
    self.tableView.tableHeaderView = searchBar;
    self.definesPresentationContext = YES;
    
    /// 加载plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Zone" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSDictionary dictionaryWithPlistData:data];
}


@end

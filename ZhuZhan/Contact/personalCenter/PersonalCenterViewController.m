//
//  PersonalCenterViewController.m
//  PersonalCenter
//
//  Created by Jack on 14-8-18.
//  Copyright (c) 2014年 Jack. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "AccountViewController.h"
#import "LoginModel.h"
#import "HomePageViewController.h"
#import "AppDelegate.h"
#import "LoginSqlite.h"
#import "CommentApi.h"
#import "PersonalCenterModel.h"
#import "MJRefresh.h"
#import "PersonalCenterCellView.h"
#import "PersonalProjectTableViewCell.h"
@interface PersonalCenterViewController ()

@end

@implementation PersonalCenterViewController
static NSString * const PSTableViewCellIdentifier = @"PSTableViewCellIdentifier";
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //恢复tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarRestore];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    //隐藏tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarHide];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //LeftButton设置属性
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 29, 28.5)];
    [leftButton setBackgroundImage:[GetImagePath getImagePath:@"icon_04"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    //RightButton设置属性
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 70, 19.5)];
    [rightButton setTitle:@"账号设置" forState:UIControlStateNormal];
    rightButton.titleLabel.font=[UIFont systemFontOfSize:14];
    rightButton.titleLabel.textColor = [UIColor whiteColor];
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.title = @"个人中心";

    
    _pathCover = [[XHPathCover alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 154)];
    _pathCover.delegate = self;
    [_pathCover setBackgroundImage:[GetImagePath getImagePath:@"首页_16"]];
    [_pathCover setHeadImageUrl:[NSString stringWithFormat:@"%s%@",serverAddress,[LoginSqlite getdata:@"userImageUrl" defaultdata:@"userImageUrl"]]];
    [_pathCover hidewaterDropRefresh];
    [_pathCover setHeadImageFrame:CGRectMake(125, -20, 70, 70)];
    [_pathCover.headImage.layer setMasksToBounds:YES];
    [_pathCover.headImage.layer setCornerRadius:35];
    [_pathCover setNameFrame:CGRectMake(145, 50, 100, 20) font:[UIFont systemFontOfSize:14]];
    _pathCover.userNameLabel.textAlignment = NSTextAlignmentCenter;
    _pathCover.userNameLabel.center = CGPointMake(157.5, 60);
    
    [_pathCover setInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Jack", XHUserNameKey, nil]];
    self.tableView.tableHeaderView = self.pathCover;
    
    //时间标签
    _timeScroller = [[ACTimeScroller alloc] initWithDelegate:self];
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:PSTableViewCellIdentifier];
    
    __weak PersonalCenterViewController *wself = self;
    [_pathCover setHandleRefreshEvent:^{
        [wself _refreshing];
    }];
    
    
    showArr = [[NSMutableArray alloc] init];
    contentViews=[[NSMutableArray alloc]init];
    
    _datasource = [[NSMutableArray alloc] init];
    [CommentApi PersonalActiveWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            showArr = posts;
            for(int i=0;i<showArr.count;i++){
                PersonalCenterModel *model = showArr[i];
                NSLog(@"%@",model.a_content);
                [_datasource addObject:model.a_time];
                [self.tableView reloadData];
            }
        }
    } userId:@"13756154-7db5-4516-bcc6-6b7842504c81" startIndex:0];
    
    
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.backgroundColor = RGBCOLOR(239, 237, 237);
}


-(void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClick{//账户按钮触发的事件
    AccountViewController *accountVC = [[AccountViewController alloc] init];
    [self.navigationController pushViewController:accountVC animated:YES];
}

- (void)_refreshing {
    // refresh your data sources
    __weak PersonalCenterViewController *wself = self;
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [wself.pathCover stopRefresh];
    });
}

/******************************************************************************************************************/
//滚动是触发的事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidScroll:scrollView];
    [_timeScroller scrollViewDidScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidEndDecelerating:scrollView];
    [_timeScroller scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pathCover scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_pathCover scrollViewWillBeginDragging:scrollView];
    [_timeScroller scrollViewWillBeginDragging];
}
/******************************************************************************************************************/



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentViews.count;
    NSLog(@"222");
    return showArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonalCenterModel *model;
    if(showArr.count !=0){
        model = showArr[indexPath.row];
    }
    if([model.a_category isEqualToString:@"Project"]&&0){
        NSString *CellIdentifier = [NSString stringWithFormat:@"PersonalProjectTableViewCell"];
        PersonalProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[PersonalProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = NO;
        return cell;
    }else{
        NSString *CellIdentifier = [NSString stringWithFormat:@"ContactProjectTableViewCell"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        cell.contentView.backgroundColor = RGBCOLOR(239, 237, 237);
        [cell.contentView addSubview:contentViews[indexPath.row]];
        cell.selectionStyle = NO;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [contentViews[indexPath.row] frame].size.height;
    PersonalCenterModel *model;
    if(showArr.count !=0){
        model = showArr[indexPath.row];
    }
    if([model.a_category isEqualToString:@"Project"]){
        return 50;
    }
    
    
    
    if (indexPath.row==0) {
        return 60;
    }
    if (indexPath.row ==1 ||indexPath.row==2 ||indexPath.row==3) {
        return 50;
    }
    
    if (indexPath.row==4) {
        return 80;
    }
    return 200;
}

//时间标签
- (UITableView *)tableViewForTimeScroller:(ACTimeScroller *)timeScroller
{
    return [self tableView];
}
//传入时间标签的date
- (NSDate *)timeScroller:(ACTimeScroller *)timeScroller dateForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    return _datasource[[indexPath row]];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)gotoMyCenter{

}

@end

//
//  ContactViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-5.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import "ContactViewController.h"
#import "CompanyMemberViewController.h"
#import "PersonalCenterViewController.h"
#import "PersonalDetailViewController.h"
#import "LoginModel.h"
#import "PublishViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "RecommendLetterViewController.h"
#import "ContactProjectTableViewCell.h"
#import "ContactCommentTableViewCell.h"
#import "ContactModel.h"
#import "ContactCommentModel.h"
#import "CommentApi.h"
#import "ConnectionAvailable.h"
#import "BirthDay.h"
#import "LoginSqlite.h"
#import "ActivesModel.h"
#import "AppDelegate.h"
#import "HomePageViewController.h"
#import "LoginSqlite.h"
#import "ProgramDetailViewController.h"
#import "MJRefresh.h"
#import "RegistViewController.h"
#import "MBProgressHUD.h"
static NSString * const PSTableViewCellIdentifier = @"PSTableViewCellIdentifier";
@interface ContactViewController ()

@end

@implementation ContactViewController
@synthesize transparent;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"GurmukhiMN-Bold" size:19], NSFontAttributeName,
                                                                     nil]];
    
    //RightButton设置属性
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 21, 21)];
    [rightButton setImage:[GetImagePath getImagePath:@"人脉_02a"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.title = @"人脉";
    
    
    //上拉刷新界面
    _pathCover = [[XHPathCover alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 154)];
    _pathCover.delegate = self;
    [_pathCover setBackgroundImage:[GetImagePath getImagePath:@"bg001"]];
    [_pathCover setHeadTaget];
    self.tableView.tableHeaderView = self.pathCover;
    //时间标签
    _timeScroller = [[ACTimeScroller alloc] initWithDelegate:self];
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:PSTableViewCellIdentifier];
    
    
    self.tableView.separatorStyle = NO;
    [self.tableView setBackgroundColor:RGBCOLOR(242, 242, 242)];
    __weak ContactViewController *wself = self;
    [_pathCover setHandleRefreshEvent:^{
        [wself _refreshing];
    }];
    
    //集成刷新控件
    [self setupRefresh];
    
    startIndex = 0;
    showArr = [[NSMutableArray alloc] init];
    viewArr = [[NSMutableArray alloc] init];
    _datasource = [[NSMutableArray alloc] init];

    [self firstNetWork];
}

-(void)firstNetWork{
    if(![[LoginSqlite getdata:@"deviceToken"] isEqualToString:@""]){
        [LoginModel GetUserInformationWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                ContactModel *model = posts[0];
                [LoginSqlite insertData:model.userImage datakey:@"userImage"];
                [LoginSqlite insertData:model.userName datakey:@"userName"];
                [_pathCover setHeadImageUrl:model.userImage];
                [_pathCover setInfo:[NSDictionary dictionaryWithObjectsAndKeys:model.userName, XHUserNameKey,[NSString stringWithFormat:@"%@     %@",model.companyName,model.position], XHBirthdayKey, nil]];
            }
        } userId:[LoginSqlite getdata:@"userId"] noNetWork:^{
            self.tableView.scrollEnabled=NO;
            [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view reloadBlock:^{
                self.tableView.scrollEnabled=YES;
                [self firstNetWork];
            }];
        }];
    }
    
    [ContactModel AllActivesWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            showArr = posts;
            for(int i=0;i<showArr.count;i++){
                ActivesModel *model = showArr[i];
                if([model.a_eventType isEqualToString:@"Actives"]){
                    commentView = [CommentView setFram:model];
                    [viewArr addObject:commentView];
                }else{
                    [viewArr addObject:@""];
                }
                [_datasource addObject:model.a_time];
            }
            [self.tableView reloadData];
        }
    } userId:[LoginSqlite getdata:@"userId"] startIndex:0 noNetWork:^{
        self.tableView.scrollEnabled=NO;
        [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view reloadBlock:^{
            self.tableView.scrollEnabled=YES;
            [self firstNetWork];
        }];
    }];
}

-(void)publish
{
    NSLog(@"发布产品");
    
    NSString *deviceToken = [LoginSqlite getdata:@"deviceToken"];
    
    if ([deviceToken isEqualToString:@""]) {
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.delegate = self;
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.view.window.rootViewController presentViewController:nv animated:YES completion:nil];
    }else{
        PublishViewController *publishVC = [[PublishViewController alloc] init];
        [self.navigationController pushViewController:publishVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_refreshing {
    // refresh your data sources
    [self reloadView];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)footerRereshing
{
    [ContactModel AllActivesWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            startIndex++;
            [showArr addObjectsFromArray:posts];
            for(int i=0;i<posts.count;i++){
                ActivesModel *model = posts[i];
                if([model.a_eventType isEqualToString:@"Actives"]){
                    commentView = [CommentView setFram:model];
                    [viewArr addObject:commentView];
                }else{
                    [viewArr addObject:@""];
                }
                [_datasource addObject:model.a_time];
            }
            _timeScroller.hidden=YES;
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 700ull *  NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                _timeScroller.hidden=NO;
            });
        }
        [self.tableView footerEndRefreshing];
    } userId:[LoginSqlite getdata:@"userId"] startIndex:startIndex+1 noNetWork:^{
        [self.tableView footerEndRefreshing];
        self.tableView.scrollEnabled=NO;
        [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view reloadBlock:^{
            self.tableView.scrollEnabled=YES;
            [self footerRereshing];
        }];
    }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [showArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PSTableViewCellIdentifier];
    ActivesModel *model = showArr[indexPath.row];
    if([model.a_category isEqualToString:@"Project"]){
        NSString *CellIdentifier = [NSString stringWithFormat:@"ContactProjectTableViewCell"];
        ContactProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[ContactProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.delegate = self;
        cell.selectionStyle = NO;
        cell.model = model;
        return cell;
    }else if([model.a_category isEqualToString:@"Personal"]){
        if([model.a_eventType isEqualToString:@"Actives"]){
            NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = NO;
            for(int i=0;i<cell.contentView.subviews.count;i++) {
                [((UIView*)[cell.contentView.subviews objectAtIndex:i]) removeFromSuperview];
            }
            commentView = viewArr[indexPath.row];
            commentView.indexpath = indexpath;
            commentView.delegate = self;
            commentView.headImageDelegate = self;
            commentView.indexpath = indexPath;
            commentView.showArr = model.a_commentsArr;
            [cell.contentView addSubview:commentView];
            return cell;
        }else{
            NSString *CellIdentifier = [NSString stringWithFormat:@"ContactTableViewCell"];
            ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell){
                cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.delegate = self;
            cell.selectionStyle = NO;
            cell.model = model;
            return cell;
        }
    }else if([model.a_category isEqualToString:@"Company"]){
        if([model.a_eventType isEqualToString:@"Actives"]){
            NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = NO;
            for(int i=0;i<cell.contentView.subviews.count;i++) {
                [((UIView*)[cell.contentView.subviews objectAtIndex:i]) removeFromSuperview];
            }
            commentView = viewArr[indexPath.row];
            commentView.indexpath = indexpath;
            commentView.delegate = self;
            commentView.headImageDelegate = self;
            commentView.indexpath = indexPath;
            commentView.showArr = model.a_commentsArr;
            [cell.contentView addSubview:commentView];
            return cell;
        }else{
            NSString *CellIdentifier = [NSString stringWithFormat:@"ContactTableViewCell"];
            ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell){
                cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.delegate = self;
            cell.selectionStyle = NO;
            cell.model = model;
            return cell;
        }
    }else{
        NSString *CellIdentifier = [NSString stringWithFormat:@"ContactTableViewCell"];
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.delegate = self;
        cell.selectionStyle = NO;
        cell.model = model;
        return cell;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ActivesModel *model = showArr[indexPath.row];
    if([model.a_category isEqualToString:@"Project"]){
        return 50;
    }else if([model.a_category isEqualToString:@"Personal"]){
        if([model.a_eventType isEqualToString:@"Actives"]){
            commentView = viewArr[indexPath.row];
            return commentView.frame.size.height;
        }else{
            return 50;
        }
    }else if([model.a_category isEqualToString:@"Company"]){
        if([model.a_eventType isEqualToString:@"Actives"]){
            commentView = viewArr[indexPath.row];
            return commentView.frame.size.height;
        }else{
            return 50;
        }
    }else{
        return 50;
    }
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ActivesModel *model = showArr[indexPath.row];
    NSLog(@"%@",model.a_entityUrl);
    if([model.a_category isEqualToString:@"Project"]){
        ProgramDetailViewController *vc = [[ProgramDetailViewController alloc] init];
        vc.projectId = model.a_entityId;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([model.a_category isEqualToString:@"Personal"]){
        if([model.a_eventType isEqualToString:@"Actives"]){
            ActivesModel *model = showArr[indexPath.row];
            NSLog(@"==>%@",model.a_entityUrl);
            ProductDetailViewController* vc=[[ProductDetailViewController alloc]initWithActivesModel:model];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
        }
    }else if([model.a_category isEqualToString:@"Company"]){
        if([model.a_eventType isEqualToString:@"Actives"]){
            ActivesModel *model = showArr[indexPath.row];
            NSLog(@"==>%@",model.a_entityUrl);
            ProductDetailViewController* vc=[[ProductDetailViewController alloc]initWithActivesModel:model];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
        }
    }else{
        ActivesModel *model = showArr[indexPath.row];
        NSLog(@"==>%@",model.a_entityUrl);
        ProductDetailViewController* vc=[[ProductDetailViewController alloc]initWithActivesModel:model];
        [self.navigationController pushViewController:vc animated:YES];
    }
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

//点击自己头像去个人中心
-(void)gotoMyCenter{
    NSLog(@"gotoMyCenter");

    NSString *deviceToken = [LoginSqlite getdata:@"deviceToken"];

    if ([deviceToken isEqualToString:@""]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.delegate = self;
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.view.window.rootViewController presentViewController:nv animated:YES completion:nil];
    }else{
        PersonalCenterViewController *personalVC = [[PersonalCenterViewController alloc] init];
        [self.navigationController pushViewController:personalVC animated:YES];
    }
}

-(void)HeadImageAction:(NSIndexPath *)indexPath{
    if (![ConnectionAvailable isConnectionAvailable]) {
        [MBProgressHUD myShowHUDAddedTo:self.view animated:YES];
        return;
    }
    
    ActivesModel *model = showArr[indexPath.row];
    showVC = [[ShowViewController alloc] init];
    showVC.delegate =self;
    showVC.createdBy = model.a_createdBy;
    [showVC.view setFrame:CGRectMake(20, 70, 280, 300)];
    showVC.view.layer.cornerRadius = 10;//设置那个圆角的有多圆
    showVC.view.layer.masksToBounds = YES;
    [self presentPopupViewController:showVC animationType:MJPopupViewAnimationFade flag:0];
}

-(void)gotoContactDetailView:(NSString *)contactId{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    PersonalDetailViewController *personalVC = [[PersonalDetailViewController alloc] init];
    personalVC.contactId = contactId;
    [self.navigationController pushViewController:personalVC animated:YES];
}

- (void)addfocus{
//    ActivesModel *model = showArr[indexpath.row];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setValue:[LoginSqlite getdata:@"userId"] forKey:@"UserId"];
//    [dic setValue:model.a_id forKey:@"FocusId"];
//    [dic setValue:@"Personal" forKey:@"FocusType"];
//    [dic setValue:@"Personal" forKey:@"UserType"];
//    [ContactModel AddfocusWithBlock:^(NSMutableArray *posts, NSError *error) {
//        if(!error){
//            model.a_isFocused=@"1";
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//        }
//        btn.enabled=YES;
//    } dic:dic];
}

-(void)jumpToGetRecommend:(NSDictionary *)dic
{
    NSLog(@"获得推荐");
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    RecommendLetterViewController *recommendLetterVC = [[RecommendLetterViewController alloc] init];
    [self.navigationController pushViewController:recommendLetterVC animated:YES];//跳转到推荐信页面
}



-(void)addCommentView:(NSIndexPath *)indexPath{
    indexpath = indexPath;
    NSLog(@"%d",indexpath.row);
    NSString *deviceToken = [LoginSqlite getdata:@"deviceToken"];
    NSLog(@"********deviceToken***%@",deviceToken);
    if ([deviceToken isEqualToString:@""]) {
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.delegate = self;
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.view.window.rootViewController presentViewController:nv animated:YES completion:nil];
    }else{
        addCommentView = [[AddCommentViewController alloc] init];
        addCommentView.delegate = self;
        [self presentPopupViewController:addCommentView animationType:MJPopupViewAnimationFade flag:2];
    }
}

-(void)sureFromAddCommentWithComment:(NSString*)comment{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    ActivesModel *model = showArr[indexpath.row];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:model.a_id forKey:@"EntityId"];
    [dic setValue:[NSString stringWithFormat:@"%@",comment] forKey:@"CommentContents"];
    [dic setValue:model.a_category forKey:@"EntityType"];
    [dic setValue:[LoginSqlite getdata:@"userId"] forKey:@"CreatedBy"];
    [CommentApi AddEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            [self finishPostCommentWithPosts:posts activesModel:model];
        }
    } dic:dic noNetWork:nil];
}

//评论发送完后的页面tableView刷新
-(void)finishPostCommentWithPosts:(NSMutableArray*)posts activesModel:(ActivesModel*)model{
    ContactCommentModel *commentModel = [[ContactCommentModel alloc] init];
    [commentModel setDict:posts[0]];
    if(model.a_commentsArr.count >=3){
        [model.a_commentsArr removeObjectAtIndex:1];
        [model.a_commentsArr insertObject:commentModel atIndex:0];
    }else if(model.a_commentsArr.count ==2){
        [model.a_commentsArr insertObject:commentModel atIndex:0];
        [model.a_commentsArr insertObject:@"" atIndex:2];
    }else{
        [model.a_commentsArr insertObject:commentModel atIndex:0];
    }
    commentView = [CommentView setFram:model];
    [showArr replaceObjectAtIndex:indexpath.row withObject:model];
    [viewArr replaceObjectAtIndex:indexpath.row withObject:commentView];
    [self.tableView reloadData];
}

-(void)finishAddCommentFromDetailWithPosts:(NSMutableArray *)posts{
    ActivesModel *model = showArr[indexpath.row];
    [self finishPostCommentWithPosts:posts activesModel:model];
}

-(void)cancelFromAddComment{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(void)reloadView{
    [ContactModel AllActivesWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            startIndex = 0;
            [showArr removeAllObjects];
            [viewArr removeAllObjects];
            [_datasource removeAllObjects];
            showArr = posts;
            for(int i=0;i<showArr.count;i++){
                ActivesModel *model = showArr[i];
                if([model.a_eventType isEqualToString:@"Actives"]){
                    commentView = [CommentView setFram:model];
                    [viewArr addObject:commentView];
                }else{
                    [viewArr addObject:@""];
                }
                [_datasource addObject:model.a_time];
            }
            [self.tableView reloadData];
            __weak ContactViewController *wself = self;
            [wself.pathCover stopRefresh];
        }
    } userId:[LoginSqlite getdata:@"userId"] startIndex:0 noNetWork:^{
        self.tableView.scrollEnabled=NO;
        __weak ContactViewController *wself = self;
        [wself.pathCover stopRefresh];
        [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view reloadBlock:^{
            self.tableView.scrollEnabled=YES;
            [self reloadView];
        }];
    }];
}

-(void)gotoDetailView:(NSIndexPath *)indexPath{
    indexpath=indexPath;
    ActivesModel *model = showArr[indexPath.row];
    ProductDetailViewController* vc=[[ProductDetailViewController alloc]initWithActivesModel:model];
    vc.delegate=self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)loginComplete{
    [LoginModel GetUserInformationWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            ContactModel *model = posts[0];
            [LoginSqlite insertData:model.userImage datakey:@"userImage"];
            [LoginSqlite insertData:model.userName datakey:@"userName"];
            [_pathCover setHeadImageUrl:model.userImage];
             [_pathCover setInfo:[NSDictionary dictionaryWithObjectsAndKeys:model.userName, XHUserNameKey,[NSString stringWithFormat:@"%@     %@",model.companyName,model.position], XHBirthdayKey, nil]];
        }
    } userId:[LoginSqlite getdata:@"userId"] noNetWork:^{
        self.tableView.scrollEnabled=NO;
        [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view reloadBlock:^{
            self.tableView.scrollEnabled=YES;
            [self firstNetWork];
        }];
    }];
}
@end

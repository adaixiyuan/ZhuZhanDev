//
//  HomePageViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-5.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import "HomePageViewController.h"
#import "LoginModel.h"
#import "AppDelegate.h"
@interface HomePageViewController ()

@end

@implementation HomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 519)];
    contactview = [[ContactViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:contactview];
    [nav.view setFrame:CGRectMake(0, 0, 320, 519)];
    nav.navigationBar.barTintColor = RGBCOLOR(85, 103, 166);
    [contentView addSubview:nav.view];
    
    [self.view addSubview:contentView];

    
    toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 519, 320, 49)];
   [toolView setBackgroundColor:RGBCOLOR(229, 229, 229)];
    
    contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [contactBtn setFrame:CGRectMake(25, 10, 25, 36)];
    [contactBtn setBackgroundImage:[GetImagePath getImagePath:@"项目－项目专题_11a-20"] forState:UIControlStateNormal];
    contactBtn.tag = 0;
    [contactBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:contactBtn];
    
    projectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [projectBtn setFrame:CGRectMake(82, 10, 25, 36)];
    [projectBtn setBackgroundImage:[GetImagePath getImagePath:@"项目－项目专题_14a"] forState:UIControlStateNormal];
    projectBtn.tag = 1;
    [projectBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:projectBtn];
    
    companyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [companyBtn setFrame:CGRectMake(210, 10, 25, 36)];
    [companyBtn setBackgroundImage:[GetImagePath getImagePath:@"项目－项目专题_17a"] forState:UIControlStateNormal];
    companyBtn.tag = 3;
    [companyBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:companyBtn];
    
    tradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tradeBtn setFrame:CGRectMake(270, 10, 25, 36)];
    [tradeBtn setBackgroundImage:[GetImagePath getImagePath:@"项目－项目专题_23a"] forState:UIControlStateNormal];
    tradeBtn.tag = 4;
    [tradeBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:tradeBtn];
    [self.view addSubview:toolView];
    
    
    //更多按钮的实现
    UIImage *storyMenuItemImage = [GetImagePath getImagePath:@"bg-menuitem"];
    UIImage *storyMenuItemImagePressed = [GetImagePath getImagePath:@"bg-menuitem-highlighted"];
    
    // Camera MenuItem.
    QuadCurveMenuItem *cameraMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[GetImagePath getImagePath:@"icon-star"]
                                                         highlightedContentImage:nil flag:0];
    // People MenuItem.
    QuadCurveMenuItem *peopleMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[GetImagePath getImagePath:@"icon-star"]
                                                         highlightedContentImage:nil flag:0];
    // Place MenuItem.
    QuadCurveMenuItem *placeMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[GetImagePath getImagePath:@"icon-star"]
                                                        highlightedContentImage:nil flag:0];
    // Music MenuItem.
    QuadCurveMenuItem *musicMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[GetImagePath getImagePath:@"icon-star"]
                                                        highlightedContentImage:nil flag:0];
    // Thought MenuItem.
    QuadCurveMenuItem *thoughtMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                 highlightedImage:storyMenuItemImagePressed
                                                                     ContentImage:[GetImagePath getImagePath:@"icon-star"]
                                                          highlightedContentImage:nil flag:0];
    
    NSArray *menus = [NSArray arrayWithObjects:cameraMenuItem, peopleMenuItem, placeMenuItem, musicMenuItem, thoughtMenuItem, nil];
    
    menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus];
    //menu.backgroundColor=[UIColor greenColor];
    menu.delegate = self;
    [self.view addSubview:menu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)homePageTabBarHide{
    contentView.frame=CGRectMake(0, 0, 320, 568);
    [nav.view setFrame:CGRectMake(0, 0, 320, 568)];
    menu.hidden=YES;
    toolView.hidden=YES;
}

-(void)homePageTabBarRestore{
    contentView.frame=CGRectMake(0, 0, 320, 519);
    [nav.view setFrame:CGRectMake(0, 0, 320, 519)];
    menu.hidden=NO;
    toolView.hidden=NO;

}

-(void)BtnClick:(UIButton *)button{
    for(int i=0;i<contentView.subviews.count;i++) {
        [((UIView*)[contentView.subviews objectAtIndex:i]) removeFromSuperview];
    }
    switch (button.tag) {
        case 0:
            NSLog(@"人脉");
            contactview = [[ContactViewController alloc] init];
            nav = [[UINavigationController alloc] initWithRootViewController:contactview];
            [nav.view setFrame:CGRectMake(0, 0, 320, 519)];
            nav.navigationBar.barTintColor = RGBCOLOR(85, 103, 166);
            [contentView addSubview:nav.view];
            contactview = nil;
            break;
        case 1:
            NSLog(@"项目");
            projectview = [[ProjectTableViewController alloc] init];
            nav = [[UINavigationController alloc] initWithRootViewController:projectview];
            [nav.view setFrame:CGRectMake(0, 0, 320, 519)];
            nav.navigationBar.barTintColor = RGBCOLOR(85, 103, 166);
            [contentView addSubview:nav.view];
            projectview = nil;
            break;
        case 2:
            NSLog(@"更多");
            break;
        case 3:
            NSLog(@"公司");
            companyview = [[CompanyViewController alloc] init];
            nav = [[UINavigationController alloc] initWithRootViewController:companyview];
            [nav.view setFrame:CGRectMake(0, 0, 320, 519)];
            nav.navigationBar.barTintColor = RGBCOLOR(85, 103, 166);
            [contentView addSubview:nav.view];
            companyview = nil;
            break;
        case 4:
            NSLog(@"交易");
            productView = [[ProductViewController alloc] init];
            //tradeView=[[TradeViewController alloc]init];
            //testVC=[[ViewController alloc]init];
            
            nav = [[UINavigationController alloc] initWithRootViewController:productView];
            //nav = [[UINavigationController alloc] initWithRootViewController:tradeView];
            //nav=[[UINavigationController alloc]initWithRootViewController:testVC];
            [nav.view setFrame:CGRectMake(0, 0, 320, 519)];
            nav.navigationBar.barTintColor = RGBCOLOR(85, 103, 166);
            [contentView addSubview:nav.view];
            productView = nil;
            testVC=nil;
            break;
        default:
            break;
    }
}


//更多按钮的委托方法
- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    if(idx == 0){
        NSLog(@"推荐信");
    }else if(idx == 1){
        NSLog(@"添加好友");
    }else if(idx == 2){
        NSLog(@"拓展人脉");
    }else if (idx == 3){
        NSLog(@"聊天");
    }else{
        NSLog(@"通讯录");
    }
}
@end

//
//  AppDelegate.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-5.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "FaceppAPI.h"
#import "FaceLoginViewController.h"
#import "HomePageViewController.h"
#import "RecordSqlite.h"
#import "networkConnect.h"
#import "iflyMSC/iflySetting.h"
#import "Definition.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "PersonalDetailViewController.h"
#import "LoginSqlite.h"
#import "FirstOpenAppAnimationView.h"
#import "ProjectSqlite.h"
@implementation AppDelegate

+ (AppDelegate *)instance {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //设置log等级，此处log为默认在documents目录下的msc.log文件
    [IFlySetting setLogFile:LVL_NONE];
    
    //输出在console的log开关
    [IFlySetting showLogcat:NO];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    //设置msc.log的保存路径
    [IFlySetting setLogFilePath:cachePath];
    
    
    //创建语音配置
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",APPID_VALUE,TIMEOUT_VALUE];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    NSString *API_KEY = KAPI_KEY;
    NSString *API_SECRET = KAPI_SECRET;
    
    // initialize
    [FaceppAPI initWithApiKey:API_KEY andApiSecret:API_SECRET andRegion:APIServerRegionCN];
    
    // turn on the debug mode
    [FaceppAPI setDebugMode:TRUE];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 要使用百度地图，请先启动BaiduMapManager
	_mapManager = [[BMKMapManager alloc]init];
	BOOL ret = [_mapManager start:@"wcW9gbkFNFjS8s3DGogfE6ch" generalDelegate:self];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    [LoginSqlite opensql];
    [RecordSqlite opensql];
    [ProjectSqlite opensql];

    HomePageViewController *homeVC = [[HomePageViewController alloc] init];
    self.window.rootViewController = homeVC;
    [self.window makeKeyAndVisible];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"]){
        NSLog(@"第一次启动程序");
        FirstOpenAppAnimationView* firstAnimationView=[[FirstOpenAppAnimationView alloc]initWithFrame:self.window.frame];
        [self.window addSubview:firstAnimationView];
    }

    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

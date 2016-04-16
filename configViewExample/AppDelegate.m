//
//  AppDelegate.m
//  configViewExample
//
//  Created by weida on 16/4/16.
//  Copyright (c) 2016年 weida. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[MainViewController alloc] init]];
    
    [self.window makeKeyAndVisible];
    return YES;
}


@end

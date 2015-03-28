//
//  AppDelegate.m
//  EatAndGo
//
//  Created by Nguyen Minh on 13/9/14.
//  Copyright (c) 2014 EatAndGo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    [[UIView appearance] setTintColor:[UIColor whiteColor]];
    
//    [[RPNetworkUtil sharedInstance] getFoodsWithCompletion:^(NSHTTPURLResponse *response, id data, NSError *error) {
//        NSLog(@"c");
//    }];
    
//    [[RPNetworkUtil sharedInstance] orderFood:0 table:0 quantity:1 comment:@"test" withCompletion:^(NSHTTPURLResponse *response, id data, NSError *error) {
//        NSLog(@"c");
//    }];
    
//    [[RPNetworkUtil sharedInstance] viewOrdersOfTable:0 withCompletion:^(NSHTTPURLResponse *response, id data, NSError *error) {
//        NSLog(@"c");
//    }];

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

#pragma mark - Handle push notification
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* newToken = [deviceToken description];
    NSLog(@"ORIGINAL TOKEN:%@", newToken);
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"TOKEN:%@", newToken);
    
    //tokenId = newToken;
    
    //[self submitDeviceInfo];
}

-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Livelabs want to send you cool stuffs through push notification. Please enable Livelabs app push notification from Settings -> Notifications. Thank you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    NSLog(@"\n  AppDelegate : =>didFailToRegisterForRemoteNotification\n");
	NSLog(@"\n   ->Failed to get token, error: %@", error);
}

@end

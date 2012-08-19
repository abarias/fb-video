//
//  AppDelegate.m
//  fb-video
//
//  Created by Anthony Bernard Arias on 7/21/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FirstViewController.h"
#import "DefaultViewController.h"

NSString *const AYSessionStateChangedNotification = @"com.aybee.fb-video:AYSessionStateChangedNotification";

@interface AppDelegate ()

- (void)showLoginView;

@end


@implementation AppDelegate

@synthesize window = _window;



#pragma mark -
#pragma mark Facebook Login Code

- (void)showLoginView {
    // FBSample logic
    // If the login screen is not already displayed, display it. If the login screen is displayed, then
    // getting back here means the login in progress did not successfully complete. In that case,
    // notify the login view so it can update its UI appropriately.
    
    UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
    [tabBarController performSegueWithIdentifier:@"facebookLogin" sender:self];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateOpen: {
            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
            if ([[tabBarController modalViewController] isKindOfClass:[DefaultViewController class]]) {
                [tabBarController dismissModalViewControllerAnimated:YES];
            }
            
            // FBSample logic
            // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
            // responsiveness when the user tags their friends.
            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            [cacheDescriptor prefetchAndCacheForSession:session];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AYSessionStateChangedNotification
                                                        object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", @"user_photos", nil];
    return [FBSession openActiveSessionWithPermissions:permissions
                                          allowLoginUI:allowLoginUI
                                     completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                         [self sessionStateChanged:session state:state error:error];
                                     }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    
    // FBSample logic
    // See if we have a valid token for the current state.
    if (![self openSessionWithAllowLoginUI:NO]) {
        // No? Display the login page.
        [self showLoginView];
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

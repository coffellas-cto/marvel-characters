//
//  GDAppDelegate.m
//  Marvel
//
//  Created by Alex G on 10.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "GDAppDelegate.h"
#import <RestKit/RestKit.h>
#import "GDMainViewController.h"
#import "GDDetailedViewController.h"
#import "GDMarvelRKObjectManager.h"

@implementation GDAppDelegate
{
	GDDetailedViewController *detailedViewController;
	UINavigationController *navVC;
}

- (void)mustShowDetails:(NSNotification *)notification
{
	// Process the notification from an instance of GDMainViewController to show an instance of GDDetailedViewController.
	if (!detailedViewController)
		detailedViewController = [[GDDetailedViewController alloc] init];

	detailedViewController.selectedCharInnerID = notification.object;
	[navVC pushViewController:detailedViewController animated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	// Override point for customization after application launch.
	self.window.backgroundColor = [UIColor whiteColor];

	GDMainViewController *vc = [[GDMainViewController alloc] init];
	navVC = [[UINavigationController alloc] initWithRootViewController:vc];

	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(mustShowDetails:)
	                                             name:NOTIFICATION_MUST_SHOW_DETAILS
	                                           object:nil];

	self.window.rootViewController = navVC;
	[self.window makeKeyAndVisible];
	return YES;
}

@end

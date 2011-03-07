//
//  MoodyAppDelegate.m
//  Moody
//
//  Created by g g on 13/08/09.
//  Copyright g 2009. All rights reserved.
//

#import "MoodyAppDelegate.h"
#import "MoodyViewController.h"

@implementation MoodyAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    [application setIdleTimerDisabled:true]; //disable screen saver
    // Override point for customization after app launch 
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end

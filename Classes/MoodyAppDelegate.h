//
//  MoodyAppDelegate.h
//  Moody
//
//  Created by g g on 13/08/09.
//  Copyright g 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoodyViewController;

@interface MoodyAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MoodyViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MoodyViewController *viewController;

@end


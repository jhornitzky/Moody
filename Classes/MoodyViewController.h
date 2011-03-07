//
//  MoodyViewController.h
//  Moody
//
//  Created by g g on 13/08/09.
//  Copyright g 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterRequest.h"

@interface MoodyViewController : UIViewController {
	UISlider *slider;
	CGFloat animatedDistance;
	UIImageView *drawImage;
	UITextField *statusTextField;
	int drawHeight;
	UITextField *textfieldName;
	UITextField *textfieldPassword;
	UIActivityIndicatorView *spinner; 
	TwitterRequest *t;
}

@property(nonatomic,retain) IBOutlet UISlider *slider; 
@property(nonatomic,retain) IBOutlet UIImageView *drawImage;
@property(nonatomic,retain) IBOutlet UITextField *statusTextField;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner; 

- (IBAction) updateBackground:(id)sender;
- (IBAction) updateText:(id)sender; 
- (IBAction) sendHappinessToTwitter:(id)sender;

@end


//
//  MoodyViewController.m
//  Moody
//
//  Created by g g on 13/08/09.
//  Copyright g 2009. All rights reserved.
//

#import "MoodyViewController.h"

@interface MoodyViewController (Private)
- (void) pageRender:(float) f;
@end

@implementation MoodyViewController

@synthesize slider, drawImage, statusTextField, spinner;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	float a = [prefs floatForKey:@"moodyval"];
	[self.slider setValue:a];
	[self.statusTextField setText:[prefs stringForKey:@"moodystatus"]];
	[self pageRender:a];
	
    [super viewDidLoad];
}

- (IBAction) updateBackground:(UISlider*)sender {
	//set vars
	float fx = sender.value;
	[self pageRender:fx];
}

- (void) pageRender:(float) f {
	float middleY = drawImage.frame.size.height*f;
	float outerY = drawImage.frame.size.height*(1.0-f);
	
	//Update slider val
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setFloat:f forKey:@"moodyval"];
	[prefs synchronize];
	
	//First render the background
	if (f < 0.5) { 
		f = f*2;
		[self.view setBackgroundColor:[UIColor colorWithRed:1.0 green:f blue:f alpha:1.0]];
	} else if (f > 0.5) {
		f = (1 - f)*2;
		[self.view setBackgroundColor:[UIColor colorWithRed:f green:f blue:1.0 alpha:1.0]];
	}
	
	//Then do the line
	NSLog(@"Should be drawing line now!");
	
	drawImage.image = nil;
	UIGraphicsBeginImageContext(drawImage.frame.size);
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
	CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0-f, 1.0-f, 1.0-f, 1.0);
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(),0,outerY);
    CGContextAddCurveToPoint(UIGraphicsGetCurrentContext(), 0, outerY, drawImage.frame.size.width/2, middleY, drawImage.frame.size.width, outerY);
	CGContextDrawPath(UIGraphicsGetCurrentContext(),kCGPathStroke);
	CGContextFlush(UIGraphicsGetCurrentContext());
	drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}


//Update the text status
- (IBAction) updateText:(id)sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:statusTextField.text forKey:@"moodystatus"];
	[prefs synchronize];
}

//Send how happy or sad you are to Twitter!
-(IBAction) sendHappinessToTwitter:(id)sender {
	NSLog(@"Sending Happiness!");
	
	if ([statusTextField.text length] == 0 )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"You need to enter text to send to Twitter"
													   delegate:self cancelButtonTitle:@"OK"  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Login" message:@"\n\n\n"
												   delegate:self cancelButtonTitle:@"Cancel"  otherButtonTitles:@"Submit", nil];
	
	textfieldName = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
	textfieldName.keyboardType = UIKeyboardTypeAlphabet;
	textfieldName.keyboardAppearance = UIKeyboardAppearanceAlert;
	textfieldName.autocorrectionType = UITextAutocorrectionTypeNo;
	textfieldName.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textfieldName.text = [prefs stringForKey:@"moodyuser"];
	[textfieldName setBorderStyle:UITextBorderStyleRoundedRect];
	[textfieldName setPlaceholder:@"User name"];
	
	textfieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(12, 80, 260, 25)];
	textfieldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
	textfieldPassword.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	textfieldPassword.keyboardAppearance = UIKeyboardAppearanceAlert;
	textfieldPassword.autocorrectionType = UITextAutocorrectionTypeNo;
	textfieldPassword.secureTextEntry = YES;
	textfieldPassword.text = [prefs stringForKey:@"moodypass"];
	[textfieldPassword setBorderStyle:UITextBorderStyleRoundedRect];
	[textfieldPassword setPlaceholder:@"Password"];
	
	[alert addSubview:textfieldName];
	[alert addSubview:textfieldPassword];
	
	CGAffineTransform tran = CGAffineTransformMakeTranslation(0.0f, 65.0f);
	[alert setTransform: tran];
	
	[alert show];
	[alert release];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    //alertView.frame = CGRectMake( 10, 120, 200, 200 );
	//alertView.autoresizesSubviews = true;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Clicked the Submit button
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		NSLog(@"Clicked Submit Button!");
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		
		NSLog(@"Name: %@", textfieldName.text);
		NSLog(@"Password: %@", textfieldPassword.text);
		[prefs setObject:textfieldName.text forKey:@"moodyuser"];
		[prefs setObject:textfieldPassword.text forKey:@"moodypass"];
		
		t = [[TwitterRequest alloc] init];
		t.username = textfieldName.text;
		t.password = textfieldPassword.text;
		
		NSMutableString *tweetText = [[NSMutableString alloc]init];
		
		if (slider.value < 0.25) {
			[tweetText appendString:@"I am feeling unhappy because "];
		} else if (slider.value < 0.5) {
			[tweetText appendString:@"I am feeling sort of unhappy because "];
		} else if (slider.value < 0.75) {
			[tweetText appendString:@"I am feeling sort of happy because "];
		} else if (slider.value <= 1.0) {
			[tweetText appendString:@"I am feeling happy because "];
		}
		
		[tweetText appendString:statusTextField.text];
		
		[spinner startAnimating];
		
		[t statuses_update:tweetText delegate:self requestSelector:@selector(status_updateCallback:) errorSelector:@selector(status_errorCallback:) ];
		[tweetText release];
	}
}

- (void) status_updateCallback: (NSData *) content {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Finished Tweeting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	[self dismissModalViewControllerAnimated:YES];
	[spinner stopAnimating];
	//NSLog(@"%@",[[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding]);
	[t release];
	[textfieldName release];
	[textfieldPassword release];
}

- (void) status_errorCallback: (NSData *) content {
	//NSString *failureMsg = [[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Could not Tweet! Check your username and password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	[spinner stopAnimating];
	[t release];
	[textfieldName release];
	[textfieldPassword release];
}


//Move the text field up and down

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
	[self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
	[self.view.window convertRect:self.view.bounds fromView:self.view];	
	
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)* viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	
	if (heightFraction < 0.0) {
        heightFraction = 0.0;
    }	
    else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
	
	animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
	
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}
*.

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end

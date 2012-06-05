//
//  OCViewController.m
//  NSObjectBindingsDemo
//
//  Created by Olivier Collet on 12-03-21.
//  Copyright (c) 2012 Olivier Collet. All rights reserved.
//

#import "NSObject+OCBindingsAdditions.h"
#import "OCViewController.h"

static NSString * const kBindingsIdentifier = @"MyBindings";

@interface OCViewController ()
@property (strong, nonatomic) IBOutlet UIButton *clickmeButton;
@property (strong, nonatomic) IBOutlet UILabel *middleLabel;
@property (strong, nonatomic) IBOutlet UIButton *salmonButton;
@property (strong, nonatomic) IBOutlet UIButton *aquaButton;
@property (strong, nonatomic) IBOutlet UIButton *mossButton;
@property (strong, nonatomic) IBOutlet UIButton *silverButton;

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *notificationBindingIdentifier;

- (IBAction)colorButtonAction:(UIButton *)sender;

@end

//

@implementation OCViewController
@synthesize clickmeButton;
@synthesize middleLabel;
@synthesize salmonButton;
@synthesize aquaButton;
@synthesize mossButton;
@synthesize silverButton;
@synthesize color;
@synthesize notificationBindingIdentifier;

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self addBindings:nil];
}

- (void)viewDidUnload
{
	[self removeBindings:nil];

	[self setMiddleLabel:nil];
	[self setClickmeButton:nil];
	[self setSalmonButton:nil];
	[self setAquaButton:nil];
	[self setMossButton:nil];
	[self setSilverButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - This is where the magic happens

- (IBAction)addBindings:(id)sender {
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:kBindingsIdentifier, OCBindingIdentifierOptionKey, nil];

	// Update the controller view's background whenever the color property changes
	[self.view bindKeyPath:@"backgroundColor" toObject:self withKeyPath:@"color" options:options];
	
	
	// Update the middle label's text whenever the controller's title changes
	[self.middleLabel bindKeyPath:@"text" toObject:self withKeyPath:@"title" options:nil];
	
	
	// Update the middle label's text color depending on the controller view's background color
	[NSObject bindBlock:^(id value) {
		if ([value isKindOfClass:[UIColor class]]) {
			UIColor *theColor = (UIColor *)value;
			if ([theColor isEqual:[UIColor blackColor]]) {
				[middleLabel setTextColor:[UIColor whiteColor]];
			}
			else {
				[middleLabel setTextColor:[UIColor blackColor]];
			}
		}
	} toObject:self withKeyPath:@"color" options:nil];
	
	
	// Update the title whenever the app becomes active
	self.notificationBindingIdentifier = [NSObject bindBlock:^(id notification) {
		self.title = @"Active";
	} toNotification:UIApplicationDidBecomeActiveNotification options:nil];
}

- (IBAction)removeBindings:(id)sender {
	// Remove bindings with the identifier option
	[NSObject unbindBindingsWithIdentifierOption:kBindingsIdentifier];

	// Remove the notification binding
	[NSObject unbindBindingWithIdentifier:self.notificationBindingIdentifier];
	
	// Remove all the bindings on the view controller
	[self unbind];
}

#pragma mark - End of magic


- (IBAction)titleChangeAction:(id)sender {
	static NSInteger i = 1;
	if (i > 1) {
		self.title = [NSString stringWithFormat:@"You changed the title %d times.", i];
	}
	else {
		self.title = @"You changed the title!";
	}
	i++;
}

- (IBAction)colorButtonAction:(UIButton *)sender {
	[self setColor:[sender titleColorForState:UIControlStateNormal]];
}

@end

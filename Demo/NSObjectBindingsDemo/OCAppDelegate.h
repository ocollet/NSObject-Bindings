//
//  OCAppDelegate.h
//  NSObjectBindingsDemo
//
//  Created by Olivier Collet on 12-03-21.
//  Copyright (c) 2012 Olivier Collet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCViewController;

@interface OCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OCViewController *viewController;

@end

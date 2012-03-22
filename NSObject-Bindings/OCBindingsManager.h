//
//  OCBindingsManager.h
//  iOSBindingsLab
//
//  Created by Olivier Collet on 12-03-09.
//  Copyright (c) 2012 Olivier Collet. All rights reserved.
//

#import <Foundation/Foundation.h>

/*	CAUTION: You should never use this object.
 * 			 Use the NSObject (OCBindingsAdditions) category methods instead.
 */


// Basic binding object
@interface OCBinding : NSObject
@property (strong,nonatomic,readonly) NSString *identifier;
@property (strong,nonatomic) id observer;
@property (strong,nonatomic) NSString *observerKeyPath;
@property (strong,nonatomic) id observed;
@property (strong,nonatomic) NSString *observedKeyPath;
@property (strong,nonatomic) NSDictionary *options;
@end


// Binding block
typedef void(^OCBindingBlock)(id value);

// Block-based binding
@interface OCBlockBinding : OCBinding
@property (strong,nonatomic) OCBindingBlock block;
@end


// Notification-based binding
@interface OCNotificationBinding : OCBlockBinding
@property (strong,nonatomic) NSString *notificationName;
@end


// Binding manager
@interface OCBindingsManager : NSObject

+ (OCBindingsManager *)sharedManager;

- (NSString *)addBinding:(OCBinding *)binding;

- (void)removeBindingWithIdentifier:(NSString *)identifier;
- (void)removeAllBindingsForObject:(id)object keyPath:(NSString *)keyPath;
- (void)removeAllBindingsForObject:(id)object;

- (void)removeAllBindingsForNotification:(NSString *)notificationName;

@end

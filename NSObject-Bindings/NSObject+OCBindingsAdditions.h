//
//  NSObject+OCBindingsAdditions.h
//
//  Created by Olivier Collet on 12-03-09.
//  Copyright (c) 2012 Olivier Collet. All rights reserved.
//

#import <Foundation/Foundation.h>


/*	WARNING: Make sure you remove all the bindings on any object before releasing it.
 *			 This implementation retains all the objects being observed, as well as
 *			 the ones being notified of changes.
 */

@interface NSObject (OCBindingsAdditions)

/**
 The receiver's value at toKeyPath is updated whenever the object's value at fromKeyPath changes.

 @param 	toKeyPath	The key path, relative to the receive, of the property to be updated
 @param 	object		The object to observe
 @param 	fromKeyPath	The key path, relative to object, of the property to observe
 @param		options		*Not used*
 
 @return 	A unique identifier
 */
- (NSString *)bindKeyPath:(NSString *)toKeyPath toObject:(id)object withKeyPath:(NSString *)fromKeyPath options:(NSDictionary *)options;


/**
 Removes a binding on the receiver's keyPath 

 @param 	keyPath		The key path, relative to the receiver, of the value to stop observing or being observed
 */
- (void)unbindKeyPath:(NSString *)binding;

/**
 Removes all bindings with the receiver, whether it is observed or observing.
 */
- (void)unbind;

/** 
 The block is executed whenever the object's value at keyPath changes.

 @param 	block		A block to be executed whenever the object's value at keyPath changes
 @param 	object		The object to observe
 @param 	keyPath		The key path, relative to object, of the property to observe
 @param		options		*Not used*

 @return 	A unique identifier
 */
+ (NSString *)bindBlock:(void (^)(id value))block toObject:(id)object withKeyPath:(NSString *)keyPath options:(NSDictionary *)options;

/** 
 The block is executed whenever the notification is sent
 
 @param 	block				A block to be executed whenever the notification is posted
 @param 	notificationName	The notification to observe
 @param		options				*Not used*

 @return	A unique identifier
 */
+ (NSString *)bindBlock:(void (^)(id notification))block toNotification:(NSString *)notificationName options:(NSDictionary *)options;


/** 
 Remove a specific binding with its identifier.
 
 @param 	identifier	A unique binding identifier returned by any method used to create a binding
 */
+ (void)unbindBindingWithIdentifier:(NSString *)bindingIdentifier;

@end

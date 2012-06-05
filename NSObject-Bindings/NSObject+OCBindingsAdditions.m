//
//  NSObject+OCBindingsAdditions.m
//
//  Created by Olivier Collet on 12-03-09.
//  Copyright (c) 2012 Olivier Collet. All rights reserved.
//

#import "NSObject+OCBindingsAdditions.h"
#import "OCBindingsManager.h"

@implementation NSObject (OCBindingsAdditions)

- (NSString *)bindKeyPath:(NSString *)toKeyPath toObject:(id)object withKeyPath:(NSString *)fromKeyPath options:(NSDictionary *)options {
	NSAssert([self respondsToSelector:NSSelectorFromString(toKeyPath)], @"\n\nBINDING: Binding an inexistent keyPath: '%@' on object: %@\n\n", toKeyPath, self);
	NSAssert([object respondsToSelector:NSSelectorFromString(fromKeyPath)], @"\n\nBINDING: Binding to inexistent keyPath: '%@' on object: %@\n\n", fromKeyPath, object);

	OCBinding *bindingInfo = [OCBinding new];
	[bindingInfo setObserver:self];
	[bindingInfo setObserverKeyPath:toKeyPath];
	[bindingInfo setObserved:object];
	[bindingInfo setObservedKeyPath:fromKeyPath];
	[bindingInfo setOptions:options];
	
	return [[OCBindingsManager sharedManager] addBinding:bindingInfo];
}

- (void)unbindKeyPath:(NSString *)binding {
	[[OCBindingsManager sharedManager] removeAllBindingsForObject:self keyPath:binding];
}

- (void)unbind {
	[[OCBindingsManager sharedManager] removeAllBindingsForObject:self];
}

+ (void)unbindBindingWithUUID:(NSString *)bindingUUID {
	[[OCBindingsManager sharedManager] removeBindingWithIdentifier:bindingUUID];
}

+ (void)unbindBindingWithIdentifier:(NSString *)bindingIdentifier {
	[[OCBindingsManager sharedManager] removeBindingWithIdentifier:bindingIdentifier];
}

+ (void)unbindBindingsWithIdentifier:(NSString *)identifier {
	[[OCBindingsManager sharedManager] removeAllBindingsWithIdentifier:identifier];
}

#pragma mark - Block-based bindings

+ (NSString *)bindBlock:(void (^)(id value))block toObject:(id)object withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	NSAssert([object respondsToSelector:NSSelectorFromString(keyPath)], @"\n\nBINDING: Binding to inexistent keyPath: '%@' on object: %@\n\n", keyPath, object);
	NSAssert(block, @"\n\nBINDING: Binding a nil block. %@\n\n");

	OCBlockBinding *binding = [OCBlockBinding new];
	[binding setObserved:object];
	[binding setObservedKeyPath:keyPath];
	[binding setBlock:block];
	[binding setOptions:options];
	
	return [[OCBindingsManager sharedManager] addBinding:binding];
}

#pragma mark - Notification-based bindings

+ (NSString *)bindBlock:(void (^)(id notification))block toNotification:(NSString *)notificationName options:(NSDictionary *)options {
	NSAssert(notificationName, @"\n\nBINDING: Binding to an inexistent notification. %@\n\n");
	NSAssert(block, @"\n\nBINDING: Binding a nil block. %@\n\n");

	OCNotificationBinding *binding = [OCNotificationBinding new];
	[binding setNotificationName:notificationName];
	[binding setBlock:block];
	[binding setOptions:options];
	
	return [[OCBindingsManager sharedManager] addBinding:binding];
}

@end

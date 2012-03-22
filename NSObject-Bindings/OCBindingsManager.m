//
//  OCBindingsManager.m
//  iOSBindingsLab
//
//  Created by Olivier Collet on 12-03-09.
//  Copyright (c) 2012 Olivier Collet. All rights reserved.
//

#import "OCBindingsManager.h"

@interface OCBinding ()
@property (strong,nonatomic,readwrite) NSString *identifier;
@end

//

@interface OCBindingsManager ()
@property (strong, nonatomic) NSMutableArray *bindings;
@property (strong, nonatomic) NSMutableArray *notificationBindings;
@end

//

@implementation OCBindingsManager
@synthesize bindings = _bindings;
@synthesize notificationBindings = _notificationBindings;

+ (OCBindingsManager *)sharedManager {
	static OCBindingsManager *sharedManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [OCBindingsManager new];
	});
	return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setBindings:[NSMutableArray array]];
		[self setNotificationBindings:[NSMutableArray array]];
    }
    return self;
}

#pragma mark - Find bindings

- (NSArray *)bindingsForKeyPath:(NSString *)keyPath ofObservedObject:(id)object {
	NSMutableArray *bindings = [NSMutableArray array];
	for (OCBinding *binding in self.bindings) {
		if ((binding.observed == object) && [binding.observedKeyPath isEqualToString:keyPath]) {
			[bindings addObject:binding];
		}
	}
	return bindings;
}

- (OCBinding *)bindingWithIdentifier:(NSString *)identifier {
	NSArray *allBindings = [self.bindings arrayByAddingObjectsFromArray:self.notificationBindings];
	for (OCBinding *binding in allBindings) {
		if ([binding.identifier isEqualToString:identifier]) {
			return binding;
		}
	}
	return nil;
}

#pragma mark - Public methods

- (NSString *)addBinding:(OCBinding *)binding {
	// Notification binding
	if ([binding isKindOfClass:[OCNotificationBinding class]]) {
		[self addNotificationBinding:(OCNotificationBinding *)binding];
	}
	// KVO binding
	else {
		[self.bindings addObject:binding];
		[binding.observed addObserver:self forKeyPath:binding.observedKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}

	// Set a UUDI to the binding
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	[binding setIdentifier:UUIDString];

	// Return the binding
	return UUIDString;
}

- (void)removeAllBindingsForObject:(id)object keyPath:(NSString *)keyPath {
	NSArray *bindings = [self bindingsForKeyPath:keyPath ofObservedObject:object];
	NSMutableArray *toRemove = [NSMutableArray array];
	for (OCBinding *binding in bindings) {
		if (((binding.observer == object) && [binding.observerKeyPath isEqualToString:keyPath]) ||
			((binding.observed == object) && [binding.observedKeyPath isEqualToString:keyPath])) {
			[binding.observed removeObserver:self forKeyPath:binding.observedKeyPath];
			[toRemove addObject:binding];
		}
	}
	[self.bindings removeObjectsInArray:toRemove];
}

- (void)removeAllBindingsForObject:(id)object {
	NSMutableArray *toRemove = [NSMutableArray array];
	for (OCBinding *binding in self.bindings) {
		if ((binding.observed == object) || (binding.observer == object)) {
			[binding.observed removeObserver:self forKeyPath:binding.observedKeyPath];
			[toRemove addObject:binding];
			continue;
		}
	}
	[self.bindings removeObjectsInArray:toRemove];
}

- (void)removeBindingWithIdentifier:(NSString *)identifier {

	// KVO binding
	for (OCBinding *binding in self.bindings) {
		if ([binding.identifier isEqualToString:identifier]) {
			[self.bindings removeObject:binding];
			return;
		}
	}

	// Notification binding
	for (OCNotificationBinding *binding in self.notificationBindings) {
		if ([binding.identifier isEqualToString:identifier]) {
			[[NSNotificationCenter defaultCenter] removeObserver:self name:binding.notificationName object:nil];
			[self.notificationBindings removeObject:binding];
			return;
		}
	}
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSArray *bindings = [self bindingsForKeyPath:keyPath ofObservedObject:object];
	for (OCBinding *binding in bindings) {
		// Block-based binding
		if ([binding isKindOfClass:[OCBlockBinding class]] && [(OCBlockBinding *)binding block]) {
			((OCBlockBinding *)binding).block([object valueForKeyPath:keyPath]);
		}
		else {
			[binding.observer setValue:[object valueForKeyPath:keyPath] forKeyPath:binding.observerKeyPath];
		}
	}
}

#pragma mark - Notifications

- (void)addNotificationBinding:(OCNotificationBinding *)binding {
	NSAssert(binding.notificationName, @"\n\nBINDING: Binding to an inexistent notification. %@\n\n");
	[self.notificationBindings addObject:binding];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeNotification:) name:binding.notificationName object:nil];
}

- (void)removeAllBindingsForNotification:(NSString *)notificationName {
	NSMutableArray *toRemove = [NSMutableArray array];
	for (OCNotificationBinding *binding in self.notificationBindings) {
		if ([binding.notificationName isEqualToString:notificationName]) {
			[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
			[toRemove addObject:binding];
		}
	}
	[self.bindings removeObjectsInArray:toRemove];
}

- (void)observeNotification:(NSNotification *)notification {
	for (OCNotificationBinding *binding in self.notificationBindings) {
		if ([binding.notificationName isEqualToString:notification.name] && binding.block) {
			binding.block(notification);
		}
	}
}

@end


#pragma mark -
#pragma mark - OCBinding

@implementation OCBinding
@synthesize identifier;
@synthesize observer;
@synthesize observerKeyPath;
@synthesize observed;
@synthesize observedKeyPath;
@synthesize options;

@end


#pragma mark -
#pragma mark - OCBlockBinding

@implementation OCBlockBinding
@synthesize block;

@end


#pragma mark -
#pragma mark - OCNotificationBinding

@implementation OCNotificationBinding
@synthesize notificationName;

@end
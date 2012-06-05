# NSObject Bindings Additions

These methods on NSObject simplify KVO coding.



## Usage

You can see the sample project in the _Demo_ folder.

**WARNING:** Make sure to remove all the bindings on any object before releasing it. This implementation retains all the objects being observed, as well as the ones being notified of changes.



### Key path bindings

#### bindKeyPath:toObject:withKeyPath:options:

The `options` parameter is not used, just set it to `nil`. Support will be added later.  
Returns a unique identifier that can be used to remove the binding.

Creates a binding that updates the `text` property on `label` every time the property `title` of `blogPost` changes.

	[label bindKeyPath:@"text" toObject:blogPost withKeyPath:@"title" options:nil];



### Block-based bindings

#### bindBlock:toObject:withKeyPath:options:

The `options` parameter is not used, just set it to `nil`. Support will be added later.  
Returns a unique identifier that can be used to remove the binding.

Executes the block every time the property `title` of `blogPost` changes. The value is the only parameter sent to the block.

	[NSObject bindBlock:^(id value) {
		NSLog(@"Value: %@", value);
	} toObject:blogPost withKeyPath:@"title" options:nil];

_Note: This can be useful to log and debug values._



### Notification bindings

#### bindBlock:toNotification:options:

The `options` parameter is not used, just set it to `nil`. Support will be added later.  
Returns a unique identifier that can be used to remove the binding.

Executes the block every time the notification is posted.

**Warning:** Make sure you keep the binding's identifier returned by the method so that you can remove the binding later.

	notificationBindingIdentifier = [NSObject bindBlock:^(id notification) {
		NSLog(@"App did become active");
	} toNotification:UIApplicationDidBecomeActiveNotification options:nil];



### Removing bindings


#### unbindKeyPath:

Removes all the bindings on the `text` property of `label`.

	[label unbindKeyPath:@"text"];


#### unbind

Removes all the bindings on `blogPost`.

	[blogPost unbind];


#### unbindBindingWithUUID:

Removes the binding with a unique identifier

	[NSObject unbindBindingWithUUID:notificationBindingIdentifier];


#### unbindBindingsWithIdentifier:

Removes all the bindings that have `@"MyIdentifier"` as the value for the `OCBindingIdentifierOptionKey` option key. See **Options** for more information.

	[NSObject unbindBindingsWithIdentifier:@"MyIdentifier"];




## Options

When creating a binding you can use the following keys to set options in the `options` dictionary.

### OCBindingIdentifierOptionKey

A NSString that you can use to remove bindings with `unbindBindingsWithIdentifier:`.

## Important

The code is taking advantage of Automatic Reference Counting (ARC). If your project does not use ARC, you will need to update the code. If you do so, please do it nicely, fork the project and send a pull request.

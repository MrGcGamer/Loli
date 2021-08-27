#import "LoliSubPrefsListController.h"
#import "GcUniversal/GcColorPickerUtils.h"

@implementation LoliSubPrefsListController

- (id)specifiers {
	return _specifiers;
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
	NSString *sub = [specifier propertyForKey:@"Sub"];
	NSString *title = [specifier name];

	_specifiers = [self loadSpecifiersFromPlistName:sub target:self];

	[self setTitle:title];
	[self.navigationItem setTitle:title];
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (bool)shouldReloadSpecifiersOnResume {
	return false;
}

- (void)viewWillAppear:(BOOL)_ {
	[super viewWillAppear:_];

	[[[[self parentViewController] view] window] setTintColor:[GcColorPickerUtils colorWithHex:@"F728B2"]];
}

- (void)viewWillDisappear:(BOOL)_ {
	[super viewWillDisappear:_];

	[[[self view] window] setTintColor:nil];
}

@end
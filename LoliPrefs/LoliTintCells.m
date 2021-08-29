@import UIKit;
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>
#import "GcUniversal/GcColorPickerUtils.h"

@interface PSTableCell ()
- (void)setTitle:(NSString *)_ ;
@end

@interface LoliButtonCell : PSTableCell
@end
@interface LoliSwitchCell : PSSwitchTableCell
@end

#define tintColor [GcColorPickerUtils colorWithHex:@"F728B2"]

@implementation LoliButtonCell
- (void)setTitle:(NSString *)_ {
	[super setTitle:_];
	UILabel *title = [self titleLabel];
	[title setTextColor:tintColor];
}
@end

@implementation LoliSwitchCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
	if (self)
		[((UISwitch *) [self control]) setOnTintColor:tintColor];
	return self;
}
@end
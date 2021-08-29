@import UIKit;
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface LoliRootListController : PSListController {
	UITableView * _table;
}
@property (nonatomic, retain) UIImageView *headerView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
@end

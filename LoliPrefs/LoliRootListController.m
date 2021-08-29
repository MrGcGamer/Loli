#import "LoliRootListController.h"
#import "GcUniversal/HelperFunctions.h"
#import "GcUniversal/GcColorPickerUtils.h"

#define iconPath(icon) [NSString stringWithFormat:@"%@/%@",[[self bundle] bundlePath],icon]

@implementation LoliRootListController

- (instancetype)init {
	self = [super init];

	if (self) {
		self.navigationItem.titleView = [UIView new];
		self.titleLabel = [UILabel new];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		self.titleLabel.text = @"Loli";
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		[self.navigationItem.titleView addSubview:self.titleLabel];

		self.iconView = [UIImageView new];
		self.iconView.contentMode = UIViewContentModeScaleAspectFit;
		self.iconView.image = [UIImage imageWithContentsOfFile:iconPath(@"Icons/icon@2x.png")];
		self.iconView.alpha = 0.0;
		[self.navigationItem.titleView addSubview:self.iconView];

		[self.titleLabel anchorEqualsToView:self.navigationItem.titleView padding:UIEdgeInsetsZero];
		[self.iconView anchorEqualsToView:self.navigationItem.titleView padding:UIEdgeInsetsZero];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)_ {
	[super viewWillAppear:_];

	[[[[self parentViewController] view] window] setTintColor:[GcColorPickerUtils colorWithHex:@"F728B2"]];
}

- (void)viewWillDisappear:(BOOL)_ {
	[super viewWillDisappear:_];

	[[[self view] window] setTintColor:nil];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
	self.headerView.clipsToBounds = YES;
	self.headerView.contentMode = UIViewContentModeScaleAspectFill;
	self.headerView.image = [UIImage imageWithContentsOfFile:iconPath(@"Icons/Banner.png")];

	_table.tableHeaderView = self.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.tableHeaderView = self.headerView;
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	BOOL replace = (scrollView.contentOffset.y >= 200);
	if (self.iconView.alpha == replace) return;
	[UIView animateWithDuration:0.2 animations:^{
		self.iconView.alpha = replace;
		self.titleLabel.alpha = !replace;
	}];
}

@end

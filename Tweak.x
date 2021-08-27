#import "Tweak.h"

const CGFloat playerHeight = 70;
const CGFloat imageRadius = 25;
const CGSize imageSize = {50,50};

NSUserDefaults *prefs;
UIImageView *artworkBackground;
__weak MTMaterialView *materialBackground;
NSArray *cachedColors;
NSData *tempData;

@interface LoliWrapper : NSObject
@property (nonatomic, retain) UIColor *titleColor;
@property (nonatomic, retain) UIColor *subtitleColor;
@property (nonatomic, retain) UIColor *background;
@end

@implementation LoliWrapper
-(void)setBackground:(UIColor *)arg1 {
	_background = arg1;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Loli-updateColor" object:nil];
	NSLog(@"Loli - Notif");
}
@end

LoliWrapper *loliWrapper;

%hook SBMediaController
- (void)setNowPlayingInfo:(id)arg1 {
	%orig;

	if ([prefs integerForKey:@"ArtBackground"] == 0)
		return;

	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
		if (result) {
			NSDictionary *dict = (__bridge NSDictionary *)result;
			NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
			if (artworkData != nil && artworkData != tempData) {
				UIImage *img = [UIImage imageWithData:artworkData];

				BOOL isSpotify = [[self nowPlayingApplication].bundleIdentifier isEqualToString:@"com.spotify.client"];
				BOOL dont = NO;
				NSLog(@"Loli - %f",img.size.width);
				if (isSpotify) {
					if (artworkData.length == 0x282e && img.size.width == 0x258) {
						if (!cachedColors)
							cachedColors = [img dominantColors];
						dont = YES;
					}
					// else if (img.size.width <= 0xc8)
					// 	return;
				}

				NSArray *dominantColors = (dont) ? cachedColors : [img dominantColors];

				NSInteger count = dominantColors.count;

				BOOL isDark = [[dominantColors lastObject] isDarkColor];

				loliWrapper.subtitleColor = (count >= 3) ? dominantColors[2] : (isDark) ? [UIColor whiteColor] : [UIColor blackColor];
				loliWrapper.titleColor = (count >= 2) ? dominantColors[1] : (isDark) ? [UIColor whiteColor] : [UIColor blackColor];
				loliWrapper.background = (count >= 1) ? dominantColors[0] : [UIColor clearColor];

				tempData = artworkData;
			}
		} else {
			loliWrapper.background = nil;
			loliWrapper.titleColor = loliWrapper.subtitleColor = [UIColor whiteColor];
			tempData = nil;
			cachedColors = nil;
		}
	});
}
%end

%hook CSAdjunctItemView
- (void)_updateSizeToMimic{
	%orig;

	[self.heightAnchor constraintEqualToConstant:playerHeight].active = true;
	self.layer.cornerRadius = self.frame.size.height / 2;
	self.layer.cornerCurve = kCACornerCurveContinuous;
}
%end


%hook MRUArtworkView
- (void)setIconImage:(UIImage *)arg1 { // NO mini icon
		UIViewController *controller = [self _viewControllerForAncestor];
		%orig(([controller isKindOfClass:objc_getClass("MRUNowPlayingViewController")] && [controller.parentViewController isKindOfClass:objc_getClass("MRUCoverSheetViewController")]) ? nil : arg1);
}
- (void)setFrame:(CGRect)frame { // move it
	UIViewController *controller = [self _viewControllerForAncestor];

	if ([controller isKindOfClass:objc_getClass("MRUNowPlayingViewController")] && [controller.parentViewController isKindOfClass:objc_getClass("MRUCoverSheetViewController")]) {
		%orig((CGRect){{-6, -6}, imageSize});
		self.layer.cornerRadius = imageRadius;
		[self setClipsToBounds:YES];
	} else
		%orig;
}
- (void)setArtworkImage:(UIImage *)arg1 {
	%orig;
	UIViewController *controller = [self _viewControllerForAncestor];

	if ([controller isKindOfClass:objc_getClass("MRUNowPlayingViewController")] && [controller.parentViewController isKindOfClass:objc_getClass("MRUCoverSheetViewController")]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColor:) name:@"Loli-updateColor" object:nil];
		NSInteger artBg = [prefs integerForKey:@"ArtBackground"];
		if (artBg == 1) {
			if (!artworkBackground) {

				// Super hacky but I do not care
				UIView *platterView;
				UIView *tempView = self;
				Class class = objc_getClass("PLPlatterCustomContentView");
				do {
					tempView = tempView.superview;
					if ([tempView isKindOfClass:class])
						platterView = tempView;
				} while (tempView.superview && !platterView);

				if (!platterView)
					return;

				artworkBackground = [UIImageView new];

				[platterView.superview insertSubview:artworkBackground atIndex:0];

				MTMaterialView *materialView = (MTMaterialView *)platterView.superview.subviews[1];
				materialView.recipe = 4;

				[artworkBackground anchorEqualsToView:platterView padding:UIEdgeInsetsZero];
			}
			artworkBackground.image = arg1;
		} else {
			if (artworkBackground) {
				MTMaterialView *materialView = (MTMaterialView *)artworkBackground.superview.subviews[1];
				materialView.recipe = 1;
				[artworkBackground removeFromSuperview];
				artworkBackground = nil;
			}
			if (artBg == 2) {
				if (!materialBackground) {
					// Super hacky but I do not care
					UIView *platterView;
					UIView *tempView = self;
					Class class = objc_getClass("PLPlatterCustomContentView");
					do {
						tempView = tempView.superview;
						if ([tempView isKindOfClass:class])
							platterView = tempView;
					} while (tempView.superview && !platterView);

					if (!platterView)
						return;

					materialBackground = (MTMaterialView *)platterView.superview.subviews[1];
				}
				[UIView animateWithDuration:.2 animations:^{
					materialBackground.backgroundColor = loliWrapper.background;
					[self setNeedsDisplay];
				}];
			}
		}
	}
}
%new
- (void)updateColor:(NSNotification *)_ {
	NSLog(@"Loli - thingy - 1");
	[UIView animateWithDuration:.2 animations:^{
		materialBackground.backgroundColor = loliWrapper.background;
		[self setNeedsDisplay];
	}];
}
%end

%hook MRUNowPlayingHeaderView
-(void)setShowRoutingButton:(BOOL)arg1 {
	%orig((self.context == 2) ? NO : arg1);
}
%end
%hook MRUNowPlayingLabelView
- (void)setContext:(long long)context {
	%orig;
	if (context == 2) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColor:) name:@"Loli-updateColor" object:nil];
		self.routeLabel.hidden = YES;
	}
}
- (void)setFrame:(CGRect)frame {
	if (self.context == 2) {
		CGFloat height = frame.size.height;

		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.heightAnchor constraintEqualToConstant:height].active = YES;
		[self.centerYAnchor constraintEqualToAnchor:self.superview.subviews[0].centerYAnchor].active = YES;
		[self.leadingAnchor constraintEqualToAnchor:self.superview.subviews[0].trailingAnchor constant:10].active = YES;
		[self.trailingAnchor constraintEqualToAnchor:self.superview.superview.subviews[2].leadingAnchor].active = YES;
	} else
		%orig;
}
- (void)setShowPlaceholderText:(BOOL)arg1 {
	%orig;
	if ([prefs integerForKey:@"ArtBackground"] == 0)
		return;
	if (self.context == 2)
		[UIView animateWithDuration:.2 animations:^{
			[self.titleLabel setTextColor:loliWrapper.titleColor];
			[self.subtitleLabel setTextColor:loliWrapper.subtitleColor];
			[self setNeedsDisplay];
		}];
}
%new
- (void)updateColor:(NSNotification *)_ {
	if ([prefs integerForKey:@"ArtBackground"] == 0)
		return;
	NSLog(@"Loli - thingy - 2");
	[UIView animateWithDuration:.2 animations:^{
		[self.titleLabel setTextColor:loliWrapper.titleColor];
		[self.subtitleLabel setTextColor:loliWrapper.subtitleColor];
		[self setNeedsDisplay];
	}];
}
%end

%hook MRUNowPlayingTransportControlsView
- (void)setFrame:(CGRect)frame{
	MRUNowPlayingViewController *controller = (MRUNowPlayingViewController *)[self _viewControllerForAncestor];
	if ([controller respondsToSelector:@selector(context)] && controller.context == 2) {
		[self setLayout:0];
		CGFloat height = 34;
		CGFloat width = 110;

		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.widthAnchor constraintEqualToConstant:width].active = YES;
		[self.heightAnchor constraintEqualToConstant:height].active = YES;
		[self.centerYAnchor constraintEqualToAnchor:((MRUNowPlayingViewController *) [self.superview.superview _viewControllerForAncestor]).artworkView.centerYAnchor].active = YES;
		[self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor].active = YES;
	} else
		%orig;
}
- (void)setStylingProvider:(id)_ {
	if ([prefs integerForKey:@"ArtBackground"] == 0)
		return %orig;
	MRUNowPlayingViewController *controller = (MRUNowPlayingViewController *)[self _viewControllerForAncestor];
	if (![controller respondsToSelector:@selector(context)] || controller.context != 2)
		%orig;
}
%end
%hook MRUNowPlayingView
- (void)setContext:(NSInteger)context {
	%orig;
	if (context == 2) {
		if (@available(iOS 14.2, *)) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColor:) name:@"Loli-updateColor" object:nil];
			if ([prefs integerForKey:@"ArtBackground"] == 0)
				return;
			UIView *controlsView = [self valueForKey:@"controlsView"];
			UIView *transportView = [controlsView valueForKey:@"transportControlsView"];

			for (UIButton *button in transportView.subviews) {
				if (![button isKindOfClass:objc_getClass("UIButton")])
					continue;
				[button.imageView _setInteractionTintColor:loliWrapper.subtitleColor];
			}
			[self setNeedsDisplay];
		}
	}
}
%new
- (void)updateColor:(NSNotification *)notif {
	if ([prefs integerForKey:@"ArtBackground"] == 0)
		return;
	NSLog(@"Loli - thingy - 3");
	if (@available(iOS 14.2, *)) {
		UIView *controlsView = [self valueForKey:@"controlsView"];
		UIView *transportView = [controlsView valueForKey:@"transportControlsView"];

		for (UIButton *button in transportView.subviews) {
			if (![button isKindOfClass:objc_getClass("UIButton")])
				continue;
			[UIView animateWithDuration:.2 animations:^{
				[button.imageView _setInteractionTintColor:loliWrapper.subtitleColor];
			}];
			[self setNeedsDisplay];
		}
	}
}
%end

%ctor {
	prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.mrgcgamer.loliprefs"];
	loliWrapper = [[LoliWrapper alloc] init];
	loliWrapper.titleColor = loliWrapper.subtitleColor = [UIColor whiteColor];
}
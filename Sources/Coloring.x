#import "Headers/Tweak.h"

UIImageView *artworkBackground;
MTMaterialView *materialBackground;
NSArray *cachedColors;
UIImage *lastImage;
UIImage *tempImage;

@interface LoliWrapper : NSObject
@property (nonatomic, retain) UIColor *titleColor;
@property (nonatomic, retain) UIColor *subtitleColor;
@property (nonatomic, retain) UIColor *background;
@end

@implementation LoliWrapper
@end

LoliWrapper *loliWrapper;

%group coloring
%hook MRUArtworkView
- (void)setArtworkImage:(UIImage *)arg1 {
	MRUNowPlayingViewController *controller = (MRUNowPlayingViewController *) [self _viewControllerForAncestor];
	if(![controller respondsToSelector:@selector(context)] || controller.context != 2)
		return %orig;

	if (arg1 && arg1 != lastImage)
		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
			if (result) {
				NSDictionary *dict = (__bridge NSDictionary *)result;
				NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
				if (artworkData != nil) {
					tempImage = [UIImage imageWithData:artworkData];
					%orig(tempImage);

					BOOL dont = NO;
					if (artworkData.length == 0x282e && tempImage.size.width == 0x258) {
						if (!cachedColors)
							cachedColors = [tempImage dominantColors];
						dont = YES;
					}

					NSArray *dominantColors = (dont) ? cachedColors : [tempImage dominantColors];

					NSInteger count = dominantColors.count;

					BOOL isDark = [[dominantColors lastObject] isDarkColor];

					loliWrapper.subtitleColor = (count >= 3) ? dominantColors[2] : (isDark) ? [UIColor whiteColor] : [UIColor blackColor];
					loliWrapper.titleColor = (count >= 2) ? dominantColors[1] : (isDark) ? [UIColor whiteColor] : [UIColor blackColor];
					loliWrapper.background = (count >= 1) ? dominantColors[0] : [UIColor clearColor];

				}
			} else {
				%orig;
				loliWrapper.background = [UIColor clearColor];
				loliWrapper.titleColor = loliWrapper.subtitleColor = [UIColor whiteColor];
				cachedColors = nil;
			}
			[self updateBackground];
		});
	else {
		tempImage = arg1;
		%orig;
	}
	lastImage = arg1;
	[self updateBackground];
}
%new
- (void)updateBackground {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Loli-update" object:nil];
	NSInteger artBg = [prefs integerForKey:@"ArtBackground"];
	UIView *platterView = [self getPlatter];

	if (!platterView)
		return;

	materialBackground = platterView.superview.subviews[1];

	if (artBg == 1) {
		if (!artworkBackground) {

			artworkBackground = [UIImageView new];

			[platterView.superview insertSubview:artworkBackground atIndex:0];

			materialBackground.recipe = 4;

			[artworkBackground anchorEqualsToView:platterView padding:UIEdgeInsetsZero];
		}
		materialBackground.backgroundColor = [UIColor clearColor];
		artworkBackground.image = tempImage;
	} else {
		if (artworkBackground) {
			MTMaterialView *materialView = (materialBackground) ?: (MTMaterialView *)artworkBackground.superview.subviews[1];
			materialView.recipe = 1;
			[artworkBackground removeFromSuperview];
			artworkBackground = nil;
		}
		if (artBg == 2) {
			[UIView animateWithDuration:.2 animations:^{
				materialBackground.backgroundColor = loliWrapper.background;
			}];
		} else {
			if (materialBackground)
				materialBackground.backgroundColor = [UIColor clearColor];
		}
	}
}
%new
- (UIView *)getPlatter { // Super hacky but I do not care
	UIView *platterView;
	UIView *tempView = self;
	Class class = objc_getClass("PLPlatterCustomContentView");
	do {
		tempView = tempView.superview;
		if ([tempView isKindOfClass:class])
			platterView = tempView;
	} while (tempView.superview && !platterView);
	return platterView;
}
%end

%hook MRUNowPlayingLabelView
- (void)setContext:(NSInteger)context {
	%orig;
	if (context == 2)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVisualStyling) name:@"Loli-update" object:nil];
}
- (void)updateVisualStyling {
	%orig;
	if (![prefs boolForKey:@"ShouldColorButtons"] || !lastImage)
		return;
	if (self.context == 2)
		[UIView animateWithDuration:.2 animations:^{
			[self.titleLabel setTextColor:loliWrapper.titleColor];
			[self.subtitleLabel setTextColor:loliWrapper.subtitleColor];
		}];
}
%end

%hook MRUTransportButton
- (void)updateVisualStyling {
	%orig;
	if (![prefs boolForKey:@"ShouldColorButtons"] || !lastImage)
		return;

	MRUNowPlayingViewController *controller = (MRUNowPlayingViewController *)[self.superview _viewControllerForAncestor];
	if ([controller respondsToSelector:@selector(context)] && controller.context == 2) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"Loli-update" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVisualStyling) name:@"Loli-update" object:nil];
		[self.imageView setTintColor:loliWrapper.subtitleColor];
	}
}
%end
%end

extern void InitColoring() {
	loliWrapper = [[LoliWrapper alloc] init];
	loliWrapper.titleColor = loliWrapper.subtitleColor = [UIColor whiteColor];
	%init(coloring);
}
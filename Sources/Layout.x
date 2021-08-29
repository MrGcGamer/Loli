#import "Headers/Tweak.h"

const CGFloat playerHeight = 70;
const CGFloat imageRadius = 25;
const CGSize imageSize = {50,50};

%group layout
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
%end

%hook MRUNowPlayingHeaderView
-(void)setShowRoutingButton:(BOOL)arg1 {
	%orig((self.context == 2) ? NO : arg1);
}
%end

%hook MRUNowPlayingLabelView
- (void)setContext:(long long)context {
	%orig;
	if (context == 2)
		self.routeLabel.hidden = YES;
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
%end
%end

extern void InitLayout() {
  %init(layout);
}
@import UIKit;
#import "GcUniversal/HelperFunctions.h"
#import "GcUniversal/GcImageUtils.h"
#import "GcUniversal/GcColorUtils.h"
#import "MediaRemote.h"
#import "LibSymbolize.h"

@interface UIView ()
@property (nonatomic,retain) UIColor * interactionTintColor;
- (UIViewController *)_viewControllerForAncestor;
-(void)_setInteractionTintColor:(id)arg1 ;
@end

@interface CSAdjunctItemView : UIView
@end

@interface MRUArtworkView : UIView
@property (retain, nonatomic) UIImageView *artworkImageView;
@end

@interface MRUNowPlayingView : UIView
@property (nonatomic, assign) NSInteger context;
@end
@interface MRUNowPlayingHeaderView : UIView
@property (nonatomic, assign) NSInteger context;
@end
@interface MRUNowPlayingLabelView : UIView
@property (retain, nonatomic) UILabel *routeLabel;
@property (nonatomic, assign) NSInteger context;
@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UILabel * subtitleLabel;
@end
@interface MRUNowPlayingViewController : UIViewController
@property (nonatomic,readonly) UIImageView * artworkView;
@property (nonatomic, assign) NSInteger context;
@end
@interface MRUNowPlayingTransportControlsView : UIView
@property (assign,nonatomic) long long layout;
@end

@interface MTMaterialView : UIView
@property (assign,nonatomic) long long recipe;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;
@end

@interface SBMediaController : NSObject
@property (nonatomic,readonly) SBApplication * nowPlayingApplication;
@end
#import "GcUniversal/HelperFunctions.h"
#import "GcUniversal/GcImageUtils.h"
#import "GcUniversal/GcColorUtils.h"
#import "MediaRemote/MediaRemote.h"
#import "Headers/Loader.h"
#import "Headers/Base.h"

@interface UIView ()
@property (nonatomic,retain) UIColor * interactionTintColor;
- (UIViewController *)_viewControllerForAncestor;
@end

@interface CSAdjunctItemView : UIView
@end

@interface MRUArtworkView : UIView
@property (retain, nonatomic) UIImageView *artworkImageView;

// NEW
- (void)updateBackground ;
- (UIView *)getPlatter ;
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
@interface MRUTransportButton : UIButton
- (void)updateVisualStyling ;
@end

@interface MTMaterialView : UIView
@property (assign,nonatomic) long long recipe;
@end

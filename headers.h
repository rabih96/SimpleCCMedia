//
//	All tha headers needed !!!
//

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (id)artwork;
- (id)nowPlayingApplication;
- (id)nowPlayingArtist;
- (id)nowPlayingTitle;
- (id)nowPlayingAlbum;
- (_Bool)isPlaying;
- (_Bool)isPaused;
@end

@interface SBUIControlCenterSlider : UISlider
@end

@interface SBBrightnessController : NSObject
+ (id)sharedBrightnessController;
- (void)setBrightnessLevel:(float)arg1;
@end

@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (void)setMediaVolume:(float)arg1;
@end

@interface SBControlCenterSectionViewController : UIViewController {
}
+ (Class)viewClass;
- (void)controlCenterDidFinishTransition;
- (void)controlCenterWillBeginTransition;
- (void)controlCenterDidDismiss;
- (void)controlCenterWillPresent;
- (void)noteSettingsDidUpdate:(id)noteSettings;
- (CGSize)contentSizeForOrientation:(int)orientation;
- (BOOL)enabledForOrientation:(int)orientation;
- (id)view;
- (void)loadView;
@end

@interface SBControlCenterContentView : UIView {
}
@property(retain, nonatomic) SBControlCenterSectionViewController *mediaControlsSection;
@property(retain, nonatomic) SBControlCenterSectionViewController *brightnessSection;
- (void)layoutSubviews;
@end

@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (id)displayName;
- (id)defaultDisplayName;
- (void)setDisplayName:(id)arg1;
- (void)setDefaultDisplayName:(id)arg1;
- (id)articonLabelName;
- (id)bundle;
@end

@interface SBApplicationController: NSObject
+ (instancetype)sharedInstance;
-(id)applicationWithDisplayIdentifier:(id)arg1 ;
@end

@interface SpringBoard
-(id)nowPlayingApp;
-(int)nowPlayingProcessPID;
@end

@protocol MPUSystemMediaControlsDelegate <NSObject>
@optional
- (void)systemMediaControlsViewController:(id)controller didTapOnTrackInformationView:(id)view;
- (void)systemMediaControlsViewController:(id)controller didReceiveTapOnControlType:(int)type;
@end

@interface MPUSystemMediaControlsViewController : UIViewController
@end

@interface SBCCMediaControlsSectionController : SBControlCenterSectionViewController <MPUSystemMediaControlsDelegate>
@end

@interface MPUChronologicalProgressView : UIView
@end

@interface MPUMediaControlsVolumeView : UIView
@end

@interface MPUNowPlayingTitlesView : UIView
@property(copy, nonatomic) NSString *titleText;
@property(copy, nonatomic) NSString *artistText;
@end

@interface MPUMediaControlsTitlesView : MPUNowPlayingTitlesView
@end

@interface MPUTransportControlsView : UIView
@end

@interface MPUSystemMediaControlsView : UIView
@property(readonly, nonatomic) MPUMediaControlsVolumeView *volumeView;
@property(readonly, nonatomic) MPUChronologicalProgressView *timeInformationView;
@property(readonly, nonatomic) MPUMediaControlsTitlesView *trackInformationView;
@property(readonly, nonatomic) MPUTransportControlsView *transportControlsView;
@end

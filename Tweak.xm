//
//	SimpleCCMedia
//
//	*Code by Rabih M (@rabih96)*
//	*Idea by Jack O'Donnell*
//
//	Created on Wed 21/1/2015
//

#include "headers.h"

static UIInterfaceOrientation currentOrientation = UIInterfaceOrientationPortrait;
static bool shrinkMediaCLast = NO;
static bool isCC = NO;
static bool shrinkMediaC = NO;

//pref stuff
static bool enabled = YES;
static bool addC = NO;
static bool addT = NO;
static bool addSI = YES;

#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.rabih96.sccmp.plist"]
#define PreferencesChangedNotification "com.rabih96.sccmp/changed"

static CGRect make(UIView *view,int plus){
	return CGRectMake( view.frame.origin.x , view.frame.origin.y+plus , view.frame.size.width , view.frame.size.height );
}

static void loadSettings(){

	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];

	NSNumber *enabledKey = prefs[@"enabled"];
	enabled = enabledKey ? [enabledKey boolValue] : 1;

	NSNumber *addSIKey = prefs[@"addSI"];
	addSI = addSIKey ? [addSIKey boolValue] : 1;

	NSNumber *addTKey = prefs[@"addT"];
	addT = addTKey ? [addTKey boolValue] : 0;

	NSNumber *addCKey = prefs[@"addC"];
	addC = addCKey ? [addCKey boolValue] : 0;

	//now then everything is ready

}

static CGFloat getCCMHeight(){
	loadSettings();
	//need to get height to resize the view
	float height = 49;

	if(addSI) height += 40;
	if(addT)  height += 34;
	if(addC)  height += 52;

	return height;
}

%hook MPUSystemMediaControlsView

- (void)layoutSubviews{

	%orig;

	loadSettings();
	//if user turned the tweak off we need to make sure everything is visible
	[self.timeInformationView.subviews setValue:@NO forKeyPath:@"hidden"];
	[self.transportControlsView.subviews setValue:@NO forKeyPath:@"hidden"];
	[self.trackInformationView.subviews setValue:@NO forKeyPath:@"hidden"];

	//This might be the lock screen so got to check where we are
	if(isCC && enabled){

		if(!addSI) {
			[self.trackInformationView.subviews setValue:@YES forKeyPath:@"hidden"];
			self.trackInformationView.frame = make(self.trackInformationView,-30);
		}
		if(!addT)  {
			[self.timeInformationView.subviews setValue:@YES forKeyPath:@"hidden"];
			self.timeInformationView.frame = make(self.timeInformationView,-30);
		}
		if(!addC)  {
			[self.transportControlsView.subviews setValue:@YES forKeyPath:@"hidden"];
			self.transportControlsView.frame = make(self.transportControlsView,-30);
		}

		if(shrinkMediaC){
			[self.timeInformationView.subviews setValue:@YES forKeyPath:@"hidden"];
			[self.transportControlsView.subviews setValue:@YES forKeyPath:@"hidden"];
			[self.trackInformationView.subviews setValue:@YES forKeyPath:@"hidden"];
		}else{
			[self.timeInformationView.subviews setValue:@NO forKeyPath:@"hidden"];
			[self.transportControlsView.subviews setValue:@NO forKeyPath:@"hidden"];
			[self.trackInformationView.subviews setValue:@NO forKeyPath:@"hidden"];

			//this thing appear in the middle of the slider its cute but please go ^.^
			MSHookIvar<MPUNowPlayingIndicatorView *>(self.timeInformationView, "_indicatorView").hidden = YES;

			//from here on things are getting very ugly but users want this... they shall get it
			if (self.trackInformationView.artistText == nil && self.trackInformationView.titleText == nil && addSI) {
				SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
				NSString *defaultDisplayName = [[[[mediaController nowPlayingApplication] bundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
				[self.trackInformationView setTitleText:[NSString stringWithFormat:@"%@", defaultDisplayName]];
		  }
			//make the ui look normal thats what the tweak is all about (here we will solve each case  and that took some time)
			if      ( addC && !addT && !addSI) {self.transportControlsView.frame = make(self.transportControlsView,-20);}
			if      (!addC &&  addT && !addSI) {self.timeInformationView.frame   = make(self.timeInformationView,0);}
			else if ( addC &&  addT && !addSI) {self.transportControlsView.frame = make(self.transportControlsView,-20);
																					self.trackInformationView.frame = make(self.trackInformationView,-40);}
			else if ( addC && !addT &&  addSI) {self.transportControlsView.frame = make(self.transportControlsView,-5);
																					self.trackInformationView.frame  = make(self.trackInformationView,-15);}
			else if (!addC &&  addT &&  addSI) {self.trackInformationView.frame  = make(self.trackInformationView,10);}
		}
	}
}

%end

%hook SBCCMediaControlsSectionController

-(CGSize) contentSizeForOrientation:(int)orientation {
	//Where we make the Media section shrink
	CGFloat screenWidht = [[UIScreen mainScreen] bounds].size.width;
	CGFloat viewHeight  = getCCMHeight();

	if(enabled){
		if (shrinkMediaC) {
			return CGSizeMake(screenWidht, 49);
		} else if(!shrinkMediaC && (orientation == 1 || orientation == 2)) {
			return CGSizeMake(screenWidht, viewHeight);
		}
	}

	return %orig;
}

%end

%hook SBControlCenterContentView

- (void)layoutSubviews {
	%orig;
	//Where we make the Media view shrink
	CGFloat viewHeight  = getCCMHeight();
	if(enabled){
		if(shrinkMediaC) viewHeight = 49;
		self.mediaControlsSection.view.frame = CGRectMake( self.mediaControlsSection.view.frame.origin.x, self.mediaControlsSection.view.frame.origin.y, self.mediaControlsSection.view.frame.size.width, viewHeight);
	}
}

%end

%hook SBControlCenterViewController

-(CGFloat) contentHeightForOrientation:(UIInterfaceOrientation)orientation {

	currentOrientation = orientation;
	if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
		if (shrinkMediaC != shrinkMediaCLast) {
			SBControlCenterContentView *contentView = MSHookIvar<SBControlCenterContentView *>(self, "_contentView");
			[contentView setNeedsLayout];

			shrinkMediaCLast = shrinkMediaC;
		}
	} else {
		shrinkMediaC = NO;
	}

	return %orig;
}

-(void)controlCenterWillPresent {
	//CC is showing up! change isCC to true and check if smthg is playing
	isCC = YES;

	int nowPlayingProcessPID = [(SpringBoard*)[UIApplication sharedApplication] nowPlayingProcessPID];
	shrinkMediaC = (nowPlayingProcessPID <= 0);

	%orig;
}

- (void)controlCenterDidDismiss{
	%orig;
	//Since CC is closing this needs to be false
	isCC = NO;
}

%end

%ctor {
	%init();
}

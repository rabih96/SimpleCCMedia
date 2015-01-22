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

%hook MPUSystemMediaControlsView

- (void)layoutSubviews{

	%orig;

	//This might be the lock screen so got to check where we are
	if(isCC){
		[self.timeInformationView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
		[self.transportControlsView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
		self.volumeView.frame = CGRectMake( self.volumeView.frame.origin.x, self.volumeView.frame.origin.y+3, self.volumeView.frame.size.width, self.volumeView.frame.size.height);
		if(shrinkMediaC){
			[self.trackInformationView setTitleText:@""];
		}else{
			if (self.trackInformationView.artistText == nil && self.trackInformationView.titleText == nil) {
				SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
				NSString *defaultDisplayName = [[[[mediaController nowPlayingApplication] bundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
				[self.trackInformationView setTitleText:[NSString stringWithFormat:@"%@", defaultDisplayName]];
		    	}
		}
	}
}

%end

%hook SBCCMediaControlsSectionController

-(CGSize) contentSizeForOrientation:(int)orientation {
	//Where we make the Media section shrink
	CGFloat screenWidht = [[UIScreen mainScreen] bounds].size.width;

	if (shrinkMediaC) {
		return CGSizeMake(screenWidht, 47);
	} else if(!shrinkMediaC && (orientation == 1 || orientation == 2)) {
		return CGSizeMake(screenWidht, 85);
	}

	return %orig;
}

%end

%hook SBControlCenterContentView

- (void)layoutSubviews {
	%orig;

	//Where we make the Media view shrink
	int height=47;
	if(!shrinkMediaC) height=90;
	self.mediaControlsSection.view.frame = CGRectMake( self.mediaControlsSection.view.frame.origin.x, self.mediaControlsSection.view.frame.origin.y, self.mediaControlsSection.view.frame.size.width,height);
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


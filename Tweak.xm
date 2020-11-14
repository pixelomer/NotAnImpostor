#import <UIKit/UIKit.h>
#import "NAICrewmatesLayer.h"
#import "Tweak.h"

NSBundle *NotAnImpostorBundle = nil;

@interface SBWallpaperViewController : UIViewController
@property (nonatomic, strong) NAICrewmatesLayer *NotAnImpostor_crewmatesLayer;
@end

%hook SBWallpaperViewController
%property (nonatomic, strong) NAICrewmatesLayer *NotAnImpostor_crewmatesLayer;

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	if (self.NotAnImpostor_crewmatesLayer) return;
	self.NotAnImpostor_crewmatesLayer = [NAICrewmatesLayer new];
	self.NotAnImpostor_crewmatesLayer.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.NotAnImpostor_crewmatesLayer];
	[self.view addConstraints:@[
		[self.NotAnImpostor_crewmatesLayer.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[self.NotAnImpostor_crewmatesLayer.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
		[self.NotAnImpostor_crewmatesLayer.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
		[self.NotAnImpostor_crewmatesLayer.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
	]];
}

%end

NSBundle *GetNotAnImpostorBundle() {
	static NSBundle *bundle;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		bundle = [NSBundle bundleWithPath:@"/Library/Application Support/NotAnImpostor"];
		if (!bundle) {
			[NSException raise:NSGenericException format:@"Could not open the NotAnImpostor bundle."];
		}
	});
	return bundle;
}
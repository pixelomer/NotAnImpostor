#import <UIKit/UIKit.h>
#import <TargetConditionals.h>
#import "NAICrewmatesLayer.h"
#import <objc/runtime.h>

#if !NAI_TARGET_IOS && !NAI_TARGET_TVOS
#error Invalid target
#elif NAI_TARGET_IOS && NAI_TARGET_TVOS
#error Invalid target
#endif

@interface SBFWallpaperView : UIView
@end

@interface SBWallpaperView : UIView
@end

@interface PBWallpaperViewController : UIViewController
- (UIView *)wallpaperView;
@end

@interface UIView(Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface _SBWallpaperWindow : UIWindow
@property (nonatomic, strong) NAICrewmatesLayer *NotAnImpostor_crewmatesLayer;
@end

static void NAIAddCrewmateLayer(UIView *view) {
	SEL key = @selector(NotAnImpostor_crewmatesLayer);
	UIView *layer = objc_getAssociatedObject(view, key);
	if (view && !layer) {
		layer = [NAICrewmatesLayer new];
		layer.layer.zPosition = CGFLOAT_MAX;
		layer.translatesAutoresizingMaskIntoConstraints = NO;
		[view addSubview:layer];
		if (kCFCoreFoundationVersionNumber >= 793.00) {
			[view addConstraints:@[
				[NSLayoutConstraint
					constraintWithItem:layer
					attribute:NSLayoutAttributeTop
					relatedBy:NSLayoutRelationEqual
					toItem:view
					attribute:NSLayoutAttributeTop
					multiplier:1.0
					constant:0.0
				],
				[NSLayoutConstraint
					constraintWithItem:layer
					attribute:NSLayoutAttributeRight
					relatedBy:NSLayoutRelationEqual
					toItem:view
					attribute:NSLayoutAttributeRight
					multiplier:1.0
					constant:0.0
				],
				[NSLayoutConstraint
					constraintWithItem:layer
					attribute:NSLayoutAttributeLeft
					relatedBy:NSLayoutRelationEqual
					toItem:view
					attribute:NSLayoutAttributeLeft
					multiplier:1.0
					constant:0.0
				],
				[NSLayoutConstraint
					constraintWithItem:layer
					attribute:NSLayoutAttributeBottom
					relatedBy:NSLayoutRelationEqual
					toItem:view
					attribute:NSLayoutAttributeBottom
					multiplier:1.0
					constant:0.0
				]
			]];
		}
		else {
			view.frame = CGRectMake(
				0.0,
				0.0,
				view.bounds.size.width,
				view.bounds.size.height
			);
		}
		objc_setAssociatedObject(view, key, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

%group iOS6
%hook SBWallpaperView

- (SBWallpaperView *)initWithOrientation:(int)arg1 variant:(int)arg2 {
	SBWallpaperView *orig = %orig;
	NAIAddCrewmateLayer(orig);
	return orig;
}

%end
%end

%group iOS7
%hook SBFWallpaperView

// This is less reliable than _SBWallpaperWindow but it works
- (void)didMoveToWindow {
	%orig;
	if ([self class] == %c(SBFStaticWallpaperView)) {
		NAIAddCrewmateLayer(self);
	}
}

%end
%end

%group iOS10
%hook _SBWallpaperWindow

- (_SBWallpaperWindow *)initWithScreen:(UIScreen *)screen debugName:(id)name {
	_SBWallpaperWindow *orig = %orig;
	NAIAddCrewmateLayer(orig);
	return orig;
}

%end
%end

%group tvOS
%hook PBWallpaperViewController

- (void)viewDidLoad {
	%orig;
	NAIAddCrewmateLayer([self view]);
	NAIAddCrewmateLayer([self wallpaperView]);
}

%end
%end

NSBundle *GetNotAnImpostorBundle() {
	static NSBundle *bundle;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		#if NAI_TARGET_SIMULATOR
		#if NAI_TARGET_TVOS
		NSString * const path = @"/opt/simjectTV/NotAnImpostor";
		#elif NAI_TARGET_IOS
		NSString * const path = @"/opt/simject/NotAnImpostor";
		#endif
		#else
		NSString * const path = @"/Library/Application Support/NotAnImpostor";
		#endif
		bundle = [NSBundle bundleWithPath:path];
		if (!bundle) {
			[NSException raise:NSGenericException format:@"Could not open the NotAnImpostor bundle."];
		}
	});
	return bundle;
}

%ctor {
#if NAI_TARGET_IOS
	if (kCFCoreFoundationVersionNumber >= 1333.20) {
		%init(iOS10);
	}
	else if (kCFCoreFoundationVersionNumber >= 847.20) {
		%init(iOS7);
	}
	else if (kCFCoreFoundationVersionNumber >= 793.00) {
		%init(iOS6);
	}
#elif NAI_TARGET_TVOS
	if (@available(tvOS 12.0, *)) {
		%init(tvOS);
	}
#endif
	else {
		NSLog(@"This system version is not supported.");
		return;
	}
	const char * const names[] = {
		"Blue",
		"Red",
		"Green",
		"Cyan",
		"Pink",
		"Purple",
		"Yellow",
		"Brown",
		"Black",
		"White",
		"Orange",
		"Lime"
	};
	NSLog(@"%s was not An Impostor.", names[arc4random_uniform(sizeof(names)/sizeof(*names))]);
}
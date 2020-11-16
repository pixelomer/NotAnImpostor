#import <UIKit/UIKit.h>
#import "NAICrewmatesLayer.h"
#import <objc/runtime.h>

@interface SBFWallpaperView : UIView
@end

@interface SBWallpaperView : UIView
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

%group iOS3
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

NSBundle *GetNotAnImpostorBundle() {
	static NSBundle *bundle;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		#ifdef NAI_SIMULATOR
		NSString * const path = @"/opt/simject/NotAnImpostor";
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
	if (kCFCoreFoundationVersionNumber >= 1333.20) %init(iOS10);
	else if (kCFCoreFoundationVersionNumber >= 847.20) %init(iOS7);
	else %init(iOS3);
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
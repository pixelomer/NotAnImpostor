/*
 * "Commons Clause" License Condition v1.0
 *
 * The Software is provided to you by the Licensor under the License, as defined
 * below, subject to the following condition.
 *
 * Without limiting other conditions in the License, the grant of rights under
 * the License will not include, and the License does not grant to you, the right
 * to Sell the Software.
 *
 * For purposes of the foregoing, "Sell" means practicing any or all of the rights
 * granted to you under the License to provide to third parties, for a fee or
 * other consideration (including without limitation fees for hosting or
 * consulting/ support services related to the Software), a product or service
 * whose value derives, entirely or substantially, from the functionality of the
 * Software. Any license notice or attribution required by the License must also
 * include this Commons Clause License Condition notice.
 *
 * Software: NotAnImpostor
 * License: BSD 3-Clause License
 * Licensor: pixelomer
 *
 * BSD 3-Clause License
 *
 * Copyright (c) 2020-2024, pixelomer
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */

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
		layer.layer.zPosition = 100000.0;
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

- (_SBWallpaperWindow *)initWithWindowScene:(id)scene role:(id)role debugName:(id)name {
	// iOS 16.0 - iOS 17.x
	_SBWallpaperWindow *orig = %orig;
	NAIAddCrewmateLayer(orig);
	return orig;
}

- (_SBWallpaperWindow *)initWithScreen:(id)screen role:(id)role debugName:(id)name {
	// iOS 15.0 - iOS 15.x
	_SBWallpaperWindow *orig = %orig;
	NAIAddCrewmateLayer(orig);
	return orig;
}

- (_SBWallpaperWindow *)initWithScreen:(id)screen debugName:(id)name {
	// iOS 10.0 - iOS 14.x
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
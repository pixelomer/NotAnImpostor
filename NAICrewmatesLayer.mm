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

#import "NAICrewmatesLayer.h"
#import "NAIFloatingCrewmate.h"
#import <objc/runtime.h>
#define c(cname) objc_getClass(#cname)

@interface SpringBoard : UIApplication
- (id)_accessibilityFrontMostApplication;
- (BOOL)isLocked;
@end

@interface SBBacklightController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)screenIsOn;
- (BOOL)screenIsOff;
@end

const CGFloat _crewmateColorValues[12][2][3] = {
	// {{LightR, LightG, LightB}, {DarkR, DarkG, DarkB}}
	{{0.741, 0.082, 0.109}, {0.466, 0.050, 0.219}}, // Red
	{{0.070, 0.176, 0.792}, {0.035, 0.082, 0.545}}, // Blue
	{{0.101, 0.474, 0.188}, {0.058, 0.290, 0.172}}, // Green
	{{0.929, 0.929, 0.337}, {0.741, 0.517, 0.129}}, // Yellow
	{{0.901, 0.474, 0.145}, {0.670, 0.243, 0.117}}, // Orange
	{{0.231, 0.266, 0.290}, {0.113, 0.113, 0.145}}, // Black
	{{0.807, 0.850, 0.905}, {0.498, 0.568, 0.713}}, // White
	{{0.407, 0.211, 0.690}, {0.227, 0.109, 0.462}}, // Purple
	{{0.482, 0.262, 0.109}, {0.372, 0.176, 0.070}}, // Brown
	{{0.333, 0.901, 0.274}, {0.129, 0.635, 0.262}}, // Lime
	{{0.219, 0.996, 0.862}, {0.141, 0.662, 0.749}}, // Cyan
	{{0.925, 0.341, 0.721}, {0.670, 0.200, 0.670}}  // Pink
};

NSArray<NSArray<UIColor *> *> *_crewmateColors = nil;

@implementation NAICrewmatesLayer {
	NSTimer *_timer;
	NSInteger _visibleCrewmateCount;
}

+ (void)initialize {
	if (self == [NAICrewmatesLayer class]) {
		NSMutableArray *crewmateColors = [NSMutableArray new];
		const int crewmateColorValuesCount = sizeof(_crewmateColorValues) / sizeof(*_crewmateColorValues);
		for (int i=0; i<crewmateColorValuesCount; i++) {
			[crewmateColors addObject:@[
				[UIColor
					colorWithRed:_crewmateColorValues[i][0][0]
					green:_crewmateColorValues[i][0][1]
					blue:_crewmateColorValues[i][0][2]
					alpha:1.0
				],
				[UIColor
					colorWithRed:_crewmateColorValues[i][1][0]
					green:_crewmateColorValues[i][1][1]
					blue:_crewmateColorValues[i][1][2]
					alpha:1.0
				]
			]];
			_crewmateColors = crewmateColors.copy;
		}
	}
}

- (void)didMoveToWindow {
	if (_timer && !self.window) {
		[_timer invalidate];
		_timer = nil;
	}
	else if (!_timer && self.window) {
		_timer = [NSTimer
			timerWithTimeInterval:1.0
			target:self
			selector:@selector(addCrewmateTimerTick:)
			userInfo:nil
			repeats:YES
		];
		[[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
	}
}

- (NSUInteger)maxCrewmateCount {
	NSUInteger maxValue = (NSUInteger)ceil((CGFloat)(self.frame.size.width * self.frame.size.height) / 25013.0);
	if (maxValue < 5) return 5;
	return maxValue;
}

- (void)addCrewmateTimerTick:(id)sender {
#if NAI_TARGET_IOS
	SpringBoard *springboard = (SpringBoard *)[UIApplication sharedApplication];
	BOOL screenIsOn = YES;
	if (kCFCoreFoundationVersionNumber >= 847.20) {
		// iOS 7.0 and higher
		SBBacklightController *backlightController = [c(SBBacklightController) sharedInstance];
		if ([backlightController respondsToSelector:@selector(screenIsOn)]) {
			screenIsOn = [backlightController screenIsOn];
		}
		else if ([backlightController respondsToSelector:@selector(screenIsOff)]) {
			screenIsOn = ![backlightController screenIsOff];
		}
	}
	if (
		// Return if there is an app in the foreground and if the device is not locked
		([springboard _accessibilityFrontMostApplication] && ![springboard isLocked]) ||
		// Return if the screen is off
		!screenIsOn
	) {
		return;
	}
#endif
	if (
		// Return if the maximum crewmate count has been reached
		(_visibleCrewmateCount >= [self maxCrewmateCount])
	) return;
	if ((_visibleCrewmateCount < 3) || arc4random_uniform(4)) {
		// If there are less than 3 crewmates, add a new one
		// If there are 3 or more crewmates, add a new one by 75% chance
		_visibleCrewmateCount++;
		[self addCrewmate];
	}
}

- (void)addCrewmate {
	// sqrt() is used in the random duration calculation to make smaller
	// values less likely.
	const CGFloat max = 10.0;
	CGFloat duration = 0.5 + sqrt(((CGFloat)arc4random_uniform((long)(100 * pow(max, 2))))/100.0);
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.fromValue = @(0.0);
	rotationAnimation.toValue = @((M_PI * 2.0) * (arc4random_uniform(2) ? -1.0 : 1.0));
	rotationAnimation.duration = duration;
	rotationAnimation.cumulative = YES;
	rotationAnimation.repeatCount = HUGE_VALF;
	
	// Check if it's April Fools' Day
	BOOL isAprilFoolsDay;
	@autoreleasepool {
		NSDate *currentDate = [NSDate date];
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		NSDateComponents *components = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:currentDate];
		isAprilFoolsDay = (
			([components month] == 4) &&
			([components day] == 1)
		);
	}

	// Crewmate with random properties
	NAIFloatingCrewmate *crewmate = [NAIFloatingCrewmate new];
	if (!isAprilFoolsDay || arc4random_uniform(4)) {
		// If it's April Fools' Day, a crewmate can have the fortegreen
		// color with 25% chance.
		int colorIndex = arc4random_uniform(_crewmateColors.count);
		crewmate.lightColor = _crewmateColors[colorIndex][0];
		crewmate.darkColor = _crewmateColors[colorIndex][1];
	}
	crewmate.crewmateID = arc4random_uniform([NAIFloatingCrewmate crewmateCount]);
	CGFloat scale = 0.1 + ((CGFloat)arc4random_uniform(350000) / 1000000.0);
	crewmate.transform = CGAffineTransformScale(
		CGAffineTransformIdentity,
		scale,
		scale
	);
	CGSize sizeThatFits = [crewmate sizeThatFits:CGSizeZero];
	BOOL fromLeftToRight = !!arc4random_uniform(3); // 66.6% chance
	if (fromLeftToRight) {
		crewmate.frame = CGRectMake(
			self.frame.size.width,
			arc4random_uniform(self.frame.size.height) - 300,
			sizeThatFits.width * scale,
			sizeThatFits.height * scale
		);
	}
	else {
		crewmate.frame = CGRectMake(
			arc4random_uniform(self.frame.size.width - (sizeThatFits.width * scale)),
			self.frame.size.height,
			sizeThatFits.width * scale,
			sizeThatFits.height * scale
		);
	}
	crewmate.layer.zPosition = scale * 10000.0;

	// Add animations
	[self addSubview:crewmate];
	[crewmate.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
	CGFloat targetY, targetX;
	if (fromLeftToRight) {
		targetX = -300;
		targetY = arc4random_uniform(self.frame.size.height);
	}
	else {
		targetY = -300;
		targetX = arc4random_uniform(self.frame.size.width + (sizeThatFits.width * scale));
	}
	[UIView
		animateWithDuration:15.0 + (NSTimeInterval)arc4random_uniform(16)
		delay:0.0
		options:UIViewAnimationOptionCurveLinear
		animations:^{
			crewmate.frame = CGRectMake(
				targetX,
				targetY,
				crewmate.frame.size.width,
				crewmate.frame.size.height
			);
		}
		completion:^(BOOL completed){
			[crewmate removeFromSuperview];
			_visibleCrewmateCount--;
		}
	];
}

@end
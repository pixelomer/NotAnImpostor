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
@end

const CGFloat _crewmateColorValues[10][2][3] = {
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
	{{0.333, 0.901, 0.274}, {0.129, 0.635, 0.262}}  // Lime
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

- (instancetype)init {
	if ((self = [super init])) {
	}
	return self;
}

- (void)didMoveToWindow {
	if (_timer && !self.window) {
		[_timer invalidate];
		_timer = nil;
	}
	else if (!_timer && self.window) {
		_timer = [NSTimer
			scheduledTimerWithTimeInterval:1.0
			target:self
			selector:@selector(addCrewmateTimerTick:)
			userInfo:nil
			repeats:YES
		];
	}
}

- (NSUInteger)maxCrewmateCount {
	return (NSUInteger)ceil((CGFloat)(self.frame.size.height * self.frame.size.height) / 2800.0);
}

- (void)addCrewmateTimerTick:(id)sender {
	SpringBoard *springboard = (SpringBoard *)[UIApplication sharedApplication];
	if (
		([springboard _accessibilityFrontMostApplication] && ![springboard isLocked]) ||
		(_visibleCrewmateCount >= [self maxCrewmateCount]) ||
		![[c(SBBacklightController) sharedInstance] screenIsOn]
	) {
		return;
	}
	if ((_visibleCrewmateCount < 3) || arc4random_uniform(4)) {
		// If there are less than 3 crewmates, add a new one
		// If there are 3 or more crewmates, add a new one with 75% chance
		[self addCrewmate];
	}
}

- (void)addCrewmate {
	// Rotation animation with random properties
	const CGFloat max = 10.0;
	CGFloat duration = 0.5 + sqrt(((CGFloat)arc4random_uniform((long)(100 * pow(max, 2))))/100.0);
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.fromValue = @(0.0);
	rotationAnimation.toValue = @((M_PI * 2.0) * (arc4random_uniform(2) ? -1.0 : 1.0));
	rotationAnimation.duration = duration;
	rotationAnimation.cumulative = YES;
	rotationAnimation.repeatCount = HUGE_VALF;
	
	// Crewmate with random properties
	NAIFloatingCrewmate *crewmate = [NAIFloatingCrewmate new];
	int colorIndex = arc4random_uniform(_crewmateColors.count);
	crewmate.lightColor = _crewmateColors[colorIndex][0];
	crewmate.darkColor = _crewmateColors[colorIndex][1];
	crewmate.crewmateID = arc4random_uniform([NAIFloatingCrewmate crewmateCount]);
	CGFloat scale = 0.1 + ((CGFloat)arc4random_uniform(400000) / 1000000.0);
	crewmate.transform = CGAffineTransformScale(
		CGAffineTransformIdentity,
		scale,
		scale
	);
	CGSize sizeThatFits = [crewmate sizeThatFits:CGSizeZero];
	crewmate.frame = CGRectMake(
		self.frame.size.width,
		arc4random_uniform(self.frame.size.height) - 300,
		sizeThatFits.width * scale,
		sizeThatFits.height * scale
	);
	crewmate.layer.zPosition = scale * 10000.0;

	// Add animations
	[self addSubview:crewmate];
	_visibleCrewmateCount++;
	[crewmate.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
	CGFloat targetY = arc4random_uniform(self.frame.size.height + 300);
	[UIView
		animateWithDuration:15.0 + (NSTimeInterval)arc4random_uniform(16)
		delay:0.0
		options:UIViewAnimationOptionCurveLinear
		animations:^{
			crewmate.frame = CGRectMake(
				-300,
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
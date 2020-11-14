#import "NAIFloatingCrewmate.h"
#import "Tweak.h"

@implementation NAIFloatingCrewmate {
	UIImageView *_imageView;
	UIImageView *_lightMaskView;
	UIImageView *_darkMaskView;
	NSLayoutConstraint *_leftAnchor;
	NSLayoutConstraint *_topAnchor;
	NSLayoutConstraint *_heightAnchor;
	NSLayoutConstraint *_widthAnchor;
	UIView *_autoLayoutView;
}

static UIImage *_lightMask;
static UIImage *_darkMask;
static UIImage *_image;
static UIColor *_forteGreenLight;
static UIColor *_forteGreenDark;

+ (void)initialize {
	if (self == [NAIFloatingCrewmate class]) {
		NSBundle *bundle = GetNotAnImpostorBundle();
		_lightMask = [[UIImage imageWithContentsOfFile:[bundle pathForResource:@"light" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_darkMask = [[UIImage imageWithContentsOfFile:[bundle pathForResource:@"dark" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"other" ofType:@"png"]];
		_forteGreenLight = [UIColor colorWithRed:0.149 green:0.592 blue:0.337 alpha:1.0];
		_forteGreenDark = [UIColor colorWithRed:0.078 green:0.243 blue:0.113 alpha:1.0];
	}
}

- (void)setLightColor:(UIColor *)lightColor {
	if (!lightColor) {
		[NSException raise:NSInvalidArgumentException format:@"Crewmate colors must not be nil."];
	}
	_lightMaskView.tintColor = lightColor;
	_lightColor = lightColor;
}

- (void)setDarkColor:(UIColor *)darkColor {
	if (!darkColor) {
		[NSException raise:NSInvalidArgumentException format:@"Crewmate colors must not be nil."];
	}
	_darkMaskView.tintColor = darkColor;
	_darkColor = darkColor;
}


const CGFloat _properties[6][4] = {
	// {X, Y, Width, Height}
	{0, 1, 133, 229},
	{134, 1, 196, 213},
	{331, 1, 142, 186},
	{1, 230, 140, 221},
	{142, 214, 184, 187},
	{331, 189, 137, 200}
};
const NSUInteger _propertiesCount = (sizeof(_properties) / sizeof(*_properties));

+ (NSUInteger)crewmateCount {
	return _propertiesCount;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; crewmate = %lu>",
		NSStringFromClass(self.class),
		self,
		(unsigned long)_crewmateID
	];
}

- (void)setCrewmateID:(NSUInteger)crewmateID {
	if (_propertiesCount <= crewmateID) {
		[NSException raise:NSInvalidArgumentException format:@"Attempted to set the Crewmate ID to %lu, which is not in the range {0..%lu}.", (unsigned long)crewmateID, (unsigned long)(_propertiesCount-1)];
	}
	_leftAnchor.constant = -_properties[crewmateID][0];
	_topAnchor.constant = -_properties[crewmateID][1];
	_widthAnchor.constant = _properties[crewmateID][2];
	_heightAnchor.constant = _properties[crewmateID][3];
	[self setNeedsLayout];
	_crewmateID = crewmateID;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(_properties[_crewmateID][2], _properties[_crewmateID][3]);
}

- (instancetype)init {
	if ((self = [super init])) {
		_autoLayoutView = [UIView new];
		_autoLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
		_imageView = [UIImageView new];
		_darkMaskView = [UIImageView new];
		_lightMaskView = [UIImageView new];
		_imageView.translatesAutoresizingMaskIntoConstraints = NO;
		_darkMaskView.translatesAutoresizingMaskIntoConstraints = NO;
		_lightMaskView.translatesAutoresizingMaskIntoConstraints = NO;
		_imageView.contentMode = UIViewContentModeTopLeft;
		_darkMaskView.contentMode = UIViewContentModeTopLeft;
		_lightMaskView.contentMode = UIViewContentModeTopLeft;
		self.lightColor = _forteGreenLight;
		self.darkColor = _forteGreenDark;
		_imageView.image = _image;
		_darkMaskView.image = _darkMask;
		_lightMaskView.image = _lightMask;
		self.clipsToBounds = YES;
		[self addSubview:_autoLayoutView];
		[self addSubview:_imageView];
		[self addSubview:_darkMaskView];
		[self addSubview:_lightMaskView];
		[self addConstraints:@[
			[_darkMaskView.topAnchor constraintEqualToAnchor:_imageView.topAnchor],
			[_darkMaskView.leftAnchor constraintEqualToAnchor:_imageView.leftAnchor],
			[_lightMaskView.topAnchor constraintEqualToAnchor:_imageView.topAnchor],
			[_lightMaskView.leftAnchor constraintEqualToAnchor:_imageView.leftAnchor],
			[_autoLayoutView.topAnchor constraintEqualToAnchor:self.topAnchor],
			[_autoLayoutView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
			[_autoLayoutView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
			[_autoLayoutView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
			_heightAnchor = [_autoLayoutView.heightAnchor constraintEqualToConstant:0.0],
			_widthAnchor = [_autoLayoutView.widthAnchor constraintEqualToConstant:0.0],
			_topAnchor = [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
			_leftAnchor = [_imageView.leftAnchor constraintEqualToAnchor:self.leftAnchor]
		]];
		self.crewmateID = 0;
	}
	return self;
}

@end

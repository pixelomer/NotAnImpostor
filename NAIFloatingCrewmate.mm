#import "NAIFloatingCrewmate.h"

@implementation NAIFloatingCrewmate {
	UIImageView *_imageView;
}

static UIImage *_lightMask;
static UIImage *_darkMask;
static UIImage *_image;
static UIColor *_forteGreenLight;
static UIColor *_forteGreenDark;

+ (void)initialize {
	if (self == [NAIFloatingCrewmate class]) {
		NSBundle *bundle = GetNotAnImpostorBundle();
		_lightMask = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"light" ofType:@"png"]];
		_darkMask = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"dark" ofType:@"png"]];
		_image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"other" ofType:@"png"]];
		_forteGreenLight = [UIColor colorWithRed:0.149 green:0.592 blue:0.337 alpha:1.0];
		_forteGreenDark = [UIColor colorWithRed:0.078 green:0.243 blue:0.113 alpha:1.0];
	}
}

- (void)setLightColor:(UIColor *)lightColor {
	if (!lightColor) {
		[NSException raise:NSInvalidArgumentException format:@"Crewmate colors must not be nil."];
	}
	_lightColor = lightColor;
	[self setNeedsDisplay];
}

- (void)setDarkColor:(UIColor *)darkColor {
	if (!darkColor) {
		[NSException raise:NSInvalidArgumentException format:@"Crewmate colors must not be nil."];
	}
	_darkColor = darkColor;
	[self setNeedsDisplay];
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
	[self setNeedsLayout];
	_crewmateID = crewmateID;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(_properties[_crewmateID][2], _properties[_crewmateID][3]);
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect imageRect = CGRectMake(
		-_properties[_crewmateID][0],
		-_properties[_crewmateID][1],
		_properties[_crewmateID][0] + _properties[_crewmateID][2],
		_properties[_crewmateID][1] + _properties[_crewmateID][3]
	);
	_imageView.frame = imageRect;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect maskRect = CGRectMake(
		-_properties[_crewmateID][0],
		_properties[_crewmateID][1],
		_lightMask.size.width,
		_lightMask.size.height
	);

	// Setup
	CGContextTranslateCTM(context, 0, _lightMask.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Light parts
	CGContextSaveGState(context);
	[_lightColor setFill];
	CGContextClipToMask(context, maskRect, [_lightMask CGImage]);
	CGContextFillRect(context, maskRect);

	// Dark parts
	CGContextRestoreGState(context);
	[_darkColor setFill];
	CGContextClipToMask(context, maskRect, [_darkMask CGImage]);
	CGContextFillRect(context, maskRect);
}

- (instancetype)init {
	if ((self = [super init])) {
		_imageView = [UIImageView new];
		_imageView.contentMode = UIViewContentModeTopLeft;
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		_imageView.image = _image;
		self.clipsToBounds = YES;
		self.lightColor = _forteGreenLight;
		self.darkColor = _forteGreenDark;
		[self addSubview:_imageView];
		self.crewmateID = 0;
	}
	return self;
}

@end

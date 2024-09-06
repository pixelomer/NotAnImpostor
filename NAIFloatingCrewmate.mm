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
	_crewmateID = crewmateID;
	[self setNeedsLayout];
	[self setNeedsDisplay];
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

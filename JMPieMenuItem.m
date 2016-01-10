//
//  JMPieMenuItem.m
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import "JMPieMenuItem.h"

@interface JMPieMenuItem (Private)
- (JMTriangleSides)sidesOfTriangleWithAngleB:(float)angleB angleC:(float)angleC sideA:(float)sideA;
- (float)textRadiusForCircleRadius:(float)theRadius;
@end

@implementation JMPieMenuItem

- (id)initWithTitle:(NSString *)itemName action:(SEL)anAction
{
	self = [super init];
	if (self == nil)
		return self;
	
	_title = [NSAttributedString alloc];
	_path = [NSBezierPath alloc];
	
	[self setTitle:itemName];
	[self setAction:anAction];
	
	return self;
}

- (void)dealloc
{
	[_titleSelected release];
	[_title release];
	[_path release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"JMPieMenuItem \"%@\"",
		[_title string]];
}


// Attributes

- (void)setSliceAngle:(float)sliceAngle rotation:(float)rotateDegrees
{
	_sliceAngle = sliceAngle;
	_rotation = rotateDegrees;
}

- (float)rotation
{
	return _rotation;
}

- (void)setAnimatedRotation:(float)newRotation
{
	_animatedRotation = newRotation;
}

- (float)animatedRotation
{
	return _animatedRotation;
}

- (void)setTitle:(NSString *)aString
{
	[_title release];
	[_titleSelected release];
	
	// Create an attributed normal (black) string
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont systemFontOfSize:0], NSFontAttributeName,
		[NSColor controlTextColor], NSForegroundColorAttributeName,
		nil];
	_title = [[NSAttributedString alloc] initWithString:aString attributes:attrs];
		
	// Create an attributed selected (white) string
	attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont systemFontOfSize:0], NSFontAttributeName,
		[NSColor selectedMenuItemTextColor], NSForegroundColorAttributeName,
		nil];
	_titleSelected = [[NSAttributedString alloc] initWithString:aString attributes:attrs];
}

- (NSAttributedString *)title
{
	return _title;
}

- (NSAttributedString *)titleSelected
{
	return _titleSelected;
}

- (void)setPath:(NSBezierPath *)basePath radius:(float)radius
{
	[basePath retain];
	[_path release];
	_path = basePath;
	
	// Rotate path by given degrees of rotation
	NSAffineTransform* rotate = [NSAffineTransform transform];
	[rotate rotateByDegrees:_rotation];
	
	// Calculate where the text start point should be
	NSSize titleSize = [_title size];
	
	float maxTextRadius = [self textRadiusForCircleRadius:radius];	
	
	_textStartPoint = NSMakePoint(maxTextRadius, 0);
	_textStartPoint = [rotate transformPoint:_textStartPoint];
	
	_textStartPoint.x = _textStartPoint.x - (titleSize.width / 2);
	_textStartPoint.y = _textStartPoint.y - (titleSize.height / 2);
	
	int roundedRotation = round(_rotation);
	if (roundedRotation > 90 && roundedRotation < 270 && roundedRotation != 180)
	{
		_textStartPoint.x = _textStartPoint.x - (titleSize.height / 2);
	}
	else if ((roundedRotation < 90 || roundedRotation > 270) && roundedRotation != 0)
	{
		_textStartPoint.x = _textStartPoint.x + (titleSize.height / 2);
	}
	
	[_path transformUsingAffineTransform:rotate];
}

- (NSBezierPath *)path
{
	return _path;
}

- (float)minRequiredRadiusWithCenter:(float)innerRadius
{
	NSSize titleSize = [_title size];
	float titleWidth = titleSize.width + (titleSize.height * 2); // width plus some slack
	
	// Special case the exact angles
	int roundedRotation = round(_rotation);
	switch(roundedRotation)
	{
		case 0:
		case 180:
			_minTextRadius = titleWidth / 2 + innerRadius;
			return titleWidth + innerRadius;
		case 90:
		case 270:
			_minTextRadius = (titleWidth/2) / tan((_sliceAngle / 2) * 0.0174532925);
			// sin(_sliceAngle / 2) = titleWidth/2 / minRadius
			return (titleWidth/2) / sin((_sliceAngle / 2) * 0.0174532925) + (titleSize.height / 2);
	}
	
	
	JMTriangleSides sides = [self sidesOfTriangleWithAngleB:(_rotation - (_sliceAngle / 2))
													 angleC:(_sliceAngle / 2)
													  sideA:innerRadius];

	_minTextRadius = abs(titleWidth / 2 * (sides.sideA / sides.sideC)); // + (titleSize.height / 2);
	
	
	sides = [self sidesOfTriangleWithAngleB:(_rotation - (_sliceAngle / 2))
									 angleC:_sliceAngle
									  sideA:innerRadius];
	
	// Hooray we have similar triangles
	// sideB/sideC == sideA/titleWidth
	return abs(titleWidth * (MAX(sides.sideA, sides.sideB) / sides.sideC));
}

- (NSPoint)textStartPoint
{
	return _textStartPoint;
}


// Submenu
// XXX needs to set supermenu. may need a pointer to _menu from here
- (void)setSubmenu:(JMPieMenu *)aSubmenu
{
	[aSubmenu retain];
	[_submenu release];
	_submenu = aSubmenu;
	
	[self setTarget: _submenu]; // XXX gnustep does this to _menu?
	[self setAction: @selector(submenuAction:)];
}

- (JMPieMenu *)submenu
{
	return _submenu;
}

- (BOOL)hasSubmenu
{
	if (_submenu != nil)
		return YES;
	return NO;
}


// Selection

- (BOOL)containsPoint:(NSPoint)aPoint
{
	return [_path containsPoint:aPoint];
}

- (void)setSelected:(BOOL)isSelected
{
	_selected = isSelected;
}

- (BOOL)selected
{
	return _selected;
}

// Action

- (void)setAction:(SEL)aSelector
{
	_action = aSelector;
}

- (SEL)action
{
	return _action;
}

- (void)setTarget:(id)anObject
{
	_target = anObject;
}

- (id)target
{
	return _target;
}

- (void)performAction
{
	//NSLog(@"%@ clicked", _title);

	if (_action != nil)
		[NSApp sendAction:_action
					   to:_target
					 from:self];
}

@end

@implementation JMPieMenuItem (Private)

/* lawOfSines
* Given two angles and a side, determine the three sides of a triangle
* Returns an array of the three sides in order sideA, sideB, sideC
*/
- (JMTriangleSides)sidesOfTriangleWithAngleB:(float)angleB angleC:(float)angleC sideA:(float)sideA
{
	// get the third angle
	float angleA = 180 - angleB - angleC;
	float sideB;
	float sideC;

	// get three sides of a similar triangle
	// sideA is 16 (given minimum), sideB is similar to radius,
	// and sideC is similar to titleSize
	sideB = 1 / ((sin(angleA * 0.0174532925) / sideA) / sin(angleB * 0.0174532925));
	sideC = 1 / ((sin(angleA * 0.0174532925) / sideA) / sin(angleC * 0.0174532925));
	
	JMTriangleSides sides = {sideA, sideB, sideC};
	return sides;
}

- (float)textRadiusForCircleRadius:(float)theRadius
{
	NSSize titleSize = [_title size];
	float titleWidth = titleSize.width + titleSize.height; // width plus some slack
	
	// Special case the exact angles
	int roundedRotation = round(_rotation);
	switch(roundedRotation)
	{
		case 0:
		case 180:
			return theRadius - (titleWidth / 2);
		case 90:
		case 270:
			return theRadius - titleSize.height;
	}
	
	
//	JMTriangleSides sides = [self sidesOfTriangleWithAngleB:(_rotation - (_sliceAngle / 2))
//													 angleC:(_sliceAngle / 2)
//													  sideA:theRadius];

	// fudge it for now.. this is awfully close in most cases
	return theRadius - (titleWidth / 2);
	//return sides.sideB;
	//return abs(sides.sideB * ((titleWidth / 2) / sides.sideC)); // + (titleSize.height / 2);
}

@end

//
//  JMPieMenuItem.h
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import <Cocoa/Cocoa.h>

@class JMPieMenu;

@interface JMPieMenuItem : NSObject {
	float _sliceAngle;
	float _rotation;
	float _animatedRotation;
	float _minTextRadius;
	
	NSAttributedString *_title;
	NSAttributedString *_titleSelected;
	NSBezierPath *_path;

	JMPieMenu *_submenu;
	
	BOOL _selected;
	NSPoint _textStartPoint;
	
	SEL _action;
	id _target;
}

typedef struct _JMTriangleSides
{
	float sideA;
	float sideB;
	float sideC;
} JMTriangleSides;

// Initialize
- (id)initWithTitle:(NSString *)itemName action:(SEL)anAction;

- (void)setSliceAngle:(float)sliceAngle rotation:(float)rotateDegrees;
- (float)rotation;

- (void)setAnimatedRotation:(float)newRotation;
- (float)animatedRotation;


// Attributes
- (void)setTitle:(NSString *)aString;
- (NSAttributedString *)title;
- (NSAttributedString *)titleSelected;

- (void)setPath:(NSBezierPath *)basePath radius:(float)radius;
- (NSBezierPath *)path;

- (float)minRequiredRadiusWithCenter:(float)innerRadius;
- (NSPoint)textStartPoint;


// Submenu
// XXX TBD, needs to set supermenu. Called by JMPieMenu for now.
- (void)setSubmenu:(JMPieMenu *)aSubmenu;
- (JMPieMenu *)submenu;
- (BOOL)hasSubmenu;


// Selection
- (BOOL)containsPoint:(NSPoint)aPoint;
- (void)setSelected:(BOOL)isSelected;
- (BOOL)selected;


// Action
- (void)setAction:(SEL)aSelector;
- (SEL)action;
- (void)setTarget:(id)anObject;
- (id)target;

- (void)performAction;

@end

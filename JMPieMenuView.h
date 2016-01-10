//
//  JMPieMenuView.h
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import <Cocoa/Cocoa.h>

@class JMPieMenu;
@class JMPieMenuItem;

@interface JMPieMenuView : NSView {
	JMPieMenu *_menu;	// pointer to the menu this view displays
	NSPoint _center;	// screen center where pie menu should appear
	float _radius;		// chosen radius of pie menu

	NSAffineTransform *_windowTranslate;			// transform which translates from 0,0 to the center
	NSAffineTransform *_windowTranslateInverted;	// transform which is an inversion of the above
	NSBezierPath *_backgroundCircle;				// blackish circle behind our items
	
	NSTimer *_timer;								// delay before activating when outside pie	
	NSAnimation *_animation;						// closing animation. nil when not animating
	float _animationProgress;						// progress of the closing animation 0.0 to 1.0
	JMPieMenuItem *_selectedItem;					// when closing this is the item which was selected

	BOOL _shiftPressed;								// The Steve Key
}

// initialize and move the center
- (id)initWithMenu:(JMPieMenu *)aMenu;
- (void)moveToCenter:(NSPoint)newCenter;
- (NSPoint)center;

// NSView drawing
- (void)drawRect:(NSRect)rect;

// Handle mouse events to figure out what user is pointing at
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)rightMouseDragged:(NSEvent *)theEvent;
- (void)otherMouseDragged:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;
- (void)rightMouseUp:(NSEvent *)theEvent;

// NSView overrides allowing us to get focus
- (BOOL)acceptsFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;

@end

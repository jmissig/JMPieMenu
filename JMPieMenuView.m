//
//  JMPieMenuView.m
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import "JMPieMenuView.h"

#import "JMPieMenu.h"
#import "JMPieMenuItem.h"
#import <Carbon/Carbon.h>

// Private messages for JMPieMenuView
@interface JMPieMenuView (Private)

- (NSBezierPath *)generateBasePathForRadius:(float)theRadius withSliceAngle:(float)anAngle innerRadius:(float)innerRadius;
- (void)timerFired:(NSTimer *)aTimer;
- (void)itemActivated:(JMPieMenuItem *)theItem;
- (void)setAnimationProgress:(float)progress;

@end

// Subclass of NSAnimation to animate the closing
@interface JMPieMenuViewAnimation : NSAnimation
@end

@implementation JMPieMenuView

- (id)initWithMenu:(JMPieMenu *)aMenu
{
	self = [super initWithFrame:[[NSScreen mainScreen] frame]];
	if (self == nil)
		return self;
	
	[aMenu retain];
	_menu = aMenu;
	
	// jump out if we're not ready to draw anything
	if ([[_menu items] count] <= 1)
		return self;
	
	float sliceDegrees = 360.0 / [[_menu items] count];
	int innerRadius = 24;
	

	// Set the rotation for each slice and find min radius
	_radius = 0;
	float degrees = 0 - sliceDegrees;
	float tempradius;
	NSEnumerator *iter = [[_menu items] objectEnumerator];
	JMPieMenuItem *item;
	while (item = [iter nextObject])
	{
		[item setSliceAngle:sliceDegrees rotation:(degrees += sliceDegrees)];
		tempradius = [item minRequiredRadiusWithCenter:innerRadius];
		if (tempradius > _radius)
			_radius = tempradius;
	}

	// Now generate the Base Path on which each item is based
	NSBezierPath *path = [self generateBasePathForRadius:_radius
										  withSliceAngle:sliceDegrees
											 innerRadius:innerRadius];
	
	// Set the path and rotation for each menu item
	iter = [[_menu items] objectEnumerator];
	NSBezierPath* newpath;
	while (item = [iter nextObject])
	{
		newpath = [path copy];
		[item setPath:newpath radius:_radius];
		[newpath release];
	}

	// Cache the background circle as well
	_backgroundCircle = [[NSBezierPath alloc] init];
	[_backgroundCircle setLineWidth:0.5];
	[_backgroundCircle appendBezierPathWithArcWithCenter:NSZeroPoint
												  radius:_radius
											  startAngle:0
												endAngle:361];
	[_backgroundCircle closePath];
	
	
	// Cache the view translation
	_windowTranslate = [NSAffineTransform transform];
	[_windowTranslate retain];
	
	return self;
}

- (void)dealloc
{
	[_selectedItem release];

	if (_timer != nil)
		[_timer invalidate]; // invalidate releases, afaik
	
	[_backgroundCircle release];
	[_windowTranslateInverted release];
	[_windowTranslate release];
	[_menu release];
	
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Pie Menu View centered at: %f, %f", 
		_center.x, _center.y];
}


- (void)moveToCenter:(NSPoint)newCenter
{
	_center = newCenter;
	
	// Cache a new window center
	[_windowTranslate release];
	_windowTranslate = [NSAffineTransform transform];
	[_windowTranslate translateXBy:_center.x
							   yBy:_center.y];
	[_windowTranslate retain];
	
	// Cache inverted window center as well
	[_windowTranslateInverted release];
	[_windowTranslate invert];
	_windowTranslateInverted = [_windowTranslate copy]; // copy retains
	[_windowTranslate invert];
}

- (NSPoint)center
{
	return _center;
}


- (void)drawRect:(NSRect)rect
{	
	[_windowTranslate concat];
		
	[[[NSColor shadowColor] colorWithAlphaComponent:0.33] set];
	[_backgroundCircle fill];
	[[NSColor blackColor] set];
	[_backgroundCircle stroke];
	
	if (_animation != nil)
	{
		JMPieMenuItem *item;
		NSAffineTransform *animationRotate;
		NSEnumerator *iter = [[_menu items] objectEnumerator];
		while (item = [iter nextObject])
		{
			if ([item selected])
				continue;
			
			animationRotate = [NSAffineTransform transform];
			[animationRotate rotateByDegrees:[item animatedRotation] * _animationProgress];
			[animationRotate concat];
			
			// Fill in the item NSBezierPath
			[[NSColor controlHighlightColor] set]; // patterns don't do well, so fudge it
			[[item path] fill];
			
			// Draw the item title
			[[item title] drawAtPoint:[item textStartPoint]];
			
			[animationRotate invert];
			[animationRotate concat];
		}
		
		// Determine whether we're flashing on or off
		int progress = round(_animationProgress * 4);
		if (progress % 2)
		{
			// Fill in the item NSBezierPath
			[[NSColor controlColor] set];
			[[_selectedItem path] fill];
			
			// Draw the item title
			[[_selectedItem title] drawAtPoint:[_selectedItem textStartPoint]];
		}
		else
		{
			// Fill in the item NSBezierPath
			[[NSColor selectedMenuItemColor] set];
			[[_selectedItem path] fill];
			
			// Draw the item title
			[[_selectedItem titleSelected] drawAtPoint:[_selectedItem textStartPoint]];
		}

		if ([_menu markingLineEnabled])
		{
			// If we have a supermenu draw the marking line
			JMPieMenu* aSupermenu = [_menu supermenu];
			if (aSupermenu != nil)
			{
				NSBezierPath *markingLine = [[NSBezierPath alloc] init];
				[markingLine setLineWidth:4];
				[markingLine setLineCapStyle:NSRoundLineCapStyle];
				[markingLine setLineJoinStyle:NSRoundLineJoinStyle];
				[markingLine moveToPoint:[NSEvent mouseLocation]];
				[markingLine lineToPoint:_center];
				while (aSupermenu != nil)
				{
					[markingLine lineToPoint:[[aSupermenu view] center]];
					
					aSupermenu = [aSupermenu supermenu];
				}
				
				[_windowTranslateInverted concat];
				[[[NSColor blackColor] colorWithAlphaComponent:0.6] set];
				[markingLine stroke];
				return;
			}
		}
	}
	else
	{		
		// Cycle through all the slices and draw them
		NSEnumerator *iter = [[_menu items] objectEnumerator];
		JMPieMenuItem *item;
		while (item = [iter nextObject])
		{
			if ([item selected])
			{
				// Fill in the item NSBezierPath
				[[NSColor selectedMenuItemColor] set];
				[[item path] fill];
				
				// Draw the item title
				[[item titleSelected] drawAtPoint:[item textStartPoint]];
			}
			else
			{
				// Fill in the item NSBezierPath
				[[NSColor controlColor] set];
//				[[[NSColor shadowColor] colorWithAlphaComponent:0.5] set];
				[[item path] fill];
//				[[NSColor whiteColor] set];
//				[[item path] stroke];
				
				// Draw the item title
				[[item title] drawAtPoint:[item textStartPoint]];
				
//				if ([item hasSubmenu])
//				{
//				NSImage *arrow = [NSImage imageNamed:@"NSMacSubmenuArrow"];
//				NSPoint arrowPoint = NSMakePoint(_radius,0);
//				NSAffineTransform *arrowRotate = [NSAffineTransform transform];
//				[arrowRotate rotateByDegrees:[item rotation]];
//				[arrowRotate concat];
//				NSRect rect = NSMakeRect(0,0,[arrow size].width,[arrow size].height);
//				[arrow drawAtPoint:arrowPoint fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
//				[arrowRotate invert];
//				[arrowRotate concat];
//				}
			}
		}
	}

	// undo our translation
	[_windowTranslateInverted concat];
}



- (void)mouseMoved:(NSEvent *)theEvent
{
	if (_animation != nil)
		return;

	NSPoint p = [NSEvent mouseLocation];
//	NSPoint p = [theEvent locationInWindow];
//	p = [self convertPoint:p fromView:nil];
	
	p = [_windowTranslateInverted transformPoint:p];

	BOOL pointInPie = NO;
	
	// Cycle through the items and see if cursor is over a slice
	NSEnumerator *iter = [[_menu items] objectEnumerator];
	JMPieMenuItem *item;
	while (item = [iter nextObject])
	{
		if ([item containsPoint:p])
		{
			pointInPie = YES;
			
			// update current selection if needed
			if (![item selected])
			{
				[item setSelected:YES];
				[self setNeedsDisplay:YES];
			}
		}
		else if ([item selected])
		{
			// this slice doesn't contain the cursor but is selected
			// so make it not selected
			[item setSelected:NO];
			[self setNeedsDisplay:YES];
		}
	}
	
	
	if (pointInPie)
	{
		if (_timer != nil)
		{
			[_timer invalidate];
		}
	}
	else {
		// Make sure we're outside and not in the center
		if (p.x * p.x + p.y * p.y > _radius * _radius)  // x^2 + y^2 > r^2
		{
			float angle = atan2f(p.y, p.x) * 57.2957795;  // 57... is rad -> deg
			if (angle < 0)
				angle = 360 + angle;
			int numItems = [[_menu items] count];
			int itemIndex = round(angle / (360.0 / numItems));
			if (itemIndex == numItems)
				itemIndex = 0;
			//NSLog(@"%f should be item %d", angle, item);
			
			JMPieMenuItem *item = [[_menu items] objectAtIndex:itemIndex];
			[item setSelected:YES];
			[self setNeedsDisplay:YES];
			
			// Start a timer to call after 200 ms
			if (_timer != nil)
			{
				[_timer invalidate];
			}

			_timer = [NSTimer scheduledTimerWithTimeInterval:0.1
													  target:self
													selector:@selector(timerFired:)
													userInfo:item
													 repeats:NO];
			[_timer retain];
			
			if ([theEvent modifierFlags] & NSShiftKeyMask)
				_shiftPressed = YES;
			
			//[item performAction];
			//[self itemActivated:item];
		}
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (_animation != nil)
		return;

	NSPoint p = [NSEvent mouseLocation];
//	NSPoint p = [theEvent locationInWindow];
//	p = [self convertPoint:p fromView:nil];

	p = [_windowTranslateInverted transformPoint:p];
		
	NSEnumerator *iter = [[_menu items] objectEnumerator];
	JMPieMenuItem *item;
	while (item = [iter nextObject])
	{
		if ([item containsPoint:p])
		{
			if ([theEvent modifierFlags] & NSShiftKeyMask)
				_shiftPressed = YES;
			
			[self itemActivated:item];
			return;
		}
	}
	
	[_menu close];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	[self mouseUp:theEvent];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	[_menu close];
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

@end

@implementation JMPieMenuView (Private)

- (NSBezierPath *)generateBasePathForRadius:(float)theRadius withSliceAngle:(float)anAngle innerRadius:(float)innerRadius
{
	float sliceDegreesHalf = anAngle / 2;

	// Create the initial path off of which all others are based
	NSBezierPath *path = [[NSBezierPath alloc] init];
	
	// start point for the path - go out to radius then rotate
	NSPoint startPoint = NSMakePoint(theRadius, 0);
	NSAffineTransform *rotate = [NSAffineTransform transform];
	[rotate rotateByDegrees:360 - sliceDegreesHalf];
	startPoint = [rotate transformPoint:startPoint];
	
	// Make the inner arc
	[path setLineWidth:0.2];
	[path appendBezierPathWithArcWithCenter:NSZeroPoint
									 radius:innerRadius
								 startAngle:sliceDegreesHalf
								   endAngle:(360 - sliceDegreesHalf)
								  clockwise:YES];
	// a line to the outside
	[path lineToPoint:startPoint];
	// and the outer arc
	[path appendBezierPathWithArcWithCenter:NSZeroPoint
									 radius:theRadius
								 startAngle:(360 - sliceDegreesHalf)
								   endAngle:sliceDegreesHalf];
	// and a line back to the inside
	[path closePath];
	
	[path autorelease];
	return path;
}

- (void)timerFired:(NSTimer *)aTimer
{
	[self itemActivated:[aTimer userInfo]];
	[_timer release];
	_timer = nil;
}

- (void)itemActivated:(JMPieMenuItem *)theItem
{
	if (_timer != nil)
	{
		[_timer invalidate];
		_timer = nil;
	}
	
	[theItem retain];
	[_selectedItem release];
	_selectedItem = theItem;
	
	[_selectedItem performAction];
	
	// cache the total rotation each item needs to perform during animation
	float totalRotation;
	JMPieMenuItem *item;
	NSEnumerator *iter = [[_menu items] objectEnumerator];
	while (item = [iter nextObject])
	{
		if ([item selected])
			continue;
		
		totalRotation = 0 - ([item rotation] - [_selectedItem rotation]);
		if (totalRotation > 180)
		{
			totalRotation -= 360;
		}
		else if (totalRotation < -180)
		{
			totalRotation += 360;
		}
		
		[item setAnimatedRotation:totalRotation];
	}
	
	// The Steve Key
	float duration = 0.4;
	if (_shiftPressed)
	{
		duration = 2.0;
		_shiftPressed = NO;
	}
	
	_animation = [[JMPieMenuViewAnimation alloc] initWithDuration:duration animationCurve:NSAnimationEaseInOut];
	[_animation setDelegate:self];
	
	[_animation startAnimation];
	
	[_animation release];
	_animation = nil;
	
	// deselect our selected item (view is recycled)
	[_selectedItem setSelected:NO];
	
	[_menu close];
}

- (void)setAnimationProgress:(float)theProgress
{
	_animationProgress = theProgress;
}

@end

// NSAnimation subclass implementation
@implementation JMPieMenuViewAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
	[super setCurrentProgress:progress];
	
	[[self delegate] setAnimationProgress:progress];
	
	[[self delegate] display];
}

@end

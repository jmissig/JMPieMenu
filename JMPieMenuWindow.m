//
//  JMPieMenuWindow.m
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import "JMPieMenuWindow.h"


@implementation JMPieMenuWindow

//- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
//{
//	return [self initWithContentRect:contentRect
//						   styleMask:aStyle
//							 backing:bufferingType
//							   defer:flag
//							  screen:[NSScreen mainScreen]];
//}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)aScreen
{
	self = [super initWithContentRect:contentRect
							styleMask:aStyle
							  backing:bufferingType
								defer:flag
							   screen:aScreen];
	if (self == nil)
		return self;
	
//	[self setBackgroundColor:[[NSColor shadowColor] colorWithAlphaComponent:0.5]];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setLevel:NSPopUpMenuWindowLevel];
	[self setOpaque:NO];
	[self setHasShadow:YES];
	
	return self;
}

- (id)initOnScreen:(NSScreen *)aScreen withView:(NSView *)aView
{
	NSRect screenRect = [aScreen frame];
	self = [self initWithContentRect:screenRect
						   styleMask:NSBorderlessWindowMask
							 backing:NSBackingStoreBuffered
							   defer:NO
							  screen:aScreen];
	
	if (self == nil)
		return self;
	
	[self setContentView:aView];
	return self;
}

// Allow us to become a key window
- (BOOL)canBecomeKeyWindow
{
	return YES;
}



// Animations
- (void)fadeIn
{
	NSViewAnimation *theAnim;
	NSDictionary *theDict = [NSDictionary dictionaryWithObjectsAndKeys:self, NSViewAnimationTargetKey, 
		NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
	
	theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
		arrayWithObjects:theDict, nil]];
	
	[theAnim startAnimation];
}

//- (void)close
//{
//	[super close];

//	NSViewAnimation *theAnim;
//	NSDictionary *theDict = [NSDictionary dictionaryWithObjectsAndKeys:self, NSViewAnimationTargetKey, 
//		NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
//	
//	theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
//		arrayWithObjects:theDict, nil]];
//	
//	[theAnim setDuration:0.3];
//	[theAnim setDelegate:self];
//	[theAnim startAnimation];
//}

- (void)animationDidEnd:(NSAnimation *)anAnimation
{
//	[super close];
}

@end

//
//  JMPieMenu.m
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import "JMPieMenu.h"

#import "JMPieMenuItem.h"
#import "JMPieMenuView.h"
#import "JMPieMenuWindow.h"

@implementation JMPieMenu

- (id)init
{
	self = [super init];
	if (self == nil)
		return self;
	
	_view = [[JMPieMenuView alloc] initWithMenu:self];
	_supermenu = nil;
	
	_items = [[NSMutableArray alloc] initWithCapacity:4];
	
	_markingLineEnabled = YES;
	
	return self;
}

- (void)dealloc
{
	if (_window)
		[self close];
	
	[_supermenu release];
	[_view release];
	[_window release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Pie Menu with window: %@ and view: %@", _window, _view];
}


- (NSArray *)items
{
	return _items;
}

- (JMPieMenuView *)view
{
	return _view;
}

- (void)displayOnScreen:(NSScreen *)aScreen
{
	[_view moveToCenter:[NSEvent mouseLocation]];
	
	_window = [[JMPieMenuWindow alloc] initOnScreen:aScreen
										   withView:_view];
	
//	[_window startAnimation];
	[_window makeKeyAndOrderFront:nil];
	[_window setAcceptsMouseMovedEvents:YES];
	[_window makeFirstResponder:_view];
}

- (void)display
{
	[self displayOnScreen:[NSScreen mainScreen]];
}

- (void)displayFromEvent:(NSEvent *)theEvent
{
	[self displayOnScreen:[[theEvent window] screen]];
}

- (void)close
{
	[_window close];
	//[_window release];
	//_window = nil;
}


- (void)setMarkingLineEnabled:(BOOL)flag
{
	_markingLineEnabled = flag;
	
	// Set marking line flag on submenus if available
	JMPieMenuItem *item;
	NSEnumerator *iter = [_items objectEnumerator];
	while (item = [iter nextObject])
	{
		if ([item hasSubmenu])
		{
			[[item submenu] setMarkingLineEnabled:flag];
		}
	}
}

- (BOOL)markingLineEnabled
{
	return _markingLineEnabled;
}


- (void)addItem:(JMPieMenuItem *)newItem
{
	[_items addObject:newItem];

	// View is dirty now
	[_view release];
	_view = [[JMPieMenuView alloc] initWithMenu:self];
	if (_window)
	{
		[_window setContentView:_view];
		[_window makeFirstResponder:_view];
	}

}

- (id)addItemWithTitle:(NSString *)aString action:(SEL)aSelector
{
	JMPieMenuItem *newItem = [[JMPieMenuItem alloc] initWithTitle:aString action:aSelector];
	[self addItem:newItem];
	[newItem autorelease];
	return newItem;
}

- (void)setSubmenu:(JMPieMenu *)aMenu forItem:(JMPieMenuItem *)anItem
{
	[anItem setSubmenu:aMenu];
	[aMenu setSupermenu:self];
}

- (void)setSupermenu:(JMPieMenu *)aMenu
{
	[aMenu retain];
	[_supermenu release];
	_supermenu = aMenu;
}

- (JMPieMenu *)supermenu
{
	return _supermenu;
}

- (void)submenuAction:(id)sender
{
	[self display];
}

@end

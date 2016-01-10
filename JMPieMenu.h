//
//  JMPieMenu.h
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import <Cocoa/Cocoa.h>

@class JMPieMenuItem;
@class JMPieMenuView;
@class JMPieMenuWindow;

@interface JMPieMenu : NSObject {
	JMPieMenuWindow *_window;		// Window used to display the view
	JMPieMenuView *_view;			// View used to display the items
	JMPieMenu *_supermenu;			// Menu this belongs to if this is a submenu
	NSMutableArray *_items;			// Menu items in this menu
	
	BOOL _markingLineEnabled;		// Whether a marking line should be drawn
}
// Initialize
- (id)init;


// Item and view accessors
- (NSArray *)items;
- (JMPieMenuView *)view;
- (JMPieMenu *)supermenu;


// Display
- (void)displayOnScreen:(NSScreen *)aScreen;
- (void)display;
- (void)displayFromEvent:(NSEvent *)theEvent;
- (void)close;


// Attributes
//- (void)setTitle:(NSString *)aString;
//- (NSAttributedString *)title;
- (void)setMarkingLineEnabled:(BOOL)flag;
- (BOOL)markingLineEnabled;

// Managing the menu items
- (void)addItem:(JMPieMenuItem *)newItem;
- (id)addItemWithTitle:(NSString *)aString action:(SEL)aSelector;
- (void)setSubmenu:(JMPieMenu *)aMenu forItem:(JMPieMenuItem *)anItem;


// Called by setSubmenu and JMPieMenuView
- (void)setSupermenu:(JMPieMenu *)aMenu;

// Called by JMPieMenuItems to open a submenu
- (void)submenuAction:(id)sender;

@end

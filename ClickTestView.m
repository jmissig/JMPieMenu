#import "ClickTestView.h"

#import "JMPieMenu.h"
#import "JMPieMenuItem.h"

@implementation ClickTestView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		_contextMenu = [[JMPieMenu alloc] init];
		[_contextMenu addItemWithTitle:@"Forward" action:@selector(itemClicked:)];
		[_contextMenu addItemWithTitle:@"View Source" action:@selector(itemClicked:)];
		[_contextMenu addItemWithTitle:@"Reload" action:@selector(itemClicked:)];
		[_contextMenu addItemWithTitle:@"Open Link" action:@selector(itemClicked:)];
		[_contextMenu addItemWithTitle:@"Back" action:@selector(itemClicked:)];
		[_contextMenu addItemWithTitle:@"Save Image As..." action:@selector(itemClicked:)];
		[_contextMenu addItemWithTitle:@"Print..." action:@selector(itemClicked:)];
		
		JMPieMenu *aSubmenu = [[JMPieMenu alloc] init];
		[aSubmenu addItemWithTitle:@"Forward" action:@selector(itemClicked:)];
		[aSubmenu addItemWithTitle:@"Reload" action:@selector(itemClicked:)];
		[aSubmenu addItemWithTitle:@"Back" action:@selector(itemClicked:)];
		JMPieMenuItem *viewSource = [[JMPieMenuItem alloc] initWithTitle:@"View Source" action:nil];
		[aSubmenu addItem:viewSource];
		
		JMPieMenuItem *item = [[JMPieMenuItem alloc] initWithTitle:@"Submenu" action:nil];
		[_contextMenu setSubmenu:aSubmenu forItem:item];
		[_contextMenu addItem:item];
		
		JMPieMenu *aSubmenu2 = [[JMPieMenu alloc] init];
		[aSubmenu setSubmenu:aSubmenu2 forItem:viewSource];
		[aSubmenu2 addItemWithTitle:@"Forward" action:@selector(itemClicked:)];
		[aSubmenu2 addItemWithTitle:@"Reload" action:@selector(itemClicked:)];
		[aSubmenu2 addItemWithTitle:@"Back" action:@selector(itemClicked:)];
		[aSubmenu2 addItemWithTitle:@"View Source" action:@selector(itemClicked:)];
		[aSubmenu2 addItemWithTitle:@"Open Link" action:@selector(itemClicked:)];
		[aSubmenu2 addItemWithTitle:@"Print..." action:@selector(itemClicked:)];
	}
	return self;
}

- (void)dealloc
{
	[_contextMenu release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[_contextMenu displayFromEvent:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[_contextMenu displayFromEvent:theEvent];
}

//- (void)mouseDragged:(NSEvent *)theEvent
//{
//	[[_contextMenu view] mouseDragged:theEvent];
//}
//
//- (void)rightMouseDragged:(NSEvent *)theEvent
//{
//	[[_contextMenu view] rightMouseDragged:theEvent];
//}

//- (void)mouseUp:(NSEvent *)theEvent
//{
//	[[_contextMenu view] mouseUp:theEvent];
//}
//
//- (void)rightMouseUp:(NSEvent *)theEvent
//{
//	[[_contextMenu view] mouseUp:theEvent];
//}

@end

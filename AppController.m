#import "AppController.h"

@implementation AppController

- (void)itemClicked:(id)sender
{
	NSString *clicked = [NSString stringWithFormat:@"%@ clicked", sender];
	[_label setStringValue:clicked];
}

@end

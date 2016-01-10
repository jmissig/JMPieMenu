//
//  JMPieMenuWindow.h
//  Julian's Cocoa Pie Menu
//
//  Created by Julian Missig on 20 Nov 05.
//

#import <Cocoa/Cocoa.h>


@interface JMPieMenuWindow : NSWindow {
}
- (id)initOnScreen:(NSScreen *)aScreen withView:(NSView *)aView;

- (void)fadeIn;

@end

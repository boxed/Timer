#import "RoundCloseButton.h"

@implementation RoundCloseButton

- (void)drawRect:(NSRect)rect
{
	NSImage* image = dark? [NSImage imageNamed:@"hud_titlebar-close-dark"]: [NSImage imageNamed:@"hud_titlebar-close"];
	NSRect r = {{0, rect.origin.y}, {13, 13}};
	[image drawAtPoint:rect.origin fromRect:r operation:NSCompositeSourceOver fraction:1];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)setDark:(BOOL)_dark
{
	dark = _dark;
}

@end

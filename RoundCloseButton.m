#import "RoundCloseButton.h"

@implementation RoundCloseButton

- (void)drawRect:(NSRect)rect
{
	// Use dark image in light mode (for contrast on gray titlebar), light image in dark mode
	BOOL useDarkImage = dark;
	if (!dark) {
		NSAppearanceName appearanceName = [[self effectiveAppearance] bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
		useDarkImage = ![appearanceName isEqualToString:NSAppearanceNameDarkAqua];
	}
	NSImage* image = useDarkImage ? [NSImage imageNamed:@"hud_titlebar-close-dark"] : [NSImage imageNamed:@"hud_titlebar-close"];
	NSRect bounds = [self bounds];
	// Center the 13x13 image in the view
	NSPoint drawPoint = NSMakePoint((bounds.size.width - 13) / 2, (bounds.size.height - 13) / 2);
	NSRect sourceRect = {{0, 0}, {13, 13}};
	[image drawAtPoint:drawPoint fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)setDark:(BOOL)_dark
{
	dark = _dark;
}

- (void)viewDidChangeEffectiveAppearance
{
	[self setNeedsDisplay:YES];
}

@end

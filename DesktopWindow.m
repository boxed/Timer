#import "DesktopWindow.h"

@implementation DesktopWindow

- (id)initForScreen:(int)screenIndex
{
	if ([[NSScreen screens] count] <= screenIndex)
		return nil;
	
	NSRect frame = [[NSScreen screens][screenIndex] frame];
	
    if ((self = [super initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:FALSE]) != nil)
	{
		[self setLevel:kCGDesktopWindowLevel];
		[self setIgnoresMouseEvents:TRUE];
		[self setHasShadow: NO];
		hidden = TRUE;
	}
	
	return self;
}

- (void)orderOut:(id)sender
{
	[super orderOut:sender];
	hidden = TRUE;
}

- (void)orderFront:(id)sender
{
	[super orderFront:sender];
	hidden = FALSE;
}

- (BOOL)hidden
{
	return hidden;
}

@end

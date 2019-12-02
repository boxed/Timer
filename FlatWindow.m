#import "FlatWindow.h"
#import "FlatView.h"

@implementation FlatWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
	if (self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:backingType defer:flag]) {
		[self setContentView:[[FlatView alloc] init]];
		initialized = TRUE;
		[self setMovableByWindowBackground:YES];
		[self setOpaque:NO];
	}
	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return TRUE;
}

- (void)setContentView:(NSView *)aView
{
	if (!initialized)
		[super setContentView:aView];
	else
	{
		int i;
		NSArray* subviews = [NSArray arrayWithArray:[aView subviews]];
		int count = [subviews count];
		for (i = 0; i != count; i++)
		{
			NSView* view = [subviews objectAtIndex:i];
			[[self contentView] addSubview:view];
		}
	}
}

@end

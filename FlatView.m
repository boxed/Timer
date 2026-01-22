#import "FlatView.h"
#import "ThemeColors.h"

@implementation FlatView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	[[ThemeColors flatViewBackgroundColor] set];
	[NSBezierPath fillRect:rect];
}

- (void)viewDidChangeEffectiveAppearance
{
	[self setNeedsDisplay:YES];
}

@end

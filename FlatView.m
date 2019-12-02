#import "FlatView.h"

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
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:rect];
}

@end

#import "FlatButton.h"
#import "ThemeColors.h"

@implementation FlatButton

- (void)drawRect:(NSRect)rect
{
	// Construct rounded rect path
    NSRect boxRect = [self bounds];
	int borderWidth = 2;
    NSRect bgRect = NSInsetRect(boxRect, borderWidth - 1.0, borderWidth - 1.0);
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 4.0;
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
	[NSBezierPath setDefaultLineWidth:1.5];
	if ([[self window] firstResponder] == self)
		[[NSColor selectedControlColor] set];
	else
		[[ThemeColors buttonBorderColor] set];
	
	[bgPath stroke];
	
	// Create drawing	rectangle for title
	NSMutableParagraphStyle *paragraphStyle;
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
	NSMutableDictionary* titleAttrs = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
        [self font], NSFontAttributeName,
        [ThemeColors buttonTextColor], NSForegroundColorAttributeName,
        [paragraphStyle autorelease], NSParagraphStyleAttributeName,
        nil] retain];
    
    float titleHInset = 6.0;
    float titleVInset = 2.0;
    NSSize titleSize = [[self title] sizeWithAttributes:titleAttrs];
    NSRect titleRect = NSMakeRect(titleHInset, 
                                  titleVInset, 
                                  rect.size.width-titleHInset*2, 
                                  titleSize.height);
    titleRect.size.width = MIN(titleRect.size.width, boxRect.size.width - (2.0 * titleHInset));
    
	// Draw title text
	[[self title] drawInRect:titleRect withAttributes:titleAttrs];
    [titleAttrs release];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)viewDidChangeEffectiveAppearance
{
	[self setNeedsDisplay:YES];
}

@end

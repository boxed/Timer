#import "CountDownView.h"
#import "Timer.h"
#import "RoundCloseButton.h"
#include <IOKit/pwr_mgt/IOPMKeys.h>

@implementation CountDownView

static NSColor* finishedTopColor = nil;
static NSColor* finishedBottomColor = nil;
static NSColor* runningTopColor = nil;
static NSColor* runningBottomColor = nil;
static NSColor* emptyTopColor = nil;
static NSColor* emptyBottomColor = nil;

+ (void)initialize
{
	finishedTopColor = [[NSColor colorWithDeviceRed:1 green:0.3 blue:0.3 alpha:1] retain];
	finishedBottomColor = [NSColor redColor];
	
	runningTopColor = [[NSColor colorWithDeviceRed:0.6 green:0.75 blue:0.91 alpha:1] retain];
	runningBottomColor = [[NSColor colorWithDeviceRed:0.4 green:0.66 blue:0.96 alpha:1] retain];
	
	emptyTopColor = [[NSColor colorWithDeviceWhite:0.88 alpha:1] retain];
	emptyBottomColor = [[NSColor colorWithDeviceWhite:0.94 alpha:1] retain];
}

- (id)initWithRect:(NSRect)frameRect seconds:(int)inSeconds title:(NSString*)inTitle titleIsDefault:(BOOL)inTitleIsDefault
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		currentSeconds = totalSeconds = inSeconds;
		startTime = [[NSCalendarDate calendarDate] retain];
		targetTime = [startTime addTimeInterval:inSeconds];
		// TODO: http://www.cocoadev.com/index.pl?CocoaAppsWithAdminstratorPrivs 
		/*IOReturn ret = IOPMSchedulePowerEvent(
							   targetTime,
							   @"1",
							   CFSTR(kIOPMAutoWakeOrPowerOn));*/  
		title = [inTitle copy];
		titleIsDefault = inTitleIsDefault;
		
		NSRect r = {{0, 0}, {frameRect.size.width-6, frameRect.size.height-16}};
		text = [[[NSTextField alloc] initWithFrame:r] autorelease];
		[text setAlignment:NSCenterTextAlignment];
		[text setDrawsBackground:FALSE];
		[text setBezeled:FALSE];
		[text setEditable:FALSE];
		[self addSubview:text];
		
		float closeDiameter = 15;
		NSRect closeFrame = {{frameRect.size.width-closeDiameter, frameRect.size.height-closeDiameter}, {closeDiameter, closeDiameter}};
		close = [[[RoundCloseButton alloc] initWithFrame:closeFrame] autorelease];
		[close setTitle:@"x"];
		[close setTarget:self];
		[close setAction:@selector(close:)];
		[close setTransparent:TRUE];
		[close setButtonType:NSMomentaryChangeButton];
		[close setDark:TRUE];
		[self addSubview:close];
	}
	return self;
}

- (BOOL)closed
{
	return closed;
}

- (NSString*)title
{
	return title;
}

- (float)totalSeconds
{
	return totalSeconds;
}

- (void)close:(id)sender
{
	closed = TRUE;
	currentSeconds = -1;
	[self removeFromSuperview];
}

- (BOOL)overdue
{
	return currentSeconds <= 0;
}

- (BOOL)updateAndReturnPastThreshold
{
	int oldCurrentSeconds = currentSeconds;
	NSCalendarDate* now = [NSCalendarDate calendarDate];
	currentSeconds = totalSeconds-[now timeIntervalSinceDate:startTime];
	
	[self setNeedsDisplay:YES];
	return oldCurrentSeconds > 0 && currentSeconds <= 0;
}

- (void)drawProgressbarInRect:(NSRect)bounds
{
	float originalWidth = bounds.size.width;
	NSRect originalBounds = bounds;
	int fillWidth = (int)((bounds.size.width)*(1.0-(float)currentSeconds/totalSeconds));
	bounds.size.height -= 6;
	bounds.origin.x++;
	bounds.origin.y++;
	
	if (fillWidth > originalWidth)
		fillWidth = originalWidth;
	
	NSRect fillAreaTop = bounds;
	NSRect fillAreaBottom = bounds;
	fillAreaBottom.size.height /= 2;
	fillAreaBottom.size.height++; // avoid an edge between the surfaces
	fillAreaTop.size.height /= 2;
	fillAreaTop.origin.y += fillAreaTop.size.height;
	
	// draw empty area
	[emptyBottomColor set];
	[NSBezierPath fillRect:fillAreaBottom];
	
	[emptyTopColor set];
	[NSBezierPath fillRect:fillAreaTop];
	
	// draw fill area
	fillAreaBottom.size.width = fillWidth;
	fillAreaTop.size.width = fillWidth;
	
	if (currentSeconds <= 0)
		[finishedBottomColor set];
	else
		[runningBottomColor set];
	
	[NSBezierPath fillRect:fillAreaBottom];
	
	if (currentSeconds <= 0)
		[finishedTopColor set];
	else
		[runningTopColor set];
	
	[NSBezierPath fillRect:fillAreaTop];
	
	[NSBezierPath setDefaultLineWidth:1];
	[[NSColor lightGrayColor] set];
	NSRect strokeBounds = originalBounds;
	strokeBounds.size.width;
	strokeBounds.size.height -= 6;
	strokeBounds.origin.y++;
	strokeBounds.origin.x++;
	[NSBezierPath strokeRect:strokeBounds];
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];

	float closeDiameter = 15;
	NSRect closeFrame = {{bounds.size.width-closeDiameter, bounds.size.height-closeDiameter}, {closeDiameter, closeDiameter}};
	[close setFrame:closeFrame];	
	
	bounds.size.width -= 8;
	[self drawProgressbarInRect:bounds];
	
	NSString* displayTitle = @"";
	
	if (!titleIsDefault)
		displayTitle = [NSString stringWithFormat:@" %@", self->title];
		
	NSString* s;
	if (currentSeconds > 0)
		s = [NSString stringWithFormat:@"%d:%.2d%@", (int)currentSeconds/60, (int)currentSeconds%60, displayTitle];
	else
		s = [NSString stringWithFormat:@"-%d:%.2d%@", -(int)currentSeconds/60, -(int)currentSeconds%60, displayTitle];
	
	//[text setTextColor:[NSColor whiteColor]];
	[text setStringValue:s];
}

@end

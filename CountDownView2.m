#import "CountDownView2.h"
#import "RoundCloseButton.h"

@implementation CountDownView2

- (id)initWithRect:(NSRect)frameRect seconds:(int)inSeconds title:(NSString*)inTitle titleIsDefault:(BOOL)inTitleIsDefault
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		currentSeconds = totalSeconds = inSeconds;
		title = [inTitle copy];
		titleIsDefault = inTitleIsDefault;
		
		[self setTitlePosition:NSNoTitle];
		
		NSSize margins = [self contentViewMargins];
		
		float border = 5;
		float closeWidth = 18.0;
		float row1Y = 30.0-margins.height;
		float row2Y = border-margins.height;
		NSRect textFrame = {{0, row1Y}, {frameRect.size.width-border*2-closeWidth-margins.width*2, 14.0}};
		text = [[NSTextField alloc] initWithFrame:textFrame];
		[text setDrawsBackground:FALSE];
		[text setBezeled:FALSE];
		[text setEditable:FALSE];
		[self updateTitle];
		[self addSubview:text];
		
		NSRect closeFrame = {{frameRect.size.width-closeWidth-border-margins.width*2, row1Y-3}, {closeWidth, closeWidth}};
		close = [[NSButton alloc] initWithFrame:closeFrame];
		[close setTitle:@"-"];
		[close setBezelStyle:NSSmallSquareBezelStyle];
		[close setTarget:self];
		[close setAction:@selector(close:)];
		[self addSubview:close];
		
		NSRect progressFrame = {{0, row2Y}, {frameRect.size.width-border-margins.width*2, 16}};
		progress = [[NSProgressIndicator alloc] initWithFrame:progressFrame];
		[progress setIndeterminate:FALSE];
		[progress setMinValue:0];
		[progress setMaxValue:totalSeconds];
		[progress sizeToFit];
		[self addSubview:progress];
		
		NSImage* deadlinePassedImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"Picture-4.png"]];
		deadlinePassed = [[NSImageView alloc] initWithFrame:[progress frame]];
		[deadlinePassed setImage:deadlinePassedImage];
		[deadlinePassed setImageAlignment:NSImageAlignTop];
		[deadlinePassed setEditable:FALSE];
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

- (void)updateTitle
{
	
	NSString* displayTitle = @"";
	
	if (!titleIsDefault)
		displayTitle = [NSString stringWithFormat:@" %@", self->title];
	
	NSString* s;
	if (currentSeconds > 0)
		s = [NSString stringWithFormat:@"%d:%.2d%@", (int)currentSeconds/60, (int)currentSeconds%60, displayTitle];
	else
		s = [NSString stringWithFormat:@"-%d:%.2d%@", -(int)currentSeconds/60, -(int)currentSeconds%60, displayTitle];
	
	[text setStringValue:s];
}

- (int)secondPassed
{
	currentSeconds--;
	
	if (currentSeconds == 0)
	{
		//[progress removeFromSuperview];
		[self addSubview:deadlinePassed];
		[progress setDoubleValue:0];
	}
	else if (currentSeconds > 0)
		[progress incrementBy:1];
	[self updateTitle];	
	
	return currentSeconds;
}

@end

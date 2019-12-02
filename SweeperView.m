//
//  Sweeper.m
//  Timer
//
//  Created by Anders Hovmöller on 2006-12-03.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SweeperView.h"
#import <math.h>
#import <time.h>

#define PI 3.14145

static NSColor* sweepColor = nil;

@implementation SweeperView

+ (void)initialize
{
	sweepColor = [[NSColor colorWithCalibratedRed:1 green:0 blue:0 alpha:1] retain];
}

- init
{
    if (self = [super init]) {
		radians = -PI/2;
		[NSThread detachNewThreadSelector:@selector(animator:) toTarget:self withObject:nil];
	}
    return self;
}

- (void)animator:(id)sender
{
	[NSThread setThreadPriority:0.1];
	NSAutoreleasePool* autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	while(true)
	{
		struct timespec ts;
		ts.tv_sec = [[self window] isVisible]?0:1;
        ts.tv_nsec = 200000;
        nanosleep(&ts, NULL);
		[self performSelectorOnMainThread:@selector(update:) withObject:self waitUntilDone:FALSE];
	}
	
	[autoreleasepool release];
}

- (void)update:(id)sender
{
	if (radians >= PI)
		radians = -PI;

	if (radians < 0 || radians > PI)
		[[self window] setLevel:NSScreenSaverWindowLevel];
	else 
		[[self window] setLevel:kCGDesktopWindowLevel+1];
	
	radians += 0.0004;
	[self setNeedsDisplay:TRUE];
}

- (void)drawRect:(NSRect)inRect
{
	float x = sin(radians+PI/2)*inRect.size.width/2+inRect.size.width/2;
	
	//NSBezierPath *foo = [NSBezierPath bezierPath]; 
	//[foo moveToPoint:NSMakePoint(x, 0)];
	//[foo lineToPoint:NSMakePoint(x, inRect.size.height)];
	float lineWidth = (sin(radians*2-PI/2)+1.0)*(inRect.size.width/7.0)+20;
	//[foo setLineWidth:lineWidth];
	//[foo stroke];
	
	[sweepColor set];
	[NSBezierPath fillRect:NSMakeRect(x-lineWidth/2, 0, lineWidth, inRect.size.height)];
	
	[self setNeedsDisplay:FALSE];
}

@end

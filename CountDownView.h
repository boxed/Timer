/* CountDownView */

#import <Cocoa/Cocoa.h>
#import "RoundCloseButton.h"

@interface CountDownView : NSView
{
	NSTextField* text;
	RoundCloseButton* close;
	int currentSeconds;
	int totalSeconds;
	BOOL closed;
	NSString* title;
	BOOL titleIsDefault;
	NSCalendarDate* startTime;
	NSCalendarDate* targetTime;
}
- (id)initWithRect:(NSRect)rect seconds:(int)inSeconds title:(NSString*)inTitle titleIsDefault:(BOOL)inTitleIsDefault;
- (BOOL)updateAndReturnPastThreshold;
- (BOOL)overdue;
- (BOOL)closed;
- (NSString*)title;
- (float)totalSeconds;
- (void)drawProgressbarInRect:(NSRect)bounds;
@end

/* CountDownView */

#import <Cocoa/Cocoa.h>

@interface CountDownView2 : NSBox
{
	NSTextField* text;
	NSButton* close;
	NSProgressIndicator* progress;
	NSImageView* deadlinePassed;
	int currentSeconds;
	int totalSeconds;
	BOOL closed;
	NSString* title;
	BOOL titleIsDefault;
}
- (id)initWithRect:(NSRect)rect seconds:(int)inSeconds title:(NSString*)inTitle titleIsDefault:(BOOL)inTitleIsDefault;
- (int)secondPassed;
- (BOOL)overdue;
- (BOOL)closed;
- (NSString*)title;
- (float)totalSeconds;
- (void)updateTitle;
@end

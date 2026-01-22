/* Timer */

#import <Cocoa/Cocoa.h>
#import "CountDownView.h"
#import "RoundCloseButton.h"

@interface Timer : NSObject <NSApplicationDelegate>
{
    IBOutlet NSButton* startButton;
	IBOutlet RoundCloseButton* closeButton;
    IBOutlet NSTextField* time;
	IBOutlet NSTextField* minutesLabel;
	IBOutlet NSWindow* window;
	IBOutlet NSWindow* preferences;
	IBOutlet NSWindow* help;
	bool timerStarted;
	IBOutlet NSUserDefaultsController* defaults;
	NSMutableArray* counters;
	int originalHeight;
	
	NSImage *originalIcon;
}
- (IBAction)start:(id)sender;
- (void)updateTime:(id)sender;
- (void)poller:(id)sender;
- (void)showPreferences:(id)sender;
- (void)showWindow:(id)sender;
- (void)showHelp:(id)sender;
- (void)addTimer:(id)sender;
- (id)counters:(id)sender;
- (void)playTest:(id)sender;
- (void)removeOverdueCounters:(id)sender;
@end

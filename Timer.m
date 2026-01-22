#import "Timer.h"
#import "CountDownView2.h"
#import "CountDownView.h"
#import "SweeperView.h"
#import "DesktopWindow.h"

@implementation Timer

static NSSpeechSynthesizer* speech = nil;
static SweeperView* sweeperView = nil;
static DesktopWindow* sweeper = nil;

+ (void)initialize
{
	speech = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]]; 
	sweeper = [[DesktopWindow alloc] initForScreen:0];
	sweeperView = [[SweeperView alloc] init];
	
	[sweeper setBackgroundColor: [NSColor clearColor]];
	[sweeper setOpaque:NO];
    [sweeper setAlphaValue:0.4];
	[sweeper setContentView:sweeperView];
}

- init
{
    if (self = [super init]) {
		[[NSApplication sharedApplication] setDelegate:self];

		counters = [[NSMutableArray alloc] init];
		originalIcon = [[NSApp applicationIconImage] copy];
	}
    return self;
}

- (void)updateColorsForAppearance
{
	// Determine if we're in dark mode
	BOOL isDark = NO;
	NSAppearanceName appearanceName = [[NSApp effectiveAppearance] bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
	isDark = [appearanceName isEqualToString:NSAppearanceNameDarkAqua];

	NSColor *labelColor = isDark ? [NSColor whiteColor] : [NSColor blackColor];
	NSColor *inputBgColor = isDark ? [NSColor colorWithWhite:0.2 alpha:1.0] : [NSColor whiteColor];
	NSColor *inputTextColor = isDark ? [NSColor whiteColor] : [NSColor blackColor];

	// Update input field
	[time setBackgroundColor:inputBgColor];
	[time setTextColor:inputTextColor];
	[time setNeedsDisplay:YES];

	// Find the minutes label by looking through subviews if outlet not connected
	NSTextField *label = minutesLabel;
	if (!label) {
		for (NSView *view in [[window contentView] subviews]) {
			if ([view isKindOfClass:[NSTextField class]]) {
				NSTextField *tf = (NSTextField *)view;
				if ([[tf stringValue] containsString:@"inute"]) {
					label = tf;
					break;
				}
			}
		}
	}

	if (label) {
		[label setTextColor:labelColor];
		[label setNeedsDisplay:YES];
	}
}

- (void)awakeFromNib
{
	[self updateColorsForAppearance];

	// Use distributed notification for system appearance changes
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
														selector:@selector(appearanceChanged:)
															name:@"AppleInterfaceThemeChangedNotification"
														  object:nil];
}

- (void)appearanceChanged:(NSNotification *)notification
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateColorsForAppearance];
	});
}

- (float)secondsFromGui
{
	NSString* s = [time stringValue];
	NSRange spaceRange = [s rangeOfString:@" "];
	
	if (spaceRange.location != NSNotFound) 
		s = [s substringToIndex:spaceRange.location];

	NSRange range = [s rangeOfString:@":"];
	if (range.location == NSNotFound) 
	{
		float f = 0;
		if ([[NSScanner localizedScannerWithString:s] scanFloat:&f])
			return f*(float)60;
		else
			return [s floatValue]*60;
	}
	
	return [[s substringToIndex:range.location] intValue]*60+[[s substringFromIndex:range.location+range.length] intValue];
}

- (NSString*)titleFromGui
{
	NSString* s = [time stringValue];
	NSRange range = [s rangeOfString:@" "];
	if (range.location == NSNotFound) 
		return [[defaults defaults] objectForKey:@"endTimeMessage"];
	
	return [s substringFromIndex:range.location+range.length];
}

- (float)counterHeight
{
	/*NSRect textFieldRect = [time frame];
	NSRect buttonRect = [startButton frame];
	return (int)(textFieldRect.size.height*2.7);*/
	
	return 35;
}

- (BOOL)removeClosedCounters
{
	int i;
	int indexToRemove = -1;
	NSUInteger count = [counters count];
	for (i = 0; i < count; i++)
	{
		if (indexToRemove == -1)
		{
			if ([[counters objectAtIndex:i] closed])
			{
				indexToRemove = i;
			}
			[(NSView*)[counters objectAtIndex:i] setAutoresizingMask:NSViewNotSizable];
		}
		else
		{
			[(NSView*)[counters objectAtIndex:i] setAutoresizingMask:NSViewMinYMargin];
		}
	}
	
	if (indexToRemove != -1)
	{
		[counters removeObjectAtIndex:indexToRemove];
		return TRUE;
	}
	
	return FALSE;
}

- (void)removeOverdueCounters
{
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	
	int i;
	NSUInteger count = [counters count];
	for (i = 0; i < count; i++)
	{
		if ([[counters objectAtIndex:i] overdue])
		{
			[[counters objectAtIndex:i] removeFromSuperview];
			[indexes addIndex:i];
		}
	}
	
	[counters removeObjectsAtIndexes:indexes];
}

- (void)removeOverdueCounters:(id)sender
{
	[self removeOverdueCounters];
}

- (void)correctCounterPositions
{
	NSRect textFieldRect = [time frame];
	NSRect buttonRect = [startButton frame];
	float counterHeight = [self counterHeight];
	int heightOffset = 8;
	int yOffset = 6;
	
	int i;
	for (i = 0; i < [counters count]; i++)
	{
		NSRect rect = 
		{
			{(int)(textFieldRect.origin.x), (int)(textFieldRect.origin.y-[counters count]*counterHeight+i*counterHeight+counterHeight-heightOffset+yOffset)}, 
			{(int)(buttonRect.origin.x-textFieldRect.origin.x+buttonRect.size.width), (int)(counterHeight-heightOffset)}
		};
		
		NSView* counter = (NSView*)[counters objectAtIndex:i];
		[counter setFrame:rect];
		[counter setAutoresizingMask:NSViewMaxYMargin];
		
		// fix tab order
		// the following code has no effect on tab order whatsoever
		/*if (i == 0)
			[startButton setNextKeyView:counter];
		
		if (i == [counters count]-1)
			[counter setNextKeyView:time];
		else
			[counter setNextKeyView:[counters objectAtIndex:i+1]];*/
	} 
}

- (void)updateWindowSize
{
	NSRect r = [window frame];
	float newHeight = originalHeight+[self counterHeight]*[counters count];
	r.origin.y -= newHeight-r.size.height;
	r.size.height = newHeight;
	[window setFrame:r display:TRUE animate:TRUE];
}

- (void)updateViewsAndWindow
{
	[self removeOverdueCounters];
	[self correctCounterPositions];
	[self updateWindowSize];
}

- (BOOL)booleanDefault:(NSString*)key
{
	id o = [[defaults defaults] objectForKey:key];
	return o != nil && [o boolValue];
}

- (CountDownView*)newCountDownViewWithRect:(NSRect)rect
{
	NSString* title = [self titleFromGui];
	return 
		[[CountDownView alloc] initWithRect:rect 
									seconds:[self secondsFromGui] 
									  title:title 
							 titleIsDefault:[title compare:[[defaults defaults] objectForKey:@"endTimeMessage"]] == NSOrderedSame];
}

- (IBAction)start:(id)sender
{
	if ([self secondsFromGui] != 0.0)
	{	
		if (!timerStarted)
		{
			timerStarted = TRUE;
			[NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
			[NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)0.1 target:self selector:@selector(poller:) userInfo:nil repeats:YES];
			
			originalHeight = [window frame].size.height;
		}
		
		if ([self booleanDefault:@"hideOnStart"])
		{
			[window orderOut:sender];
		}
		
		float counterHeight = [self counterHeight];//textFieldRect.size.height*2;

		NSRect textFieldRect = [time frame];
		NSRect buttonRect = [startButton frame];
		NSRect rect = 
		{
			{0,0}, 
			{buttonRect.origin.x-textFieldRect.origin.x+buttonRect.size.width, counterHeight}
		};
		
		[self updateViewsAndWindow];	
		
		CountDownView* counter = [[self newCountDownViewWithRect:rect] autorelease];  
		
		[counters addObject:counter];
		[counter setAutoresizingMask:NSViewMinYMargin];
		[[time superview] addSubview:counter positioned:NSWindowBelow relativeTo:nil];
		
		[self updateViewsAndWindow];
	}
		
	[window makeFirstResponder:time];
}

- (void)playMessage:(CountDownView*)counter
{
	if (![self booleanDefault:@"mute"])
	{
		[speech startSpeakingString:[counter title]];
	}
	
	NSString* title = [counter title];
	NSString* format = NSLocalizedString(@"time_up", @"time up message, is formatted with standard C API (use %d), first minutes then seconds");
	NSString* description = [NSString stringWithFormat:format, (int)[counter totalSeconds]/60, (int)[counter totalSeconds]%60];
	
	if ([self booleanDefault:@"showOnTop"])
	{
		[window orderFrontRegardless];
	}
}

- (void)playTest:(id)sender
{
	NSRect rect = {{0, 0}, {0, 0}};
	[self playMessage:[self newCountDownViewWithRect:rect]];
}

- (BOOL)hasOverdueTimers
{
	int i;
	for (i = 0; i < [counters count]; i++)
	{
		if ([[counters objectAtIndex:i] overdue])
			return TRUE;
	}	
	return FALSE;
}

- (BOOL)hasRunningTimers
{
	int i;
	for (i = 0; i < [counters count]; i++)
	{
		if (![[counters objectAtIndex:i] overdue])
			return TRUE;
	}	
	return FALSE;
}

- (void)updateTime:(id)sender
{
	NSImage* dockImage = [[[NSImage alloc] initWithSize:NSMakeSize(128,  128)] autorelease]; 
	[dockImage lockFocus];
	[originalIcon drawAtPoint:NSMakePoint(0, 0)
					 fromRect:NSMakeRect(0, 0, 128, 128) 
					operation:NSCompositeSourceOver 
					 fraction:1.0f];
	
	float counterHeight = 128.0/[counters count];
	if (counterHeight > 30)
		counterHeight = 30;
	NSRect rect = {{0, 10}, {128, counterHeight}};
	
	int i;
	for (i = 0; i < [counters count]; i++, rect.origin.y += counterHeight)
	{
		id counter = [counters objectAtIndex:i];
		if ([counter updateAndReturnPastThreshold])
		{
			if ([self booleanDefault:@"showAtEndTime"])
			{
				[window orderFront:sender];
			}
			
			[self playMessage:[counters objectAtIndex:i]];
		}
		
		if (![self booleanDefault:@"doNotShowProgressInDock"])
			[counter drawProgressbarInRect:rect];
	}
	
	if ([self hasOverdueTimers] && ![self booleanDefault:@"disableSweeps"])
		[sweeper orderFront:self];
	else
		[sweeper orderOut:self];
	
	[dockImage unlockFocus];
	
	[NSApp setApplicationIconImage:dockImage];
	
	[self removeClosedCounters];
	[self updateWindowSize];
}


- (void)poller:(id)sender
{
	if ([self removeClosedCounters])
		[self updateWindowSize];
}

- (void)showPreferences:(id)sender;
{
	if ([[defaults initialValues] count] == 0)
	{
		NSDictionary* d = [NSDictionary dictionaryWithObject:@"time" forKey:@"endTimeMessage"];
		[defaults setInitialValues:d];
	}	
	
	[preferences setReleasedWhenClosed:NO];
	[preferences orderFront:sender];
	[preferences makeKeyWindow];
}

- (void)showWindow:(id)sender;
{
	[window orderFront:sender];
	[window makeKeyWindow];
}

- (void)showHelp:(id)sender;
{	
	[help setReleasedWhenClosed:NO];
	[help orderFront:sender];
	[help makeKeyWindow];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[window orderFront:self];
	[window makeKeyWindow];
	
	return TRUE;
}

- (id)counters:(id)sender
{
	return counters;
}

- (void)addTimer:(id)sender
{
}

- (void)stopAndRemoveAllTimers
{
	int i;
	for (i = 0; i < [counters count]; i++)
	{
		[[counters objectAtIndex:i] removeFromSuperview];
	}
	
	[counters removeAllObjects];
	
	[self updateTime:self];
	[self poller:self];
}

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString  *)key
{
    if ([key isEqual:@"addTimer"])
	{
        return YES;
    }
	else
	{
        return NO;
    }
}

- (void)cancelOperation:(id)sender
{
	[self removeOverdueCounters];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if ([self hasRunningTimers])
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:NSLocalizedString(@"quit", @"Quit")];
		[alert addButtonWithTitle:NSLocalizedString(@"cancel", @"Cancel")];
		[alert setMessageText:NSLocalizedString(@"quit", @"Quit the application?")];
		[alert setInformativeText:NSLocalizedString(@"running_timers_quit_warning", @"warning message when quitting application that has timers running")];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		
		return NSTerminateLater;
	}
	else
	{
		[self stopAndRemoveAllTimers];
	}	
	return NSTerminateNow;
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode	contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		// stop all timers and resize the window back to the original size and then exit, this is to prevent the stored size being strange
		[self stopAndRemoveAllTimers];
		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:TRUE];
    }
	else
	{
		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:FALSE];
	}
}

@end

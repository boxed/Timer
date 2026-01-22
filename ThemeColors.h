#import <Cocoa/Cocoa.h>

@interface ThemeColors : NSObject

// CountDownView colors
+ (NSColor *)finishedTopColor;
+ (NSColor *)finishedBottomColor;
+ (NSColor *)runningTopColor;
+ (NSColor *)runningBottomColor;
+ (NSColor *)emptyTopColor;
+ (NSColor *)emptyBottomColor;
+ (NSColor *)progressBorderColor;

// HUDWindow colors
+ (NSColor *)titlebarColor;
+ (NSColor *)titlebarColor2;
+ (NSColor *)focusedTitlebarColor;
+ (NSColor *)focusedTitlebarColor2;
+ (NSColor *)windowBackgroundColor;

// SweeperView colors
+ (NSColor *)sweepColor;

// FlatButton colors
+ (NSColor *)buttonBorderColor;
+ (NSColor *)buttonTextColor;

// FlatView colors
+ (NSColor *)flatViewBackgroundColor;

@end

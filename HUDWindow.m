//
//  HUDWindow.m
//  HUDWindow
//
//  Created by Matt Gemmell on 12/02/2006.
//  Copyright 2006 Magic Aubergine. All rights reserved.
//

#import "HUDWindow.h"
#import "ThemeColors.h"

@implementation HUDWindow

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(NSWindowStyleMask)styleMask
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag 
{
    if (self = [super initWithContentRect:contentRect 
                                styleMask:NSWindowStyleMaskBorderless
                                  backing:bufferingType 
                                    defer:flag]) {
        
        [self setBackgroundColor: [NSColor clearColor]];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        [self setMovableByWindowBackground:YES];
        forceDisplay = NO;
        [self setBackgroundColor:[self sizedHUDBackground]];
	
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidResize:)
                                                     name:NSWindowDidResizeNotification
                                                   object:self];

        // Use distributed notification for system appearance changes
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(appearanceChanged:)
                                                                name:@"AppleInterfaceThemeChangedNotification"
                                                              object:nil];

        // Create title label
        titleLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
        [titleLabel setBezeled:NO];
        [titleLabel setDrawsBackground:NO];
        [titleLabel setEditable:NO];
        [titleLabel setSelectable:NO];
        [titleLabel setTextColor:[NSColor whiteColor]];
        [titleLabel setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
        [titleLabel setAlignment:NSCenterTextAlignment];
        [titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self contentView] addSubview:titleLabel];
        [self updateTitleLabel];

        return self;
    }
    return nil;
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self];
    [titleLabel release];
    [super dealloc];
}

- (void)appearanceChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setBackgroundColor:[self sizedHUDBackground]];
        [self display];
    });
}

- (void)updateTitleLabel
{
    float titlebarHeight = 21.0;
    NSRect contentRect = [[self contentView] bounds];
    // Position in titlebar area: 19px from left, centered vertically in titlebar
    NSRect labelFrame;
    labelFrame.origin.x = 19.0;
    labelFrame.origin.y = contentRect.size.height - titlebarHeight + (titlebarHeight - 17.0) / 2.0;
    labelFrame.size.width = contentRect.size.width - 38.0;
    labelFrame.size.height = 17.0;
    [titleLabel setFrame:labelFrame];
    [titleLabel setStringValue:[self title] ?: @""];

    // Ensure titleLabel is on top of other subviews
    [titleLabel removeFromSuperview];
    [[self contentView] addSubview:titleLabel positioned:NSWindowAbove relativeTo:nil];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
    [self setBackgroundColor:[self sizedHUDBackground]];
    [self updateTitleLabel];
    if (forceDisplay) {
        [self display];
    }
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag
{
    forceDisplay = YES;
    [super setFrame:frameRect display:displayFlag animate:animationFlag];
    forceDisplay = NO;
}

- (NSColor *)sizedHUDBackground
{
    float titlebarHeight = 21.0;
    NSSize frameSize = [self frame].size;
    frameSize.width = floor(frameSize.width);
    frameSize.height = floor(frameSize.height);
    NSImage *bg = [[NSImage alloc] initWithSize:frameSize];
    [bg lockFocus];

    // Set the current appearance so dynamic colors resolve correctly
    NSAppearance *savedAppearance = [NSAppearance currentAppearance];
    [NSAppearance setCurrentAppearance:[NSApp effectiveAppearance]];
    
    // Make background path
    NSRect bgRect = NSMakeRect(0, 0, [bg size].width, [bg size].height - titlebarHeight);
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 6.0;
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    [bgPath lineToPoint:NSMakePoint(maxX, maxY)];
    [bgPath lineToPoint:NSMakePoint(minX, maxY)];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    // Composite background color into bg
	[[ThemeColors windowBackgroundColor] set];
	[bgPath fill];
    
    // Make titlebar path
    NSRect titlebarRect = NSMakeRect(0, round([bg size].height - titlebarHeight), round([bg size].width), titlebarHeight);
    minX = NSMinX(titlebarRect);
    midX = NSMidX(titlebarRect);
    maxX = NSMaxX(titlebarRect);
    minY = NSMinY(titlebarRect);
    //midY = NSMidY(titlebarRect);
    maxY = NSMaxY(titlebarRect);
    NSBezierPath *titlePath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [titlePath moveToPoint:NSMakePoint(minX, minY)];
    [titlePath lineToPoint:NSMakePoint(maxX, minY)];
    
    // Right edge and top-right curve
    [titlePath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [titlePath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, minY) 
                                      radius:radius];
    
    [titlePath closePath];
    
    // Titlebar
	if ([self isKeyWindow])
		[[ThemeColors focusedTitlebarColor] set];
	else
		[[ThemeColors titlebarColor] set];
    [titlePath fill];

	NSRect titlebarRect2 = titlebarRect;
	if ([self isKeyWindow])
		[[ThemeColors focusedTitlebarColor2] set];
	else
		[[ThemeColors titlebarColor2] set];
    titlebarRect2.size.height = floor(titlebarRect2.size.height / 2);
	[NSBezierPath fillRect:titlebarRect2];

    // Restore the previous appearance
    [NSAppearance setCurrentAppearance:savedAppearance];

    [bg unlockFocus];
    
    return [NSColor colorWithPatternImage:[bg autorelease]];
}


- (void)becomeKeyWindow 
{
	[super becomeKeyWindow];
	[self setBackgroundColor:[self sizedHUDBackground]];
	[self display];
}

- (void)resignKeyWindow
{
	[super resignKeyWindow];
	[self setBackgroundColor:[self sizedHUDBackground]];
	[self display];
}

- (void)setTitle:(NSString *)value
{
    [super setTitle:value];
    [self updateTitleLabel];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)performClose:(id)sender
{
	[self orderOut:sender];
}

- (void)cancelOperation:(id)sender
{
	if ([[self delegate] respondsToSelector:@selector(cancelOperation:)])
		[[self delegate] cancelOperation:self];
}

@end

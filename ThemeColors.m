#import "ThemeColors.h"

@implementation ThemeColors

+ (NSColor *)adaptiveColorWithLight:(NSColor *)lightColor dark:(NSColor *)darkColor {
    return [NSColor colorWithName:nil dynamicProvider:^NSColor *(NSAppearance *appearance) {
        NSAppearanceName appearanceName = [appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
        if ([appearanceName isEqualToString:NSAppearanceNameDarkAqua]) {
            return darkColor;
        }
        return lightColor;
    }];
}

#pragma mark - CountDownView Colors

+ (NSColor *)finishedTopColor {
    return [self adaptiveColorWithLight:[NSColor colorWithDeviceRed:1 green:0.3 blue:0.3 alpha:1]
                                   dark:[NSColor colorWithDeviceRed:0.9 green:0.2 blue:0.2 alpha:1]];
}

+ (NSColor *)finishedBottomColor {
    return [self adaptiveColorWithLight:[NSColor redColor]
                                   dark:[NSColor colorWithDeviceRed:0.8 green:0.1 blue:0.1 alpha:1]];
}

+ (NSColor *)runningTopColor {
    return [self adaptiveColorWithLight:[NSColor colorWithDeviceRed:0.6 green:0.75 blue:0.91 alpha:1]
                                   dark:[NSColor colorWithDeviceRed:0.3 green:0.5 blue:0.8 alpha:1]];
}

+ (NSColor *)runningBottomColor {
    return [self adaptiveColorWithLight:[NSColor colorWithDeviceRed:0.4 green:0.66 blue:0.96 alpha:1]
                                   dark:[NSColor colorWithDeviceRed:0.2 green:0.45 blue:0.85 alpha:1]];
}

+ (NSColor *)emptyTopColor {
    return [self adaptiveColorWithLight:[NSColor colorWithDeviceWhite:0.88 alpha:1]
                                   dark:[NSColor colorWithDeviceWhite:0.25 alpha:1]];
}

+ (NSColor *)emptyBottomColor {
    return [self adaptiveColorWithLight:[NSColor colorWithDeviceWhite:0.94 alpha:1]
                                   dark:[NSColor colorWithDeviceWhite:0.20 alpha:1]];
}

+ (NSColor *)progressBorderColor {
    return [self adaptiveColorWithLight:[NSColor lightGrayColor]
                                   dark:[NSColor colorWithDeviceWhite:0.4 alpha:1]];
}

#pragma mark - HUDWindow Colors

+ (NSColor *)titlebarColor {
    return [self adaptiveColorWithLight:[NSColor colorWithCalibratedWhite:0.65 alpha:1]
                                   dark:[NSColor colorWithCalibratedWhite:0.25 alpha:1]];
}

+ (NSColor *)titlebarColor2 {
    return [self adaptiveColorWithLight:[NSColor colorWithCalibratedWhite:0.60 alpha:1]
                                   dark:[NSColor colorWithCalibratedWhite:0.20 alpha:1]];
}

+ (NSColor *)focusedTitlebarColor {
    return [self adaptiveColorWithLight:[NSColor colorWithCalibratedWhite:0.55 alpha:1]
                                   dark:[NSColor colorWithCalibratedWhite:0.35 alpha:1]];
}

+ (NSColor *)focusedTitlebarColor2 {
    return [self adaptiveColorWithLight:[NSColor colorWithCalibratedWhite:0.50 alpha:1]
                                   dark:[NSColor colorWithCalibratedWhite:0.30 alpha:1]];
}

+ (NSColor *)windowBackgroundColor {
    return [self adaptiveColorWithLight:[NSColor colorWithCalibratedWhite:0.9 alpha:1]
                                   dark:[NSColor colorWithCalibratedWhite:0.15 alpha:1]];
}

#pragma mark - SweeperView Colors

+ (NSColor *)sweepColor {
    return [self adaptiveColorWithLight:[NSColor colorWithCalibratedRed:1 green:0 blue:0 alpha:1]
                                   dark:[NSColor colorWithCalibratedRed:1 green:0.2 blue:0.2 alpha:1]];
}

#pragma mark - FlatButton Colors

+ (NSColor *)buttonBorderColor {
    return [self adaptiveColorWithLight:[NSColor whiteColor]
                                   dark:[NSColor colorWithDeviceWhite:0.7 alpha:1]];
}

+ (NSColor *)buttonTextColor {
    return [self adaptiveColorWithLight:[NSColor whiteColor]
                                   dark:[NSColor colorWithDeviceWhite:0.9 alpha:1]];
}

#pragma mark - FlatView Colors

+ (NSColor *)flatViewBackgroundColor {
    return [self adaptiveColorWithLight:[NSColor whiteColor]
                                   dark:[NSColor colorWithDeviceWhite:0.2 alpha:1]];
}

@end

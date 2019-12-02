/* DesktopWindow */

#import <Cocoa/Cocoa.h>

@interface DesktopWindow : NSWindow
{
	BOOL hidden;
}
- (id)initForScreen:(int)screenIndex;
- (BOOL)hidden;
@end

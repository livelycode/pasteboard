#import "Cocoa.h"

@class CBClipboard;

@interface CBClipboardController : NSObject
{
    @private
    CBClipboard *clipboard;
    CALayer *clipboardLayer;
    NSArray *types;
}

- (id)initWithClipboard:(CBClipboard *)aClipboard layer:(CALayer *)aLayer;

- (void)setTypes:(NSArray *)anArray;

@end

@interface CBClipboardController(Delegation) <CBPasteboardOberserverDelegate>

- (void)systemPasteboardDidChange:(NSPasteboard *)aPasteboard;

@end
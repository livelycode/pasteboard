#import "Cocoa.h"
#import "CBClipboardViewDelegate.h"

@class CBClipboard;
@class CBClipboardView;

@interface CBClipboardController : NSObject
{
    @private
    CBClipboard *clipboard;
    CBClipboardView *clipboardView;
    id changeListener;
}
							
- (id)initWithFrame:(CGRect)aFrame
     viewController:(id)viewController;

- (void)insertItem:(CBItem *)newItem
           atIndex:(NSInteger)anIndex;

- (BOOL)clipboardContainsItem:(CBItem *)anItem;

- (void)addChangeListener:(id)anObject;

@end

@interface CBClipboardController(Delegation) <CBClipboardViewDelegate>

- (void)didReceiveClickForVisibleItemAtIndex:(NSUInteger)anIndex;

- (void)didReceiveDismissClickForVisibleItemAtIndex:(NSUInteger)anIndex;

- (void)didReceiveDragOperationForVisibleItemAtIndex:(NSUInteger)anIndex;

@end
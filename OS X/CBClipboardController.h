#import "Cocoa.h"
#import "CBItemViewDelegate.h"

@class CBClipboard;
@class CBClipboardView;

@interface CBClipboardController : NSObject {
  @private
  id changeListener;
  CBClipboard *clipboard;
  CBClipboardView *clipboardView;
  NSMutableArray *frames;
  NSMutableArray *viewSlots;
  NSDate* lastChanged;
}
- (id)initWithFrame:(CGRect)aFrame viewController:(id)viewController;
- (void)setItemQuiet:(CBItem*)newItem atIndex:(NSInteger)anIndex;
- (void)setItem:(CBItem *)item atIndex:(NSInteger)index;
- (void)addItem:(CBItem *)item;
- (BOOL)clipboardContainsItem:(CBItem *)item;
- (void)addChangeListener:(id)object;
- (NSDate*)lastChanged;
- (NSArray*)allItems;
@end

@interface CBClipboardController(Delegation) <CBItemViewDelegate>
- (void)itemViewClicked:(CBItemView *)view index:(NSInteger)index;
- (void)pasteViewClicked:(CBItemView *)view index:(NSInteger)index;
@end
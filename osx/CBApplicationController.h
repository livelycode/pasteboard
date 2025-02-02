#import "Cocoa.h"
#import "CBPasteboardObserver.h"
#import "CBSyncControllerProtocol.h"

@class CBClipboard, CBClipboardController, CBItem, CBHotKeyObserver, CBPasteboardObserver, CBMainWindowController, HTTPConnectionDelegate, CBSyncController;

@interface CBApplicationController:NSObject {
  @private
  CBPasteboardObserver *pasteboardObserver;		
  CBHotKeyObserver *hotkey;
  CBClipboardController *clipboardController;
  CBMainWindowController *windowController;
  CBSyncController *syncController;
  NSStatusItem *statusItem;
  NSArray* shortcutKeycodes;
  IBOutlet NSMenu *statusBarMenu;
  NSUInteger hotkeyIndex;
  BOOL autoStart;
  BOOL autoPaste;
  BOOL menuItemVisible;
}
- (void)initPasteboardObserver;
- (CBSyncController*)syncController;
- (BOOL)autoStart;
- (void)setAutoStart:(BOOL)autoStart;
- (BOOL)autoPaste;
- (void)setAutoPaste:(BOOL)autoPaste;
- (BOOL)menuItemVisible;
- (void)setMenuItemVisible:(BOOL)visible;
- (NSUInteger)hotkeyIndex;
- (void)setHotkeyIndex:(NSUInteger)hotkey;
@end

@interface CBApplicationController(Actions)

- (IBAction)showPasteboard:(id)sender;
- (IBAction)quitApplication:(id)sender;

@end

@interface CBApplicationController(Delegation)
  <NSApplicationDelegate, CBPasteboardOberserverDelegate, CBSyncControllerProtocol>
//NSApplicationDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

//CBPasteboardOberserverDelegate
- (void)systemPasteboardDidChange;
//CBClipboardViewDelegate
- (void)pasteItem;
@end

@interface CBApplicationController(Private)
- (CBItem*)currentPasteboardItem;
- (void)loadSettings;
- (void)updateSettings;
- (void)updateLaunchd;
- (void)startHotkeyObserver;
- (void)updateStatusMenu;
- (void)initHotkeyCodes;
@end
#import "Cloudboard.h"

#define PADDING_TOP 5
#define PADDING_LEFT 5

#define ITEMS 8
#define ROWS_PORTRAIT 4
#define ROWS_LANDSCAPE 2

@implementation CBClipboardController

@end

@implementation CBClipboardController(Overriden)
- (void)viewDidLoad {
  [self.view setFrame:CGRectOffset(self.view.frame, 0, 20)];
  [self drawBackgroundLayers];
  [self initializeItemViewFrames];
  [self drawPasteView];
  [self drawAllItems];
}

- (void)viewDidUnload {
  [clipboardView release];
}

- (void)dealloc {
  [clipboard release];
  [delegate release];
  [devicesViewController release];
  [pasteButton release];
  [itemViewSlots release];
  [frames release];
  [syncController release];
  [super dealloc];
}
@end

@implementation CBClipboardController(Delegation)
//UIToolbarDelegate
- (IBAction)devicesButtonTapped:(id)event {
  [self presentModalViewController:devicesViewController animated:YES];
}
@end

@implementation CBClipboardController(Private)

@end
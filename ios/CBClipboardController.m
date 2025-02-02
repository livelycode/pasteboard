
#import "CBClipboardController.h"
#import "Cloudboard.h"

#define ITEMS 8
#define ROWS_PORTRAIT 4
#define ROWS_LANDSCAPE 2

@implementation CBClipboardController

- (id)initWithNibName:(NSString*)nibName delegate:(id)appController {
  self = [super initWithNibName:nibName bundle:nil];
  if (self != nil) {
    if((self.interfaceOrientation == UIInterfaceOrientationPortrait) ||
       (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
      [self setRowsForPortrait];
    } else {
      [self setRowsForLandscape];
    }
    [self initDeviceSpecificParams];
    clipboard = [[CBClipboard alloc] initWithCapacity:rows*columns-1];
    frames = [[NSMutableArray alloc] init];
    itemViewSlots = [[NSMutableArray alloc] init];
    delegate = appController;
  }
  return self;
}

- (void)stopSyncing {
  [syncController release];
  syncController = nil;
  [devicesViewController releaseSyncController];
}

- (void)startSyncing {
  syncController = [[CBSyncController alloc] initWithClipboardController:self];
  [devicesViewController setSyncController:syncController];
}
@end

@implementation CBClipboardController(iOSDelegation)

//UIGestureRecognizerDelegate
- (void)handleTapFromPasteView:(CBPasteView*)view {
  CBItem* newItem = [delegate currentPasteboardItem];
  if(newItem != nil) {
    [self addItem:newItem syncing:YES];
  }
}

- (void)handleTapFromItemView:(CBItemView*)itemView {
  NSInteger index = [itemViewSlots indexOfObject:itemView];
  NSString *string = [[clipboard itemAtIndex:index] string];
  UIPasteboard *systemPasteboard = [UIPasteboard generalPasteboard];
  [systemPasteboard setValue: string forPasteboardType:(NSString*)kUTTypeUTF8PlainText];
}

- (IBAction)clearAllButtonTapped:(id)event {
  [self clearClipboardSyncing:YES];
}
@end

@implementation CBClipboardController(iOSPrivate)

- (void)initDeviceSpecificParams {
  if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    paddingTop = 40;
    paddingSides = 20;
  } else {
    paddingTop = 20;
    paddingSides = 10;
  }
}

- (CGRect)rectForNSValue:(NSValue*)value {
  return [value CGRectValue];
}

- (void)setRowsForPortrait {
  rows = ROWS_PORTRAIT;
  columns = ITEMS/rows;
}

- (void)setRowsForLandscape {
  rows = ROWS_LANDSCAPE;
  columns = ITEMS/rows;
}

- (void)moveAllItemViewsAnimated {
  [UIView animateWithDuration:0.5 animations:^(void) {
    [self moveAllItemViews];
  }];
}

- (void)initializeItemViewFrames {	
  CGRect mainBounds = [clipboardView bounds];
  CGRect itemsBounds = CGRectMake(paddingSides, paddingTop, CGRectGetWidth(mainBounds)-2*paddingSides, CGRectGetHeight(mainBounds)-2*paddingTop);
  CGFloat clipboardHeight = CGRectGetHeight(itemsBounds);
  CGFloat clipboardWidth = CGRectGetWidth(itemsBounds);
  CGFloat itemWidth = clipboardWidth / columns;
  CGFloat itemHeight = clipboardHeight / rows;
  for(NSInteger row=1; row<=rows; row++) {
    for(NSInteger column=1; column<=columns; column++) {
      CGFloat x = paddingSides + itemWidth*(column-1);
      CGFloat y = paddingTop +(row-1)*itemHeight;
      CGRect itemFrame = CGRectMake(x, y, itemWidth, itemHeight);
      [frames addObject:[NSValue valueWithCGRect:itemFrame]];
    }
  }
}

-(void)addItemView:(UIView *)itemView {
  [clipboardView addSubview:itemView];
}

- (void) drawBackgroundLayers {
  UIColor *startingColor = [UIColor woodColor];
  UIColor *endingColor = [startingColor saturateWithLevel:0.1];
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.colors = [NSArray arrayWithObjects: (id)[startingColor CGColor], (id)[endingColor CGColor], nil];
  UIImage *structure = [UIImage imageNamed:@"Structure.png"];
  
  CALayer *structureLayer = [CALayer layer];
  structureLayer.backgroundColor = [[UIColor colorWithPatternImage:structure] CGColor];
  
  gradientLayer.frame = clipboardView.layer.bounds;
  structureLayer.frame = clipboardView.layer.bounds;
  
  [clipboardView.layer addSublayer: gradientLayer];
  [clipboardView.layer addSublayer:structureLayer];
}
@end
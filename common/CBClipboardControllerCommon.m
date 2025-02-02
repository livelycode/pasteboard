//
//  CBClipboardControllerCommon.m
//  Cloudboard-iOS
//
//  Created by Mirko on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cloudboard.h"

@implementation CBClipboardController(CBClipboardControllerCommon)
- (void)addItem:(CBItem *)item syncing:(BOOL)sync {
  [clipboard addItem:item];
  [clipboard persist];
  [self drawItem:item];
  if(sync) {
    [clipboard updateLastChanged];
    if(syncController) {
      [syncController didAddItem:item];
    } 
  }
}

- (void)setLastChanged:(NSDate*)date {
  [clipboard setLastChanged:date];
}

- (BOOL)clipboardContainsItem:(CBItem *)anItem {
  return [[clipboard items] containsObject:anItem];
}

- (NSDate*)lastChanged {
  return [clipboard lastChanged];
}

- (NSArray*)allItems {
  return [clipboard items];
}

- (CBSyncController*)syncController {
  return syncController;
}

- (void)clearClipboardSyncing:(BOOL)sync {
  for (CBItemView* view in itemViewSlots) {
    [view removeFromSuperview];
  }
  [itemViewSlots removeAllObjects];
  [clipboard clear];
  [clipboard updateLastChanged];
  if(sync) {
    [syncController didResetItems];
  }
  [clipboard persist];
}

- (void)persistClipboard {
  [clipboard persist];
}
@end

@implementation CBClipboardController(CommonPrivate)

- (void)drawPasteView {
  CGRect pasteButtonFrame = [self rectForNSValue:[frames objectAtIndex:0]];
  CBPasteView *pasteView = [[[CBPasteView alloc] initWithFrame:CGRectInset(pasteButtonFrame, 10, 10) delegate:self] autorelease];
  [self addItemView:pasteView];
}

- (void)drawItem:(CBItem*)item {
  CGRect itemFrame = [self rectForNSValue:[frames objectAtIndex:0]];
  CBItemView *newItemView = [[[CBItemView alloc] initWithFrame:itemFrame content:[item string] delegate:self] autorelease];
  [itemViewSlots insertObject:newItemView atIndex:0];
  [self addItemView:newItemView];
  //remove last itemView if necessary
  while([itemViewSlots count] > (rows*columns-1)) {
    CBItemView* lastView = [itemViewSlots lastObject];
    [itemViewSlots removeLastObject];
    [lastView removeFromSuperview];
  }
  //move all existing itemViews
  [self moveAllItemViewsAnimated];
}

- (void)moveAllItemViews {
  [itemViewSlots enumerateObjectsUsingBlock:^(id itemView, NSUInteger index, BOOL *stop) {
    CGRect newFrame = [self rectForNSValue:[frames objectAtIndex:index+1]];
    [itemView setFrame:newFrame];
  }];  
}

- (void)drawAllItems {
  for(CBItemView* itemView in itemViewSlots) {
    [itemView removeFromSuperview];
  }
  [itemViewSlots release];
  itemViewSlots = [[NSMutableArray alloc] init];
  for(id item in [[[clipboard items] reverseObjectEnumerator] allObjects]) {
    [self drawItem:item];
  }
}
@end
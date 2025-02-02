//
//  CBClipboardControllerCommon.h
//  Cloudboard-iOS
//
//  Created by Mirko on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBClipboardController.h"
@class CBItem, CBSyncController;

@interface CBClipboardController(CommonPublic)
- (void)addItem:(CBItem *)item syncing:(BOOL)sync;
- (void)setLastChanged:(NSDate*)date;
- (NSDate*)lastChanged;
- (NSArray*)allItems;
- (BOOL)clipboardContainsItem:(CBItem*)anItem;
- (CBSyncController*)syncController;
- (void)clearClipboardSyncing:(BOOL)sync;
- (void)persistClipboard;
@end

@interface CBClipboardController(CommonPrivate)
- (void)drawPasteView;	
- (void)drawItem:(CBItem *)item;
- (void)moveAllItemViews;
- (void)drawAllItems;
@end
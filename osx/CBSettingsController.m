#import "Cloudboard.h"


@implementation CBSettingsController(Actions)

- (IBAction)addDevice:(id)sender {
  NSUInteger index = [foundClipboardsView selectedRow];
  NSString* device = [foundCloudboards objectAtIndex:index];
  [registeredClipboards addObject:device];
  [foundCloudboards removeObject:device];
  [foundClipboardsView reloadData];
  [registeredClipboardsView reloadData];
  [syncController addClientToSearch:device];
}

- (IBAction)removeDevice:(id)sender {
  NSUInteger index = [registeredClipboardsView selectedRow];
  NSString* device = [registeredClipboards objectAtIndex:index];
  [registeredClipboards removeObjectAtIndex:index];
  [foundCloudboards addObject:device];
  [foundClipboardsView reloadData];
  [registeredClipboardsView reloadData];
  [syncController removeClientToSearch:device];
}

- (IBAction)autoPasteCheckboxChanged:(id)sender {
  NSInteger autoPaste = [sender state];
  if(autoPaste == NSOnState) {
    [appController setAutoPaste:YES];
  } else {
    [appController setAutoPaste:NO];
  }
}

- (IBAction)autoStartCheckboxChanged:(id)sender {
  NSInteger autoStart = [sender state];
  if(autoStart == NSOnState) {
    [appController setAutoStart:YES];
  } else {
    [appController setAutoStart:NO];
  }
}

- (IBAction)menuItemVisibleCheckboxChanged:(id)sender {
  NSInteger autoStart = [sender state];
  if(autoStart == NSOnState) {
    [appController setMenuItemVisible:YES];
  } else {
    [appController setMenuItemVisible:NO];
  }
}

- (IBAction)back:(id)sender {
  [windowController showFront];
}

- (IBAction)shortcutSelected:(NSPopUpButton*)sender {
  [appController setHotkeyIndex:[sender selectedTag]];
}

@end

@implementation CBSettingsController

- (id)initWithFrame:(CGRect)aRect syncController:(CBSyncController*) aSyncController; {
  self = [super initWithNibName:@"settings" bundle:nil];
  if(self != nil) {
    appController = [[NSApplication sharedApplication] delegate];
    syncController = aSyncController;
    [syncController addDelegate:self];
    
    foundCloudboards = [[NSMutableArray alloc] initWithArray:[syncController clientsVisible]];
    registeredClipboards = [[NSMutableArray alloc] initWithArray:[syncController clientsToSearch]];
    for(NSString*client in registeredClipboards) {
      [foundCloudboards removeObject:client];
    }
    [[self view] setFrame:aRect];
  }
  return self;
}

- (void)setWindowController:(CBMainWindowController *)aController {
  [windowController autorelease];
  windowController = [aController retain];
}

- (void)dealloc {
  [windowController release];
  [appController release];
  [syncController release];
  [foundCloudboards release];
  [registeredClipboards release];
  [autoStartButton release];
  [autoPasteButton release];
  [foundClipboardsView release];
  [registeredClipboardsView release];
  [addButton release];
  [removeButton release];
  [backButton release];
  [super dealloc];
}

@end

@implementation CBSettingsController(Delegation)

- (void)awakeFromNib {
  if([appController autoStart]) {
    [autoStartButton setState:NSOnState];
  } else {
    [autoStartButton setState:NSOffState];
  }
  if([appController autoPaste]) {
    [autoPasteButton setState:NSOnState];
  } else {
    [autoPasteButton setState:NSOffState];
  }
  if([appController menuItemVisible]) {
    [menuItemVisibleButton setState:NSOnState];
  } else {
    [menuItemVisibleButton setState:NSOffState];
  }
  [hotkeyPopup selectItemWithTag:[appController hotkeyIndex]];
  [addButton setEnabled:NO];
  [removeButton setEnabled:NO];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  NSUInteger count = 0;
  if (aTableView == foundClipboardsView) {
    count = [foundCloudboards count];
  }
  if (aTableView == registeredClipboardsView) {
    count = [registeredClipboards count];
  }
  return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
  id object = nil;
  if (aTableView == foundClipboardsView) {
    object = [foundCloudboards objectAtIndex:rowIndex];
  }
  if (aTableView == registeredClipboardsView) {
    object = [registeredClipboards objectAtIndex:rowIndex];
  }
  NSString* substring = [object substringFromIndex:10];
  return substring;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
  if ([aNotification object] == foundClipboardsView) {
    if ([foundClipboardsView numberOfSelectedRows] != 0) {
      [addButton setEnabled:YES];
    }
    else {
      [addButton setEnabled:NO];
    }
  }
  
  if ([aNotification object] == registeredClipboardsView) {
    if ([registeredClipboardsView numberOfSelectedRows] != 0) {
      [removeButton setEnabled:YES];
    }
    else {
      [removeButton setEnabled:NO];
    }
  }
}

//CBSyncControllerDelegate
- (void)clientBecameVisible:(NSString*)clientName {
  if(([foundCloudboards containsObject:clientName] == NO) && ([registeredClipboards containsObject:clientName] == NO)) {
    [foundCloudboards addObject:clientName];
    [foundClipboardsView reloadData];
  }
}

- (void)clientBecameInvisible:(NSString*)clientName {
  if([foundCloudboards containsObject:clientName]) {
    [foundCloudboards removeObject:clientName];
    [foundClipboardsView reloadData];
  }
}

- (void)clientConnected:(NSString*)clientName {
}

- (void)clientDisconnected:(NSString*)clientName {
}

- (void)clientConfirmed:(NSString*)clientName {
}

@end
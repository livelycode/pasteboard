#import "Cloudboard.h"

#define TEXT_PADDING 12
#define BUTTON_PADDING 8
#define BUTTON_LENGTH 16

@implementation CBItemView

- (void)mouseDown:(NSEvent *)theEvent
{
    [delegate itemViewClicked:self];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSData *imageData = [self dataWithPDFInsideRect:[self bounds]];
    NSImage *dragImage = [[NSImage alloc] initWithData:imageData];
    NSPoint leftBottom = [self bounds].origin;
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
        
    [self dragImage:dragImage
                 at:leftBottom
             offset:NSZeroSize
              event:theEvent
         pasteboard:pasteboard
             source:self
          slideBack:YES];
    
    [delegate itemView:self startedDragWithPasteboard:pasteboard];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationMove;
}

- (BOOL)ignoreModifierKeysWhileDragging
{
    return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSLog(@"enter");
    return [sender draggingSourceOperationMask];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    NSLog(@"exit");
}

- (id)initWithFrame:(NSRect)aRect;
{
    self = [super initWithFrame:aRect];
    if (self != nil)
    {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeString]];
        
        textField = [[NSTextField alloc] initWithFrame:CGRectZero];
        [textField setBordered:NO];
        [textField setBackgroundColor:[NSColor clearColor]];
        [textField setSelectable:NO];
        [self addSubview:textField];
        
        button = [[NSButton alloc] initWithFrame:CGRectZero];
        [button setImage:[NSImage imageNamed:NSImageNameStopProgressTemplate]];
        [button setButtonType:NSMomentaryChangeButton];
        [button setBordered:NO];
        [[button cell] setImageScaling:NSImageScaleProportionallyDown];
        [button setAction:@selector(dismiss)];
        [button setTarget:self];
        [self addSubview:button];	
        
        NSShadow *pageShadow = [[NSShadow alloc] init];
        [pageShadow setShadowColor:[NSColor colorWithCalibratedWhite:0
                                                               alpha:0.5]];
        [pageShadow setShadowBlurRadius:2];
        [pageShadow setShadowOffset:CGSizeMake(0, -4)];
        [self setShadow:pageShadow];
        
        NSColor *startingColor = [NSColor colorWithCalibratedRed:0.9
                                                         green:0.8
                                                          blue:0.3
                                                         alpha:1];
        NSColor *endingColor = [NSColor colorWithCalibratedRed:0.9
                                                           green:0.8
                                                            blue:0.4
                                                           alpha:1];
        gradient = [[NSGradient alloc] initWithStartingColor:startingColor
                                                 endingColor:endingColor];
        
        
    }
    return self;
}

- (void)setDelegate:(id <CBItemViewDelegate>)anObject
{
    delegate = anObject;
}

- (void)setText:(NSAttributedString *)aString;
{
    string = aString;
    [self setNeedsDisplay:YES];
}

- (void)setVisible:(BOOL)isVisible
{
    if (isVisible)
    {
        [self setAlphaValue:1];
    }
    else
    {
        [self setAlphaValue:0];
    }
}

- (void)drawRect:(NSRect)aRect
{
    CGRect viewBounds = [self bounds];
    NSPoint leftBottom = NSMakePoint(viewBounds.origin.x, viewBounds.origin.y);
    NSPoint leftTop = NSMakePoint(viewBounds.origin.x, viewBounds.size.height);
    NSPoint rightBottom = NSMakePoint(viewBounds.size.width, viewBounds.origin.y);
    NSPoint rightTop = NSMakePoint(viewBounds.size.width, viewBounds.size.height);
    
    CGFloat textWidth = viewBounds.size.width - (2 * TEXT_PADDING);
    CGFloat textHeight = viewBounds.size.height - (2 * TEXT_PADDING);
    CGFloat textX = TEXT_PADDING;
    CGFloat textY = TEXT_PADDING;
    [textField setFrame:CGRectMake(textX, textY, textWidth, textHeight)];
    [textField setAttributedStringValue:string];
    [textField setNeedsDisplay:YES];
    
    CGFloat buttonWidth = BUTTON_LENGTH;
    CGFloat buttonHeight = BUTTON_LENGTH;
    CGFloat buttonX = viewBounds.size.width - BUTTON_LENGTH - BUTTON_PADDING;
    CGFloat buttonY = viewBounds.size.height - BUTTON_LENGTH - BUTTON_PADDING;;
    [button setFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:leftBottom];
    [path lineToPoint:rightBottom];
    [path lineToPoint:rightTop];
    [path lineToPoint:leftTop];
    [path lineToPoint:leftBottom];
    [path closePath];
    [gradient drawInBezierPath:path
                         angle:90];
}

@end

@implementation CBItemView(Private)

- (void)dismiss
{
    [delegate itemViewDismissButtonClicked:self];
}

@end
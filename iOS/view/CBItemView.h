#import "Cocoa.h"
#import "CBItemViewDelegate.h"

@interface CBItemView : UIView
{
  @private
  id delegate;
  NSString* string;
  NSMutableArray *animationLayers;
}

- (id)initWithFrame:(CGRect)aRect content:(NSString*)content delegate:(id <CBItemViewDelegate>)anObject;
- (void)moveToFrame:(CGRect)frame;
@end

@interface CBItemView(Overridden)


@end

@interface CBItemView(Delegation)
- (void)handleTap:(UITapGestureRecognizer*)recognizer;
@end

@interface CBItemView(Private)

@end
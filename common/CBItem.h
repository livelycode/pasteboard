#import "Cocoa.h"

@interface CBItem : NSObject
{
    @private
    NSString *string;
}

+ (id)itemWithString:(NSString*)aString;

- (id)initWithString:(NSString *)aString;

- (id)initWithAttributedString:(NSAttributedString *)aString;

- (NSString *)string;

- (BOOL)isEqual:(id)anObject;

- (NSUInteger)hash;

@end
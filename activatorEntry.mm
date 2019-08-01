#import "ActivatorEntry.h"

@implementation ActivatorEntry
- (NSString *)localizedTitleForEventName:(NSString *)eventName {
        return self.eventTitle;
}
- (NSString *)localizedGroupForEventName:(NSString *)eventName {
        return @"NFC";
}
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
        return self.eventDescription;
}
@end
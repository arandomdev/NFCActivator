#import <libactivator/libactivator.h>

@interface ActivatorEntry : NSObject <LAEventDataSource>
@property (nonatomic, retain) NSString *eventTitle;
@property (nonatomic, retain) NSString *eventDescription;
- (NSString *)localizedTitleForEventName:(NSString *)eventName;
- (NSString *)localizedGroupForEventName:(NSString *)eventName;
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName;
@end

//git test ignore this
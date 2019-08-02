#import "NAPViewDismissCallbackProtocol.h"

@interface NAPDiscoveryViewController : UIViewController
@property (nonatomic, weak) id<NAPViewDismissCallbackProtocol> delegate;
@property (nonatomic, retain) NSMutableDictionary
- (id)initWithEntry:(NSMutableDictionary *)entry;
- (void)loadView;
@end
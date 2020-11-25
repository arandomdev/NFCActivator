#import "NAPViewDismissCallbackProtocol.h"
#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface NAPDiscoveryViewController : UIViewController{
    CPDistributedMessagingCenter * _messagingCenter;
}
@property (nonatomic, weak) id<NAPViewDismissCallbackProtocol> delegate;
@property (nonatomic, retain) NSMutableDictionary *entry;
- (id)initWithEntry:(NSMutableDictionary *)entry;
- (void)loadView;
@end

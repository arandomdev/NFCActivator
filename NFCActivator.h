#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface NFCActivator : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
    CPDistributedMessagingCenter * _tagDiscoveryMessagingCenter;
}
@property (nonatomic, retain) NSArray *nfcActivatorEntrys;
+(id)sharedInstance;
-(void)reloadNFCActivatorEntrys;
@end

#import <Cephei/HBPreferences.h>
#import "ActivatorEntry.h"
#import "NFCActivator.h"

static BOOL discoveringTag = NO;

static void discoverCallback(){
    discoveringTag = YES;
}

static void reloadNFCActivatorEntrysCallback(){
    [[%c(NFCActivator) sharedInstance] reloadNFCActivatorEntrys];
}

@implementation NFCActivator

+(void)load{
    [self sharedInstance];
}

+(id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

-(instancetype)init{
    if ((self = [super init])){
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.haotestlabs.nfcactivator.center"];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
        [_messagingCenter runServerOnCurrentThread];
        [_messagingCenter registerForMessageName:@"nfcActivatorDetectedTags" target:self selector:@selector(nfcActivatorDetectedTags:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"reloadNFCActivatorEntrys" target:self selector:@selector(reloadNFCActivatorEntrys:withUserInfo:)];
        
        _tagDiscoveryMessagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.haotestlabs.nfcactivator.tagdiscover.center"];
        rocketbootstrap_distributedmessagingcenter_apply(_tagDiscoveryMessagingCenter);
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)discoverCallback, CFSTR("com.haotestlabs.nfcactivator.discover"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadNFCActivatorEntrysCallback, CFSTR("com.haotestlabs.nfcactivator.reload"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
        
        [self reloadNFCActivatorEntrys];
    }
    return self;
}

-(NSDictionary *)reloadNFCActivatorEntrys:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    [self reloadNFCActivatorEntrys];
    return nil;
}

-(void)reloadNFCActivatorEntrys{
    for (NSDictionary *entry in self.nfcActivatorEntrys){
        [LASharedActivator unregisterEventDataSourceWithEventName:entry[@"name"]];
    }
    
    NSArray *entrys = [[[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"] objectForKey:@"NFCActivatorEntrys"];
    for (NSDictionary *entry in entrys) {
        ActivatorEntry *eventData = [[ActivatorEntry alloc] init];
        eventData.eventTitle = entry[@"title"];
        eventData.eventDescription = entry[@"description"];
        [LASharedActivator registerEventDataSource:eventData forEventName:entry[@"name"]];
    }
    self.nfcActivatorEntrys = entrys;
}

-(NSDictionary *)nfcActivatorDetectedTags:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    NSString *uid = userInfo[@"data"][0][@"uid"];
    [self handleNfcActivatorDetectedTag:uid];
    
    if (discoveringTag){
        [_tagDiscoveryMessagingCenter sendMessageAndReceiveReplyName:@"detectedTags" userInfo:userInfo];
        discoveringTag = NO;
    }
    
    return nil;
}

-(void)handleNfcActivatorDetectedTag:(NSString *)uid{
    for (NSDictionary *entry in self.nfcActivatorEntrys) {
        if ([entry[@"tags"] containsObject:uid]) {
            LAEvent *event = [LAEvent eventWithName:entry[@"name"] mode:[LASharedActivator currentEventMode]];
            [LASharedActivator sendEventToListener:event];
        }
    }
}

@end

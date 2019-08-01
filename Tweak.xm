#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <Cephei/HBPreferences.h>
#import "ActivatorEntry.h"

@interface SpringBoard
@property (nonatomic, retain) NSArray *registeredEventNames;
+ (id)sharedApplication;
- (void)applicationOpenURL:(NSURL *)arg1;
@end

@interface SBApplicationInfo
-(NSUserDefaults *)userDefaults;
@end

@interface SBApplication
-(SBApplicationInfo *)info;
@end

@interface SBApplicationController
+(id)sharedInstance;
+(id)sharedInstanceIfExists;
-(SBApplication *)applicationWithBundleIdentifier:(NSString *)arg1;
@end

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void nfcActivatorDetectedTags(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
	NSDictionary *userInfo = (__bridge NSDictionary *)data;
	NSString *uid = userInfo[@"data"][0][@"uid"];

	NSDictionary *entrys = [[[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"] objectForKey:@"NFCActivatorEntrys"];
	if (!entrys) {
		return;
	}

	for (NSString *name in entrys) {
		if ([entrys[name][@"tags"] containsObject:uid]) {
			LAEvent *event = [LAEvent eventWithName:entrys[name][@"eventName"] mode:[LASharedActivator currentEventMode]];
			[LASharedActivator sendEventToListener:event];
		}
	}
}

%hook SpringBoard
%property (nonatomic, retain) NSArray *registeredEventNames;
- (id)init {
	id orig = %orig;
	
	NSDictionary *entrys = [[[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"] objectForKey:@"NFCActivatorEntrys"];
	NSMutableArray *eventNames = [NSMutableArray new];
	if (entrys) {
		for (NSString *name in entrys) {
			ActivatorEntry *eventData = [[ActivatorEntry alloc] init];
			eventData.eventTitle = name;
			eventData.eventDescription = entrys[name][@"description"];
			[LASharedActivator registerEventDataSource:eventData forEventName:entrys[name][@"eventName"]];
			[eventNames addObject:entrys[name][@"eventName"]];
		}
	}
	self.registeredEventNames = [eventNames copy];
	
	CPDistributedMessagingCenter * messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.haotestlabs.nfcactivator"];
	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
	[messagingCenter runServerOnCurrentThread];
	[messagingCenter registerForMessageName:@"reregister" target:orig selector:@selector(reregisterCommandForName:)];
	
	CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	CFNotificationCenterAddObserver(center, NULL, nfcActivatorDetectedTags, CFSTR("nfcbackground.newtag"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	return orig;
}

%new
- (void)reregisterCommandForName:(NSString *)name {
	for (NSString *eventName in self.registeredEventNames) {
		[LASharedActivator unregisterEventDataSourceWithEventName:eventName];
	}

	NSDictionary *entrys = [[[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"] objectForKey:@"NFCActivatorEntrys"];
	NSMutableArray *eventNames = [NSMutableArray new];
	if (entrys) {
		for (NSString *name in entrys) {
			ActivatorEntry *eventData = [[ActivatorEntry alloc] init];
			eventData.eventTitle = name;
			eventData.eventDescription = entrys[name][@"description"];
			[LASharedActivator registerEventDataSource:eventData forEventName:entrys[name][@"eventName"]];
			[eventNames addObject:entrys[name][@"eventName"]];
		}
	}
	self.registeredEventNames = [eventNames copy];
}
%end
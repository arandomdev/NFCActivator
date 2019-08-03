#import <Cephei/HBPreferences.h>
#import "ActivatorEntry.h"

@interface SpringBoard
@property (nonatomic, retain) NSArray *nfcActivatorEntrys;
+ (id)sharedApplication;
- (void)reloadNFCActivatorEntrys;
@end

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void nfcActivatorDetectedTags(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
	NSDictionary *userInfo = (__bridge NSDictionary *)data;
	NSString *uid = userInfo[@"data"][0][@"uid"];

	NSArray *entrys = [[%c(SpringBoard) sharedApplication] nfcActivatorEntrys];
	for (NSDictionary *entry in entrys) {
		if ([entry[@"tags"] containsObject:uid]) {
			LAEvent *event = [LAEvent eventWithName:entry[@"name"] mode:[LASharedActivator currentEventMode]];
			[LASharedActivator sendEventToListener:event];
		}
	}
}

void nfcActivatorReloadEntrys(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
	[[%c(SpringBoard) sharedApplication] reloadNFCActivatorEntrys];
}

%hook SpringBoard
%property (nonatomic, retain) NSArray *nfcActivatorEntrys;
- (id)init {
	id orig = %orig;
	
	CFNotificationCenterRef tagCenter = CFNotificationCenterGetDistributedCenter();
	CFNotificationCenterAddObserver(tagCenter, NULL, nfcActivatorDetectedTags, CFSTR("nfcbackground.newtag"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	
	CFNotificationCenterRef reloadCenter = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(reloadCenter, NULL, nfcActivatorReloadEntrys, CFSTR("com.haotestlabs.nfcactivator.reload"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	[orig reloadNFCActivatorEntrys];
	return orig;
}

%new
- (void)reloadNFCActivatorEntrys {
	for (NSDictionary *entry in self.nfcActivatorEntrys) {
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
%end
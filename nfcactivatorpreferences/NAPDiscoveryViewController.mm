#import "NAPDiscoveryViewController.h"
extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void detectedTags(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
    NSDictionary *userInfo = (__bridge NSDictionary *)data;
	NSString *uid = userInfo[@"data"][0][@"uid"];
    NAPDiscoveryViewController *controller = (__bridge NAPDiscoveryViewController *)observer;

    NSArray *tags = controller.entry[@"tags"];
    if (![tags containsObject:uid]) {
        [entry setObject:[tags arrayByAddingObject:uid] forKey:@"tags"];
    }

    [observer dismissView];
}

@implementation NAPDiscoveryViewController
- (id)initWithEntry:(NSMutableDictionary *)entry {
    self = [super init];
    if (self) {
        self.entry = entry;

        CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	    CFNotificationCenterAddObserver(center, (__bridge void *)self, detectedTags, CFSTR("nfcbackground.newtag"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIlabel *textLabel = [[UIlabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    textLabel.text = @"Scan Now";
    textLabel.Alignment = NSTextAlignmentCenter;
    textLabel.center = self.view.center;
}
- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];

    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	CFNotificationCenterRemoveObserver(center, (__bridge void *)self, CFSTR("nfcbackground.newtag"), NULL);

    if (self.delegate) {
        [self.delegate viewDismissed];
    }
}
@end
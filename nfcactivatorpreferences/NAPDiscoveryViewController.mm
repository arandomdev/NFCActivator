#import "NAPDiscoveryViewController.h"
extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void detectedTags(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
    NSDictionary *userInfo = (__bridge NSDictionary *)data;
	NSString *uid = userInfo[@"data"][0][@"uid"];
    NAPDiscoveryViewController *controller = (__bridge NAPDiscoveryViewController *)observer;

    NSArray *tags = controller.entry[@"tags"];
    if (![tags containsObject:uid]) {
        [controller.entry setObject:[tags arrayByAddingObject:uid] forKey:@"tags"];
    }

    [controller dismissView];
}

@implementation NAPDiscoveryViewController
- (id)initWithEntry:(NSMutableDictionary *)entry {
    self = [super init];
    if (self) {
        self.entry = entry;

        CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	    CFNotificationCenterAddObserver(center, (__bridge void *)self, detectedTags, CFSTR("nfcbackground.newtag"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    textLabel.text = @"Scan Now";
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.center = self.view.center;
    [self.view addSubview:textLabel];
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
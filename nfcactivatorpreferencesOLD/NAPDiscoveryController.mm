#import "NAPDiscoveryController.h"
extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void detectedTags(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
    NSDictionary *userInfo = (__bridge NSDictionary *)data;
	NSString *uid = userInfo[@"data"][0][@"uid"];
    NAPDiscoveryController *controller = (__bridge NAPDiscoveryController *)observer;

    NSMutableDictionary *entry = [controller.delegate.eventEntry mutableCopy];
    if (![entry[@"tags"] containsObject:uid]) {
        NSMutableArray *tags = [entry[@"tags"] mutableCopy];
        [tags addObject:uid];
        [entry setObject:tags forKey:@"tags"];

        controller.delegate.eventEntry = [entry copy];
        dispatch_async(dispatch_get_main_queue(), ^{
  	        [controller.delegate.tableView reloadData];
	    });
    }

    [controller dismissView];
}

@implementation NAPDiscoveryController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    textLabel.text = @"Scan Now";
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.center = self.view.center;
    [self.view addSubview:textLabel];

    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	CFNotificationCenterAddObserver(center, (__bridge void *)self, detectedTags, CFSTR("nfcbackground.newtag"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
- (void)dismissView {
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	CFNotificationCenterRemoveObserver(center, (__bridge void *)self, CFSTR("nfcbackground.newtag"), NULL);

    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
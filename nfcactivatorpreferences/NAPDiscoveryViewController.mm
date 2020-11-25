#import "NAPDiscoveryViewController.h"

@implementation NAPDiscoveryViewController
- (id)initWithEntry:(NSMutableDictionary *)entry {
    if (self = [super init]) {
        self.entry = entry;
        
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.haotestlabs.nfcactivator.tagdiscover.center"];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
        [_messagingCenter runServerOnCurrentThread];
        [_messagingCenter registerForMessageName:@"detectedTags" target:self selector:@selector(detectedTags:withUserInfo:)];
        
    }
    return self;
}

-(NSDictionary *)detectedTags:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    
    NSString *uid = userInfo[@"data"][0][@"uid"];
    
    if (![self.entry[@"tags"] containsObject:uid]) {
        [self.entry setObject:[self.entry[@"tags"] arrayByAddingObject:uid] forKey:@"tags"];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return nil;
}

- (void)loadView {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.haotestlabs.nfcactivator.discover"), NULL, NULL, YES);
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    textLabel.text = @"Scan Now";
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.center = self.view.center;
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            textLabel.textColor = [UIColor blackColor];
        }else {
            textLabel.textColor = [UIColor whiteColor];
        }
    }
    [self.view addSubview:textLabel];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_messagingCenter stopServer];
}
@end

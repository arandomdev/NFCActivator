#import "NAPEntryEditController.h"

@interface NAPDiscoveryController : UIViewController
@property (nonatomic, retain) NAPEntryEditController *delegate;
- (void)viewDidLoad;
- (void)dismissView;
@end
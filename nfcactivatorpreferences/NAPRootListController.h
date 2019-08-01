#import <Preferences/PSListController.h>

@interface NAPRootListController : PSListController
@property (nonatomic, retain) HBPreferences *userDefaults;
@property (readonly) NSDictionary *eventEntrys;
- (NSArray *)specifiers;
- (NSDictionary *)eventEntrys;
- (void)viewDidLoad;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
@end

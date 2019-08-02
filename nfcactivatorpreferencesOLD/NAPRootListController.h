#import <Preferences/PSListController.h>
//#import <Preferences/PSViewController.h>

@interface NAPRootListController : PSListController //<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) HBPreferences *userDefaults;
@property (readonly) NSDictionary *eventEntrys;
//@property (nonatomic, retain) UITableView *tableView;
- (NSArray *)specifiers;
- (NSDictionary *)eventEntrys;
- (void)viewDidLoad;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
@end

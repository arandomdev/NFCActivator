#import <Preferences/PSViewController.h>
#import "NAPViewDismissCallbackProtocol.h"

@interface NAPRootViewController : PSViewController <UITableViewDataSource, UITableViewDelegate, NAPViewDismissCallbackProtocol>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *entrys;
- (id)init;
- (void)loadView;
- (void)reloadEntrys;
- (void)addButtonPressed;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)viewDismissed;
@end

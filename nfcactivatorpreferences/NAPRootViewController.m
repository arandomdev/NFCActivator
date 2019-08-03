#import <Cephei/HBPreferences.h>
#import "NAPRootViewController.h"
#import "NAPEditViewController.h"

@implementation NAPRootViewController
- (id)init {
    self = [super init];
    if (self) {
        [self reloadEntrys];
    }
    return self;
}
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.title = @"NFCActivator";

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
}
- (void)reloadEntrys {
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"];
    self.entrys = [preferences objectForKey:@"NFCActivatorEntrys"];
    if (!self.entrys) {
        [preferences setObject:[NSArray new] forKey:@"NFCActivatorEntrys"];
        self.entrys = [preferences objectForKey:@"NFCActivatorEntrys"];
    }
}
- (void)addButtonPressed {
    NAPEditViewController *editController = [[NAPEditViewController alloc] initWithEntry:nil];
    editController.delegate = self;
    [self.navigationController pushViewController:editController animated:YES];
}

#pragma mark UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Registered Events";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFCActivatorEntryCells"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NFCActivatorEntryCells"];
	}

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *name = self.entrys[indexPath.row][@"title"];
    NSString *description = self.entrys[indexPath.row][@"description"];
    cell.textLabel.text = name;
    cell.detailTextLabel.text = description;

    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entrys.count;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *entry = self.entrys[indexPath.row];
    NAPEditViewController *editController = [[NAPEditViewController alloc] initWithEntry:[entry mutableCopy]];
    editController.delegate = self;
    [self.navigationController pushViewController:editController animated:YES];
}

#pragma mark NAPViewDismissCallbackProtocol
- (void)viewDismissed {
    [self reloadEntrys];
    [self.tableView reloadData];
}
@end

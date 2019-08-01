#import <Cephei/HBPreferences.h>
#include "NAPRootListController.h"
#import "NAPEntryEditController.h"

@implementation NAPRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (NSDictionary *)eventEntrys {
	return [self.userDefaults objectForKey:@"NFCActivatorEntrys"];
}

- (void)viewDidLoad {
	self.userDefaults = [[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"];;
	if (!self.eventEntrys) {
		[self.userDefaults setObject:[NSDictionary new] forKey:@"NFCActivatorEntrys"];
	}

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed)];
	self.navigationItem.rightBarButtonItem = addButton;

	self.title = @"NFCActivator";
}

- (void)addButtonPressed {
	NAPEntryEditController *editController = [[NAPEntryEditController alloc] initWithName:nil entry:nil];
	[self.navigationController pushViewController:editController animated:YES];
}

# pragma mark UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Registered Events";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HBLogDebug(@"called cell");
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFCActivatorEntryCells"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NFCActivatorEntryCells"];
	}

	NSArray *entrys = [[self.eventEntrys allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	NSString *name = entrys[indexPath.row];
	cell.textLabel.text = name;
	cell.accessoryType = UITableViewCellAccessoryDetailButton;
	return cell;
}
- (NSInteger)numberOfRowsInSection:(NSInteger)section {
	HBLogDebug(@"called number of rows");
	return self.eventEntrys.count;
}

# pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSArray *entryKeys = [[self.eventEntrys allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	NSString *name = entryKeys[indexPath.row];
	NSDictionary *entry = self.eventEntrys[name];
	NAPEntryEditController *editController = [[NAPEntryEditController alloc] initWithName:name entry:entry];
	[self.navigationController pushViewController:editController animated:YES];
}
@end

#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <Cephei/HBPreferences.h>
#import "NAPEntryEditController.h"
#import "NAPDiscoveryController.h"

@implementation NAPEntryEditController
- (id)initWithName:(NSString *)name entry:(NSDictionary *)entry {
    self = [super init];
    if (self) {
        self.eventName = name;
        if (entry) {
            self.eventEntry = entry;
        }
        else {
            self.eventEntry = @{@"tags" : [NSArray new]};
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];

    self.title = @"Configure Event";
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
}
- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)doneButtonPressed {
    if (self.nameInput.text.length == 0) {
        [self.nameInput becomeFirstResponder];
        return;
    }
    else if (self.descriptionInput.text.length == 0) {
        [self.descriptionInput becomeFirstResponder];
        return;
    }
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"];
    if (!self.eventName) {
        NSString *uniqueName = [@"com.haotestlabs.nfcactivator." stringByAppendingString:[[NSProcessInfo processInfo] globallyUniqueString]];
        NSDictionary *newEntry = @{@"description" : self.descriptionInput.text, @"eventName" : uniqueName, @"tags" : self.eventEntry[@"tags"]};

        NSDictionary *entrys = [preferences objectForKey:@"NFCActivatorEntrys"];
        NSMutableDictionary *updatedEntrys = [entrys mutableCopy];
        [updatedEntrys setObject:newEntry forKey:self.nameInput.text];
        [preferences setObject:updatedEntrys forKey:@"NFCActivatorEntrys"];
    }
    else {
        NSDictionary *entrys = [preferences objectForKey:@"NFCActivatorEntrys"];
        NSMutableDictionary *updatedEntrys = [entrys mutableCopy];
        [updatedEntrys removeObjectForKey:self.eventName];

        NSString *uniqueName = [@"com.haotestlabs.nfcactivator." stringByAppendingString:[[NSProcessInfo processInfo] globallyUniqueString]];
        NSDictionary *newEntry = @{@"description" : self.descriptionInput.text, @"eventName" : uniqueName, @"tags" : self.eventEntry[@"tags"]};
        [updatedEntrys setObject:newEntry forKey:self.nameInput.text];
        [preferences setObject:updatedEntrys forKey:@"NFCActivatorEntrys"];
    }
    CPDistributedMessagingCenter *messagingCenter;
    messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.haotestlabs.nfcactivator"];
    rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
    [messagingCenter sendMessageName:@"reregister" userInfo:nil];

    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Name";
            break;
        case 1:
            return @"Description";
            break;
        case 2:
            return @"Tags";
            break;
        default:
            return nil;
            break;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFCActivatorEditCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NFCActivatorEditCell"];
    }

    if (indexPath.section == 0) {
        if (!self.nameInput) {
            UITextField *inputField = [[UITextField alloc] initWithFrame:cell.frame];
            inputField.adjustsFontSizeToFitWidth = YES;
            inputField.placeholder = @"Name Of Event";
            inputField.autocorrectionType = UITextAutocorrectionTypeNo;
            inputField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            inputField.textAlignment = NSTextAlignmentLeft;
            if (self.eventName) {
                inputField.text = self.eventName;
            }
            self.nameInput = inputField;
        }
        
        [cell.contentView addSubview:self.nameInput];
    }
    else if (indexPath.section == 1) {
        if (!self.descriptionInput) {
            UITextField *inputField = [[UITextField alloc] initWithFrame:cell.frame];
            inputField.adjustsFontSizeToFitWidth = YES;
            inputField.placeholder = @"Description Of Event";
            inputField.autocorrectionType = UITextAutocorrectionTypeYes;
            inputField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            inputField.textAlignment = NSTextAlignmentLeft;
            if (self.eventName) {
                inputField.text = self.eventEntry[@"description"];
            }
            self.descriptionInput = inputField;
        }

        [cell.contentView addSubview:self.descriptionInput];        
    }
    else if (indexPath.section == 2) {
        cell.textLabel.text = @"Scan Tag";
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:0 green:0.478 blue:1 alpha:1];
    }
    else if (indexPath.section == 3) {
        if (self.eventEntry) {
            cell.textLabel.text = self.eventEntry[@"tags"][indexPath.row];
        }
    }
    else if (indexPath.section == 4) {
        cell.textLabel.text = @"Delete Event";
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:1 green:0.231 blue:188 alpha:1];
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3) {
        if (self.eventEntry) {
            NSArray *tags = self.eventEntry[@"tags"];
            return tags.count;
        }
        else {
            return 0;
        }
    }
    else if (section == 4) {
        if (self.eventName) {
            return 1;
        }
        else {
            return 0;
        }
    }
    else {
        return 1;
    }
}

# pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        NAPDiscoveryController *discoveryPage = [[NAPDiscoveryController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:discoveryPage];
	    [navController setToolbarHidden:YES animated:NO];

	    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:discoveryPage action:@selector(dismissView)];
	    discoveryPage.navigationItem.leftBarButtonItem = dismissButton;
	    [navController setNavigationBarHidden:NO];

	    [self presentViewController:navController animated:YES completion:nil];
    }
    else if (indexPath.section == 4) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Event" message:@"Are you sure that you want to delete this event?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (self.eventName) {
                HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"];
                NSDictionary *entrys = [preferences objectForKey:@"NFCActivatorEntrys"];
                NSMutableDictionary *updatedEntrys = [entrys mutableCopy];
                [updatedEntrys removeObjectForKey:self.eventName];
                [preferences setObject:updatedEntrys forKey:@"NFCActivatorEntrys"];
                
                CPDistributedMessagingCenter *messagingCenter;
                messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.haotestlabs.nfcactivator"];
                rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
                [messagingCenter sendMessageName:@"reregister" userInfo:nil];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:deleteAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
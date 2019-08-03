#import <Cephei/HBPreferences.h>
#import "NAPEditViewController.h"
#import "NAPDiscoveryViewController.h"

@implementation NAPEditViewController
- (id)initWithEntry:(NSMutableDictionary *)entry {
    self = [super init];
    if (self) {
        if (entry) {
            self.entry = entry;
            self.isNewEntry = NO;
        }
        else {
            self.entry = [@{@"tags" : [NSArray new]} mutableCopy];
            self.isNewEntry = YES;
        }
    }
    return self;
}
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.title = @"Event Editor";

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.view addSubview:self.tableView];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;

}
- (void)doneButtonPressed {
    if (self.titleTextField.text.length == 0) {
        [self.titleTextField becomeFirstResponder];
        return;
    }
    else if (self.descriptionTextField.text.length == 0) {
        [self.descriptionTextField becomeFirstResponder];
        return;
    }

    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"];
    NSArray *entrys = [preferences objectForKey:@"NFCActivatorEntrys"];

    if (self.isNewEntry) {
        NSString *uniqueName = [@"com.haotestlabs.nfcactivator." stringByAppendingString:[[NSProcessInfo processInfo] globallyUniqueString]];
        [self.entry setObject:uniqueName forKey:@"name"];
        [self.entry setObject:self.titleTextField.text forKey:@"title"];
        [self.entry setObject:self.descriptionTextField.text forKey:@"description"];

        NSArray *updatedEntrys = [entrys arrayByAddingObject:[self.entry copy]];
        [preferences setObject:updatedEntrys forKey:@"NFCActivatorEntrys"];
    }
    else {
        NSString *eventName = self.entry[@"name"];
        for (int i = 0; i < entrys.count; i++) {
            if ([entrys[i][@"name"] isEqual:eventName]) {
                NSMutableArray *updatedEntrys = [entrys mutableCopy];
                [updatedEntrys removeObjectAtIndex:i];
                [updatedEntrys addObject:[self.entry copy]];

                [preferences setObject:[updatedEntrys copy] forKey:@"NFCActivatorEntrys"];
                break;
            }
        }
    }

    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification(center, CFSTR("com.haotestlabs.nfcactivator.reload"), NULL, NULL, TRUE);

    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate) {
        [self.delegate viewDismissed];
    }
}
- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate) {
        [self.delegate viewDismissed];
    }
}

#pragma mark UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Title";
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFCActivatorEditCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NFCActivatorEditCell"];
    }

    if (indexPath.section == 0) {
        if (!self.titleTextField) {
            UITextField *titleInput = [[UITextField alloc] initWithFrame:cell.contentView.bounds];
            titleInput.center = CGPointMake(titleInput.center.x + 15, titleInput.center.y);

            titleInput.textAlignment = NSTextAlignmentLeft;
            titleInput.placeholder = @"Title Of Event";
            titleInput.clearButtonMode = UITextFieldViewModeNever;
            titleInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
            titleInput.autocorrectionType = UITextAutocorrectionTypeNo;
            titleInput.delegate = self;
            if (!self.isNewEntry) {
                titleInput.text = self.entry[@"title"];
            }
            self.titleTextField = titleInput;
        }
        [cell.contentView addSubview:self.titleTextField];
    }
    else if (indexPath.section == 1) {
        if (!self.descriptionTextField) {
            UITextField *descriptionInput = [[UITextField alloc] initWithFrame:cell.contentView.bounds];
            descriptionInput.center = CGPointMake(descriptionInput.center.x + 15, descriptionInput.center.y);

            descriptionInput.textAlignment = NSTextAlignmentLeft;
            descriptionInput.placeholder = @"Description of event";
            descriptionInput.clearButtonMode = UITextFieldViewModeNever;
            descriptionInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            descriptionInput.autocorrectionType = UITextAutocorrectionTypeYes;
            descriptionInput.delegate = self;
            if (!self.isNewEntry) {
                descriptionInput.text = self.entry[@"description"];
            }
            self.descriptionTextField = descriptionInput;
        }
        [cell.contentView addSubview:self.descriptionTextField];
    }
    else if (indexPath.section == 2) {
        cell.textLabel.text = @"Start Scanning";
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:0 green:0.478 blue:1 alpha:1];
    }
    else if (indexPath.section == 3) {
        cell.textLabel.text = self.entry[@"tags"][indexPath.row];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else if (indexPath.section == 4) {
        cell.textLabel.text = @"Delete";
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:1 green:0.231 blue:0.188 alpha:1];
    }

    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isNewEntry) {
        return 4;
    }
    else {
        return 5;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3) {
        return [self.entry[@"tags"] count];
    }
    else {
        return 1;
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 2) {
        NAPDiscoveryViewController *discoveryController = [[NAPDiscoveryViewController alloc] initWithEntry:self.entry];
        discoveryController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:discoveryController];

        [navController setToolbarHidden:YES animated:NO];
        [navController setNavigationBarHidden:NO];
        UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:discoveryController action:@selector(dismissView)];
        
        discoveryController.navigationItem.leftBarButtonItem = stopButton;

        [self presentViewController:navController animated:YES completion:nil];
    }
    else if (indexPath.section == 4) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Event" message:@"Are you sure that you want to delete this event?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSString *eventName = self.entry[@"name"];
            HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"];
            NSArray *entrys = [preferences objectForKey:@"NFCActivatorEntrys"];

            for (int i = 0; i < entrys.count; i++) {
                if ([entrys[i][@"name"] isEqual:eventName]) {
                    NSMutableArray *updatedEntrys = [entrys mutableCopy];
                    [updatedEntrys removeObjectAtIndex:i];
                    [preferences setObject:[updatedEntrys copy] forKey:@"NFCActivatorEntrys"];
                    break;
                }
            }

            CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
	        CFNotificationCenterPostNotification(center, CFSTR("com.haotestlabs.nfcactivator.reload"), NULL, NULL, TRUE);

            [self.navigationController popViewControllerAnimated:YES];
            if (self.delegate) {
                [self.delegate viewDismissed];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:deleteAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 3) {
        return nil;
    }

    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		NSMutableArray *tags = [self.entry[@"tags"] mutableCopy];
        [tags removeObjectAtIndex:indexPath.row];
        [self.entry setObject:tags forKey:@"tags"];

        [self.tableView reloadData];

		completionHandler(YES);
	}];

	UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
	return config;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.titleTextField]) {
        [self.descriptionTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark NAPViewDismissCallbackProtocol
- (void)viewDismissed {
    [self.tableView reloadData];
}
@end
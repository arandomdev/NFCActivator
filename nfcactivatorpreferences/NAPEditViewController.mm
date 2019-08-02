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
            self.entry = @{@"tags" : [NSArray new]};
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
                NSMutableDictionary *updatedEntrys = [entrys mutableCopy];
                [updatedEntrys removeObjectAtIndex:i];
                [updatedEntrys addObject:[self.entry copy]];

                [preferences setObject:[updatedEntrys copy] forKey:@"NFCActivatorEntrys"];
                break;
            }
        }
    }

    // TODO: send notification
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
            titleInput.textAlignment = NSTextAlignmentLeft;
            titleInput.placeholder = @"Title Of Event";
            titleInput.clearButtonMode = UITextFieldViewModeWhileEditing;
            titleInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
            titleInput.autocorrectionType = UITextAutocorrectionTypeNo;
            titleInput.delegate = self;
            if (!self.isNewEntry) {
                titleInput.text = self.entry[@"title"];
            }
        }
        [cell.contentView addSubview:self.titleTextField];
    }
    else if (indexPath.section == 1) {
        if (!self.descriptionTextField) {
            UITextField *descriptionInput = [[UITextField alloc] initWithFrame:cell.contentView.bounds];
            descriptionInput.textAlignment = NSTextAlignmentLeft;
            descriptionInput.placeholder = @"Description of event";
            descriptionInput.clearButtonMode = UITextFieldViewModeWhileEditing;
            descriptionInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            descriptionInput.autocorrectionType = UITextAutocorrectionTypeYes
            descriptionInput.delegate = self;
            if (!self.isNewEntry) {
                descriptionInput.text = self.entry[@"description"];
            }
        }
        [cell.contentView addSubview:self.descriptionTextField];
    }
    else if (indexPath.section == 2) {
        cell.textLabel.text = @"Start Scanning";
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:0 green:0.478 blue:1 alpha:1];
    }
    else if (indexPath.section == 3) {
        cell.textLabel.text = self.entry[@"tags"][indexPath.row];
    }
    else if (indexPath.section == 4) {
        cell.textLabel.text = @"Delete";
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:1 green:0.231 blue:188 alpha:1];
    }
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
        return self.entry[@"tags"].count;
    }
    else {
        return 1;
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
        navController.navigationItem.leftBarButtonItem = stopButton;

        [self presentViewController:navController animated:YES completion:nil];
    }
    else if (indexPath.section == 4) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Event" message:@"Are you sure that you want to delete this event?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSString *eventName = self.event[@"name"];
            HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.haotestlabs.nfcactivator"];
            NSArray *entrys = [preferences objectForKey:@"NFCActivatorEntrys"];

            for (int i = 0; i < entrys.count; i++) {
                if ([entrys[i][@"name"] isEqual:eventName]) {
                    NSArray *updatedEntrys = [[[entrys mutableCopy] removeObjectAtIndex:i] copy];
                    [preferences setObject:updatedEntrys forKey:@"NFCActivatorEntrys"];
                    break;
                }
            }

            // TODO: send notification

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

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.titleTextField]) {
        [self.descriptionTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
}

#pragma mark NAPViewDismissCallbackProtocol
- (void)viewDismissed {
    [self.tableView reloadData];
}
@end
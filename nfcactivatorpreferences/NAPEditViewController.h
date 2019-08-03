#import "NAPViewDismissCallbackProtocol.h"

@interface NAPEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NAPViewDismissCallbackProtocol>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) bool isNewEntry;
@property (nonatomic, retain) NSMutableDictionary *entry;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UITextField *descriptionTextField;
@property (nonatomic, weak) id<NAPViewDismissCallbackProtocol> delegate;
- (id)initWithEntry:(NSDictionary *)entry;
- (void)loadView;
- (void)doneButtonPressed;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11));

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (void)viewDismissed;
@end
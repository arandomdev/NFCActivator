#import <Cephei/HBPreferences.h>
#import "NAPRootListController.h"

@interface NAPEntryEditController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *eventName;
@property (nonatomic, retain) NSDictionary *eventEntry;
@property (nonatomic, retain) UITextField *nameInput;
@property (nonatomic, retain) UITextField *descriptionInput;
@property (nonatomic, retain) NAPRootListController *delegate;
- (id)initWithName:(NSString *)name entry:(NSDictionary *)entry;
- (void)viewDidLoad;
- (void)cancelButtonPressed;
- (void)doneButtonPressed;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end
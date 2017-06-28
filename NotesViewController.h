
#import <UIKit/UIKit.h>

@interface NotesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;

-(void)setUpDataSourceAsperInternet;

@end

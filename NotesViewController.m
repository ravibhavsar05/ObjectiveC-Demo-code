
#import "NotesViewController.h"
#import "NoteListCell.h"
#import "CreateNotesVC.h"


@interface NotesViewController ()
{
    NSMutableArray *noteListData;
    UITableViewController *tableViewController;

}
@end

@implementation NotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - UIViewController Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpViewforPulltoRefresh];
}
-(void)viewWillAppear:(BOOL)animated{
    [self setUpDataSourceAsperInternet];
}

-(void)setUpDataSourceAsperInternet{
    
    // if the internet connection avialable then call a webservice else get the data from local DB
    if ([APPDELEGATE isInterNetConnectionAvailable])
    {
        // getting a data from Web using API
        [self callNoteData];
        
    }else{
        // getting a data from Local DB
        [self gettingAllNotesLocalDatabase];
    }
    
}

#pragma mark General Methods

// prepare a view for the pulltorefresh indication on top side of tableview
 
 -(void)setUpViewforPulltoRefresh{
    tableViewController= [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableViewOutlet;
    
    UIRefreshControl *refreshControl = [UIRefreshControl.alloc init];
    [refreshControl setTintColor:[UIColor colorWithRed:73.0/255.0f green:126.0/255.0f blue:192.0/255.0f alpha:1.0]];
    
    NSDictionary *refreshAttributes = @{
                                        NSForegroundColorAttributeName: [UIColor colorWithRed:73.0/255.0f green:126.0/255.0f blue:192.0/255.0f alpha:1.0],
                                        };
    NSString *s = @"Refresh the list...";
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:s];
    
    [attributeString setAttributes:refreshAttributes range:NSMakeRange(0, attributeString.length)];
    refreshControl.attributedTitle=attributeString;
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl=refreshControl;
}
-(void)pullToRefresh{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tableViewController.refreshControl endRefreshing];
    });
    [self setUpDataSourceAsperInternet];
}



#pragma mark WebService method

-(void)callNoteData{
    
  
    [[ArcadeManager sharedInstance] requestWithURL:APINotes data:nil withType:GetMethod withCompletion:^(id result, BOOL success) {
        if (success) { 
            //handle the API responce
            NSMutableDictionary *dict=(NSMutableDictionary *)result;
            noteListData=[dict objectForKey:@"data"];
            
            [USERDEFAULTS setObject:[APPDELEGATE getCurrentDateinUTC] forKey:KEYNotesSYNCDATEUTC];
    
            // once responce is getting just open the DB and dumb in database
            [[DataBaseHelper shareDatabase] databaseOpen];
            [[DataBaseHelper shareDatabase] insertIntoNoteTable:noteListData withSync:DatabaseSyncYes withStatus:@""];
            [[DataBaseHelper shareDatabase] deleteData:[NSString stringWithFormat:@"delete from NotesDetail where note_id IN (%@)",[dict objectForKey:@"delete"]]];
            [[DataBaseHelper shareDatabase] databaseClose];
            
            // getting latest data from database and reload the view using tableview reload.
            [self gettingAllNotesLocalDatabase];
            [self.tableViewOutlet  reloadData];
        }
    
    }];
}
-(void)gettingAllNotesLocalDatabase{
    [[DataBaseHelper shareDatabase] databaseOpen];
     noteListData =[[DataBaseHelper shareDatabase] selectNoteData];
    [[DataBaseHelper shareDatabase] databaseClose];
    [self.tableViewOutlet reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // gt of any resources that can be recreated.
}
-(NSString *)dateformateForNote :(NSString *)noteData{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *noteDateFormate = [dateFormatter dateFromString:noteData];
    [dateFormatter setDateFormat:@"EEEE dd/MM/yyyy"];
    NSString *displayDate = [dateFormatter stringFromDate:noteDateFormate];
    NSLog(@"%@",displayDate);
    return displayDate;
}

#pragma Mark UItableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return noteListData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    static NSString *CellIdentifier = @"NoteListCell";
    
    // prepate a cell for the every row  and set the data in cell
    NoteListCell *noteCell = (NoteListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *dictData=[noteListData objectAtIndex:indexPath.row];
    noteCell.lblNoteName.text=[dictData objectForKey:@"name"];
    noteCell.lblNoteDate.text=[self dateformateForNote:[dictData objectForKey:@"note_date"]];
    NSString * result = [[[dictData objectForKey:@"related"] valueForKey:@"related_name"] componentsJoinedByString:@","];
        noteCell.lblRelatedName.text=result;
    return noteCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    // on selection of the row on table it will push a new view for create a new note or edit the note.
    
    CreateNotesVC *createNote =[[UIStoryboard storyboardWithName:@"Calendar_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CreateNotesVC"];
    createNote.isEditNote=YES;
    createNote.dictNoteDetails=[noteListData objectAtIndex:indexPath.row];
    [[APPDELEGATE sharedObject].mainNavController pushViewController:createNote animated:YES];
}
@end

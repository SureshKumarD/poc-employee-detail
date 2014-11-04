//
//  EmployeesTableViewController.m
//  POCEmployeeDetail
//
//  Created by Suresh on 03/11/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import "EmployeesTableViewController.h"
#import "DataManager.h"
#import "Employee.h"
#import "ViewController.h"

@interface EmployeesTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation EmployeesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
       self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [self.tableView reloadData];
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[DataManager dataManager].employees count];
}


#pragma mark - Table view delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"employeeCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"employeeCellIdentifier" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Employee *employee = [[DataManager dataManager].employees objectAtIndex:indexPath.row];
    cell.textLabel.text = employee.firstName;
    cell.detailTextLabel.text = employee.address;//[employee.companyDetail objectAtIndex:0];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"viewController"];

    viewController.employeeEntryIndex = [indexPath row];
    viewController.isForAddingNewEmployee = NO;
    viewController.employeeData = [[DataManager dataManager].employees objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ViewController *viewController = segue.destinationViewController;
    viewController.employeeData = [[Employee alloc] init];
    if([segue.identifier isEqualToString:@"addNewEmployee"])
        viewController.isForAddingNewEmployee = YES;
    
}



@end

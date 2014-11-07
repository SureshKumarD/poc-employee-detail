//
//  EmployeesTableViewController.h
//  POCEmployeeDetail
//
//  Created by Suresh on 03/11/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeesTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong) NSMutableArray *employees;
@end

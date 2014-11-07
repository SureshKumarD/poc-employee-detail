//
//  ViewController.h
//  POCEmployeeDetail
//
//  Created by Suresh on 29/10/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

@interface ViewController : UIViewController
@property (nonatomic) BOOL isForAddingNewEmployee;
@property (nonatomic) NSInteger employeeEntryIndex;
@property (nonatomic) Employee *employeeData;
@property(strong,nonatomic) NSMutableArray *companyDetailArray;
@end

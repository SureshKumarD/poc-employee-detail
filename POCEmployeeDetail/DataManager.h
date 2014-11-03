//
//  DataManager.h
//  POCEmployeeDetail
//
//  Created by Suresh on 03/11/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Employee.h"

@interface DataManager : NSObject
{
    NSMutableArray *employees;
}
@property (nonatomic,strong) NSMutableArray *employees;
+ (DataManager *)dataManager;
-(void)updateEmployeeEntry :(Employee *) employeeDetail :(NSInteger)index;
-(void)addNewEmployee:(Employee *)employeeDetail;
@end

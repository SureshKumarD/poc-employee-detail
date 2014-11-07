//
//  DataManager.m
//  POCEmployeeDetail
//
//  Created by Suresh on 03/11/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import "DataManager.h"
#import "Employee.h"

@implementation DataManager
@synthesize employees = _employees;


+ (DataManager *)dataManager {
    static DataManager *myDataManager = nil;
    @synchronized(self){
        if(myDataManager == nil)
            myDataManager = [[DataManager alloc] init];
        
    }
    return myDataManager;
}

-(id) init{
    if(self == [super init]){
        self.employees = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)updateEmployeeEntry :(Employee *) employeeDetail :(NSInteger)index{
    [self.employees replaceObjectAtIndex:index withObject:employeeDetail];
    
}
-(void)addNewEmployee:(Employee *)employeeDetail{
    
    [self.employees addObject:employeeDetail];
}

@end

//
//  Employee.h
//  POCEmployeeDetail
//
//  Created by Suresh on 03/11/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface Employee : NSManagedObject{
    NSString *empFirstName,*empLastName,*empDOB,*empAddress;
    id companyDetail;
}
@property (nonatomic, strong) NSString *empFirstName;
@property (nonatomic, strong) NSString *empLastName;
@property (nonatomic, strong) NSString *empDOB;
@property (nonatomic, strong) NSString *empAddress;
@property (nonatomic, strong) id companyDetail;

@end



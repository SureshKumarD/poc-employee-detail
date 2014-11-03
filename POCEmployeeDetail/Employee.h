//
//  Employee.h
//  POCEmployeeDetail
//
//  Created by Suresh on 03/11/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Employee : NSObject{
    NSString *firstName,*lastName,*dateOfBirth,*address;
    NSMutableArray *companyDetail;
}
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *dateOfBirth;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSMutableArray *companyDetail;
@end

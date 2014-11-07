//
//  CompanyDetail.m
//  POCEmployeeDetail
//
//  Created by Suresh on 07/11/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import "CompanyDetail.h"

@implementation CompanyDetail

+ (Class)transformedValueClass
{
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

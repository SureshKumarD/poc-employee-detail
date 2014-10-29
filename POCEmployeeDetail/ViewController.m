//
//  ViewController.m
//  POCEmployeeDetail
//
//  Created by Suresh on 29/10/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()<UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>{
    UIActionSheet *pickerViewActionSheet;
    UIDatePicker *datePicker;
    UIToolbar *pickerToolbar;

}
@property (strong, nonatomic) IBOutlet UILabel *employeeLabel;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *invalidAlertFirstNameLabel;

@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *invalidAlertLastNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *dateOfBirthTextField;
@property (strong, nonatomic) IBOutlet UILabel *invalidAlertDOBLabel;
@property (strong, nonatomic) IBOutlet UITextView *addressTextView;

@property (strong, nonatomic) IBOutlet UILabel *companyDetailLabel;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *invalidAlertCompanyNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *companyAddressTextView;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self StyleTextView];
    	// Do any additional setup after loading the view, typically from a nib.
}

-(void)StyleTextView {
    [[self.addressTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.addressTextView layer] setBorderWidth:0.2];
    
    [[self.addressTextView layer] setCornerRadius:5];
    
    [[self.companyAddressTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.companyAddressTextView layer] setBorderWidth:0.2];
    [[self.companyAddressTextView layer] setCornerRadius:5];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.dateOfBirthTextField.delegate = self;
    self.companyNameTextField.delegate = self;
    [self hideAllInvalidAlerts];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UIView *views in self.view.subviews){
        if([views isKindOfClass:[UITextField class]] && [views isFirstResponder]){
            [views resignFirstResponder];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if(textField == self.firstNameTextField){
        if(![self checkForOnlyString:textField.text])
        {
            self.invalidAlertFirstNameLabel.hidden = NO;
            self.invalidAlertFirstNameLabel.text = NSLocalizedString(@"Invalid First Name", nil) ;
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideAllInvalidAlerts) userInfo:nil repeats:NO];
            return NO;
        }
    }
    else if(textField == self.lastNameTextField){
        if(![self checkForOnlyString:textField.text]){
            
            self.invalidAlertLastNameLabel.hidden = NO;
            self.invalidAlertLastNameLabel.text = NSLocalizedString(@"Invalid Last Name", nil);
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideAllInvalidAlerts) userInfo:nil repeats:NO];
            return NO;
        }
    }
    else if(textField == self.companyNameTextField){
        if(![self checkForOnlyString:textField.text]){
            
            self.invalidAlertCompanyNameLabel.hidden = NO;
            self.invalidAlertCompanyNameLabel.text = NSLocalizedString(@"Invalid Company Name", nil);
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideAllInvalidAlerts) userInfo:nil repeats:NO];
            return NO;
        }
    }
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.dateOfBirthTextField)
    {
        datePicker = [[UIDatePicker alloc] init];
        [textField resignFirstResponder];
        float platformVersion = 8.0;
        if([[[UIDevice currentDevice] systemVersion] floatValue ] >= platformVersion){
           
            //TODO : iOS8 date picker
            
        }
        else {
            [textField resignFirstResponder];
            datePicker = [[UIDatePicker alloc] init];
            
            pickerViewActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select the date!"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil];
            
            datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 300.0)];
            datePicker.datePickerMode = UIDatePickerModeDate;
            [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
            pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            pickerToolbar.barStyle=UIBarStyleBlackOpaque;
            [pickerToolbar sizeToFit];
            NSMutableArray *barItems = [[NSMutableArray alloc] init];
            UIBarButtonItem *batButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
            [barItems addObject:batButtonItem];
            
            [pickerToolbar setItems:barItems animated:YES];
            [pickerViewActionSheet addSubview:pickerToolbar];
            [pickerViewActionSheet addSubview:datePicker];
            [pickerViewActionSheet showInView:self.view];
            [pickerViewActionSheet setBounds:CGRectMake(0,0,320, 464)];
            
        }
        
    }
    
}

-(BOOL)checkForOnlyString:(NSString *) string{
    NSString *nameRegularExpression = @"[a-zA-Z\" \"]*$";
    NSPredicate *nameValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegularExpression];
    BOOL isValid = [nameValidation evaluateWithObject:string];
    return isValid;
}
-(void) hideAllInvalidAlerts {
    self.invalidAlertFirstNameLabel.hidden = YES;
    self.invalidAlertLastNameLabel.hidden = YES;
    self.invalidAlertDOBLabel.hidden = YES;
    self.invalidAlertCompanyNameLabel.hidden = YES;
}
-(void)dateChanged{
    NSDateFormatter *FormatDate = [[NSDateFormatter alloc] init];
    FormatDate = [[NSDateFormatter alloc] init];
    [FormatDate setDateFormat:@"dd/MM/yyyy"];
    self.dateOfBirthTextField.text = [FormatDate stringFromDate:[datePicker date]];
}

-(BOOL)closeDatePicker:(id)sender{
    [pickerViewActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.dateOfBirthTextField resignFirstResponder];
    return YES;
}

-(void)doneButtonClicked{
    [self closeDatePicker:self];
}


@end

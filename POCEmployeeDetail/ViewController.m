//
//  ViewController.m
//  POCEmployeeDetail
//
//  Created by Suresh on 29/10/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PrefixHeader.pch"
#import "DataManager.h"
#import "Employee.h"

@interface ViewController ()<UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    UIActionSheet *pickerViewActionSheet;
    UIDatePicker *datePicker;
    UIToolbar *pickerToolbar;
    CGFloat animatedDistance;
    UIView *dateView;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
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
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) IBOutlet UITableView *companyListTableView;

- (IBAction)addCompanyButtonClicked:(id)sender;

- (IBAction)submitButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelButtonClicked:(id)sender;


@end


@implementation ViewController
//@synthesize isForAddingNewEmployee;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self styleTextView];
    self.navigationController.navigationBar.hidden = YES;
   	// Do any additional setup after loading the view, typically from a nib.
}

-(void)dismissKeyboard {
    for(UIView *views in self.scrollView.subviews){
        if(([views isKindOfClass:[UITextField class]] ||[views
                                                         isKindOfClass:[UITextView class]]) && [views isFirstResponder]){
            [views resignFirstResponder];
        }
    }
}

-(void)styleTextView {
    [[self.addressTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.addressTextView layer] setBorderWidth:0.2];
    
    [[self.addressTextView layer] setCornerRadius:5];
    
    [[self.companyAddressTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.companyAddressTextView layer] setBorderWidth:0.2];
    [[self.companyAddressTextView layer] setCornerRadius:5];
}

- (void)viewDidLayoutSubviews {
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 300)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.dateOfBirthTextField.delegate = self;
    self.companyNameTextField.delegate = self;
    [self hideAllInvalidAlerts];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    if(self.isForAddingNewEmployee == NO){
        
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(self.isForAddingNewEmployee == NO){
        
        self.firstNameTextField.text =  self.employeeData.firstName;
        self.lastNameTextField.text =  self.employeeData.lastName;
        self.dateOfBirthTextField.text =  self.employeeData.dateOfBirth;
        self.addressTextView.text =  self.employeeData.address;

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self bringTextFieldVisible:textField];
    if(textField == self.dateOfBirthTextField)
    {
        datePicker = [[UIDatePicker alloc] init];
        [textField resignFirstResponder];
        float platformVersion = 8.0;
        if([[[UIDevice currentDevice] systemVersion] floatValue ] >= platformVersion){
           
            //TODO : iOS8 date picker
            dateView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2.0, 320, 640)];
            pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            pickerToolbar.barStyle=UIBarStyleBlackOpaque;
            [pickerToolbar sizeToFit];
            NSMutableArray *barItems = [[NSMutableArray alloc] init];
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateChosen:)];
            [barItems addObject:barButtonItem];
            barButtonItem.tag = 123;
            [pickerToolbar setItems:barItems animated:YES];
            [dateView addSubview:pickerToolbar];
            datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 300.0)];
            datePicker.datePickerMode = UIDatePickerModeDate;
            [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
            datePicker.backgroundColor = [UIColor whiteColor];
            [dateView addSubview:datePicker];
            
            
            [self.view addSubview:dateView];

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
            datePicker.tag = -1;
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

-(void) dateChosen:(UIBarButtonItem *) barButton {
    if(barButton.tag ==123){
        [dateView removeFromSuperview];
        
    }
   
}

-(void)bringTextFieldVisible:(UITextField *)textField {
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.scrollView setFrame:viewFrame];
    
    [UIView commitAnimations];
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    self.dateOfBirthTextField.text = [dateFormatter stringFromDate:[datePicker date]];
}

-(BOOL)closeDatePicker:(id)sender{
    [pickerViewActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.dateOfBirthTextField resignFirstResponder];
    return YES;
}

-(void)doneButtonClicked{
    [self closeDatePicker:self];
}


- (IBAction)addCompanyButtonClicked:(id)sender {
    NSMutableArray *companyDetail = [[NSMutableArray alloc] initWithObjects:self.companyNameTextField.text, self.companyAddressTextView.text, nil];
    self.employeeData.firstName = @" Suresh";
    [self.employeeData.companyDetail addObject:companyDetail];
    [self.companyListTableView reloadData];
    
}

- (IBAction)submitButtonClicked:(id)sender {
    //To avoid posting the same data multiple times.
    self.submitButton.enabled = NO;
    
    //Get the local data to post into the global/server data
    Employee *employee = [[Employee alloc]init];
    employee.firstName = self.firstNameTextField.text;
    employee.lastName = self.lastNameTextField.text;
    employee.dateOfBirth = self.dateOfBirthTextField.text;
    employee.address = self.addressTextView.text;
    employee.companyDetail = [self.employeeData.companyDetail mutableCopy];
    
    //If the submit is for new employee add, otherwise update.
    if(self.isForAddingNewEmployee == YES)
        [[DataManager dataManager] addNewEmployee:employee];
    else
        [[DataManager dataManager] updateEmployeeEntry:employee :self.employeeEntryIndex];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Datasource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.employeeData.companyDetail count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"companyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"companyDetailCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[self.employeeData.companyDetail objectAtIndex:indexPath.row] objectAtIndex:0];
    cell.detailTextLabel.text = [[self.employeeData.companyDetail objectAtIndex:indexPath.row] objectAtIndex:1];
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.employeeData.companyDetail removeObjectAtIndex:indexPath.row];
        [self.companyListTableView reloadData];
    }
}
@end

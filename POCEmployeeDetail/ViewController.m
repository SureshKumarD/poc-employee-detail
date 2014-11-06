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

@interface ViewController ()<UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource,UITableViewDelegate>{
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
@property (strong, nonatomic) IBOutlet UIButton *addButton;

- (IBAction)addCompanyButtonClicked:(id)sender;

- (IBAction)submitButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelButtonClicked:(id)sender;

@property (nonatomic) CGFloat contentOffsetHeight;

@end


@implementation ViewController
//@synthesize isForAddingNewEmployee;

#pragma mark - UIViewController Delegate Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self styleTextView];
    if(self.isForAddingNewEmployee == NO){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(enableFieldsForEdit:)];

    }
   	
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
    [self setTitle:@"Employee Detail"];
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.dateOfBirthTextField.delegate = self;
    self.companyNameTextField.delegate = self;
    self.addressTextView.delegate = self;
    self.companyAddressTextView.delegate = self;
    datePicker = [[UIDatePicker alloc] init];
    self.dateOfBirthTextField.inputView = datePicker;
    
    [self hideAllInvalidAlerts];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    if(self.isForAddingNewEmployee == NO){
        [self.firstNameTextField setEnabled:NO];
        [self.lastNameTextField setEnabled:NO];
        [self.dateOfBirthTextField setEnabled:NO];
        [self.companyNameTextField setEnabled:NO];
        [self.companyAddressTextView setEditable:NO];
        [self.addressTextView setEditable:NO];
    }
    self.contentOffsetHeight = self.scrollView.frame.size.height;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validateFields) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validateFields) name:UITextViewTextDidChangeNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.submitButton setEnabled:NO];
    [self.addButton setEnabled:NO];
    [self.addButton setAlpha:0.1];
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




#pragma mark - SubView Layout Method
- (void)viewDidLayoutSubviews {
    CGRect frame = self.scrollView.frame;
    NSLog(@"frame : %f", frame.size.height);
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.contentOffsetHeight+350.0 )];
}


-(void)enableFieldsForEdit:(id)sender{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.firstNameTextField setEnabled:YES];
    [self.lastNameTextField setEnabled:YES];
    [self.dateOfBirthTextField setEnabled:YES];
    [self.companyNameTextField setEnabled:YES];
    [self.companyAddressTextView setEditable:YES];
    [self.addressTextView setEditable:YES];
    
}




#pragma mark - UITextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.firstNameTextField){
        [self.lastNameTextField becomeFirstResponder];
    }
    else if(textField == self.lastNameTextField){
        [textField resignFirstResponder];
    }
    else if(textField == self.companyNameTextField){
        [self.companyAddressTextView becomeFirstResponder];
    }
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
        if([[[UIDevice currentDevice] systemVersion] floatValue ] >= kPLATFORM_VERSION_8_0){
           
            
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
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
            [barItems addObject:barButtonItem];
            
            [pickerToolbar setItems:barItems animated:YES];
            [pickerViewActionSheet addSubview:pickerToolbar];
            [pickerViewActionSheet addSubview:datePicker];
            [pickerViewActionSheet showInView:self.view];
            [pickerViewActionSheet setBounds:CGRectMake(0,0,320, 464)];
            
        }
        
    }
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    self.contentOffsetHeight = self.scrollView.frame.size.height;
    [textField resignFirstResponder];
}

-(void)bringTextFieldVisible:(id)field {
    CGRect textFieldRect;
    if([field isKindOfClass:[UITextField class]]){
        UITextField *textField = (UITextField *)field;
        textFieldRect = textField.frame;
    }else{
        UITextView *textView = (UITextView *)field;
        textFieldRect = textView.frame;
    }
    
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat heightDifference = scrollViewFrame.size.height - (textFieldRect.origin.y + textFieldRect.size.height);
    
    if( heightDifference <= kOFFSET_FOR_KEYBOARD){
        self.contentOffsetHeight += kOFFSET_FOR_KEYBOARD - heightDifference;
        [self.scrollView setContentOffset:CGPointMake(0,  kOFFSET_FOR_KEYBOARD - heightDifference) animated:YES];
        
    }
    
    
}

#pragma mark - UITextView Delegate Methods

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self bringTextFieldVisible:textView];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    self.contentOffsetHeight = self.scrollView.frame.size.height;
       
}


#pragma mark - UIDatePicker Methods
-(void) dateChosen:(UIBarButtonItem *) barButton {
    if(barButton.tag ==123){
        [dateView removeFromSuperview];
        
    }
   
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

#pragma mark - Validation Method
-(void)validateFields{
    if(![self.firstNameTextField.text isEqualToString:@""] && ![self.lastNameTextField.text isEqualToString:@""] && ![self.dateOfBirthTextField.text isEqualToString:@""]&& ![self.addressTextView.text isEqualToString:@""]&&[self.companyNameTextField.text isEqualToString:@""] && [self.companyAddressTextView.text isEqualToString:@""]){
        [self.submitButton setEnabled:YES];
        [self.addButton setEnabled:NO];
        [self.addButton setAlpha:0.2];
    }
    
    else if(![self.companyNameTextField.text isEqualToString:@""] && ![self.companyAddressTextView.text isEqualToString:@""]){
        [self.addButton setEnabled:YES];
        [self.addButton setAlpha:1.0];
        
    }
    else{
        [self.submitButton setEnabled:NO];
        [self.addButton setEnabled:NO];
        [self.addButton setAlpha:0.2];
        
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


-(void)dismissKeyboard {
    for(UIView *views in self.scrollView.subviews){
        if(([views isKindOfClass:[UITextField class]] ||[views
                                                         isKindOfClass:[UITextView class]]) && [views isFirstResponder]){
            [views resignFirstResponder];
            
            [self viewDidLayoutSubviews];
            
            
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



#pragma mark - Add/Submit/Cancel Methods


- (IBAction)addCompanyButtonClicked:(id)sender {
    NSMutableArray *companyDetail = [[NSMutableArray alloc] initWithObjects:self.companyNameTextField.text, self.companyAddressTextView.text, nil];
    
    [self.employeeData.companyDetail addObject:companyDetail];
    [self.companyListTableView reloadData];
    [self.companyNameTextField setText:nil];
    [self.companyAddressTextView setText:nil];

    [self validateFields];
   
    
}

- (IBAction)submitButtonClicked:(id)sender {
    //To avoid posting the same data multiple times.
    [self.submitButton setEnabled:NO];
    
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

#pragma mark - TableView Delegate Method
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.employeeData.companyDetail removeObjectAtIndex:indexPath.row];
        [self.companyListTableView reloadData];
    }
}
@end

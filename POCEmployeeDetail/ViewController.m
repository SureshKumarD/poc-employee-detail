//
//  ViewController.m
//  POCEmployeeDetail
//
//  Created by Suresh on 29/10/14.
//  Copyright (c) 2014 Neev. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "PrefixHeader.pch"
#import "DataManager.h"
#import "CompanyDetail.h"

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
@property (strong, nonatomic) IBOutlet UILabel *addCompanyLabel;
@property (strong, nonatomic) IBOutlet UILabel *companyAddressLabel;
@property (strong, nonatomic) IBOutlet UITableView *companyListTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addCompanyOption;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *companyLabelTopSpaceConstraint;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (atomic) CGFloat contentOffsetHeight;
@property (strong, nonatomic) IBOutlet UIButton *addCompanyButton;
@property (nonatomic) BOOL isEdited;

- (IBAction)addCompanyButtonClicked:(id)sender;
- (void) submitButtonClicked:(id)sender;
- (void) cancelButtonClicked:(id)sender;
- (void) enableFieldsForEdit:(id)sender;
- (IBAction)showCompanyDetails:(id)sender;

@end


@implementation ViewController
@synthesize companyDetailArray = _companyDetailArray,addCompanyButton = _addCompanyButton;


#pragma mark - UIViewController Delegate Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleTextView];
    if(self.isForAddingNewEmployee == NO) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(enableFieldsForEdit:)];

    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitButtonClicked:)];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
   	
}


- (void)viewWillAppear:(BOOL)animated {
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
    
    self.companyDetailArray = [[NSMutableArray alloc] init];
    
    [self hideAllInvalidAlerts];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.addCompanyButton =[[UIButton alloc] init];
    
    [self hideCompanyDetail];
    if(self.isForAddingNewEmployee == NO){
        [self.firstNameTextField setEnabled:NO];
        [self.lastNameTextField setEnabled:NO];
        [self.dateOfBirthTextField setEnabled:NO];
        [self.companyNameTextField setEnabled:NO];
        [self.companyAddressTextView setEditable:NO];
        [self.addressTextView setEditable:NO];
        [self.addCompanyButton setEnabled:NO];
        CompanyDetail *companydetail = [[CompanyDetail alloc]init];
        self.companyDetailArray =  [companydetail reverseTransformedValue:self.employeeData.companyDetail];
    }    
    self.contentOffsetHeight = self.scrollView.frame.size.height;
    
    //Observe the textfields and textviews on change...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validateFields) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validateFields) name:UITextViewTextDidChangeNotification object:nil];
    [self.addCompanyButton setHidden:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.isForAddingNewEmployee == NO) {
        self.firstNameTextField.text =  self.employeeData.empFirstName ;
        self.lastNameTextField.text =  self.employeeData.empLastName ;
        self.dateOfBirthTextField.text =self.employeeData.empDOB ;
        self.addressTextView.text = self.employeeData.empAddress ;
        
    }
    else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
    }
    
    //Check for Company Details To display the company details dynamically.
    if([self.companyDetailArray count] == 0) {
        [self.companyListTableView setHidden:YES];
        self.tableHeightConstraint.constant = 0 ;
        [self.companyListTableView needsUpdateConstraints];
    }
    else {
        [self.companyListTableView setHidden:NO];
        CGFloat tableViewHeight = MIN([self.companyDetailArray count]*44.0 , 176.0);
        self.tableHeightConstraint.constant = tableViewHeight;
        [self.companyListTableView needsUpdateConstraints];

    }
    [self.companyListTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    [self.addCompanyButton setHidden:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SubView Layout Method

- (void)viewDidLayoutSubviews {
    CGRect frame = self.scrollView.frame;
    NSLog(@"frame : %f", frame.size.height);
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.contentOffsetHeight+300.0 )];
}


- (void)enableFieldsForEdit:(id)sender {
    if(!self.isEdited) {
        self.isEdited = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"Submit"];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.addCompanyButton setEnabled:YES];
        [self.firstNameTextField setEnabled:YES];
        [self.lastNameTextField setEnabled:YES];
        [self.dateOfBirthTextField setEnabled:YES];
        [self.companyNameTextField setEnabled:YES];
        [self.companyAddressTextView setEditable:YES];
        [self.addressTextView setEditable:YES];
    }
    else {
        [self submitButtonClicked:nil];
    }
    
}


- (IBAction)showCompanyDetails:(id)sender {
    
    [self.addCompanyButton setEnabled:NO];
    [self.addCompanyButton setAlpha:0.2];
    [self.companyNameTextField setHidden:NO];
    [self.companyAddressTextView setHidden:NO];
    [self.companyAddressLabel setHidden:NO];
    [self.addCompanyLabel setHidden:NO];
    [self.addButton setHidden:NO];
    
}

-(void) hideCompanyDetail {
    [self.addCompanyButton setEnabled:YES];
    [self.companyNameTextField setHidden:YES];
    [self.companyAddressTextView setHidden:YES];
    [self.companyAddressLabel setHidden:YES];
    [self.addCompanyLabel setHidden:YES];
    [self.addButton setHidden:YES];

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


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField == self.firstNameTextField) {
        if(![self checkForOnlyString:textField.text]) {
            self.invalidAlertFirstNameLabel.hidden = NO;
            self.invalidAlertFirstNameLabel.text = NSLocalizedString(@"Invalid First Name", nil) ;
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideAllInvalidAlerts) userInfo:nil repeats:NO];
            return NO;
        }
    }
    else if(textField == self.lastNameTextField) {
        if(![self checkForOnlyString:textField.text]) {
            
            self.invalidAlertLastNameLabel.hidden = NO;
            self.invalidAlertLastNameLabel.text = NSLocalizedString(@"Invalid Last Name", nil);
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideAllInvalidAlerts) userInfo:nil repeats:NO];
            return NO;
        }
    }
    else if(textField == self.companyNameTextField) {
        if(![self checkForOnlyString:textField.text]) {
            
            self.invalidAlertCompanyNameLabel.hidden = NO;
            self.invalidAlertCompanyNameLabel.text = NSLocalizedString(@"Invalid Company Name", nil);
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideAllInvalidAlerts) userInfo:nil repeats:NO];
            return NO;
        }
    }
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self bringTextFieldVisible:textField];
    if(textField == self.dateOfBirthTextField) {
        datePicker = [[UIDatePicker alloc] init];
        [textField resignFirstResponder];
        if([[[UIDevice currentDevice] systemVersion] floatValue ] >= kPLATFORM_VERSION_8_0) {
            
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.contentOffsetHeight = self.scrollView.frame.size.height;
    [textField resignFirstResponder];
}

- (void)bringTextFieldVisible:(id)field {
    CGRect textFieldRect;
    if([field isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)field;
        textFieldRect = textField.frame;
    }
    else {
        UITextView *textView = (UITextView *)field;
        textFieldRect = textView.frame;
    }
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat heightDifference = scrollViewFrame.size.height - (textFieldRect.origin.y + textFieldRect.size.height);
    if( heightDifference <= kOFFSET_FOR_KEYBOARD) {
        self.contentOffsetHeight += kOFFSET_FOR_KEYBOARD - heightDifference;
        [self.scrollView setContentOffset:CGPointMake(0,  kOFFSET_FOR_KEYBOARD - heightDifference) animated:YES];
        
    }
    
}

#pragma mark - UITextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self bringTextFieldVisible:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.contentOffsetHeight = self.scrollView.frame.size.height;
       
}


#pragma mark - UIDatePicker Methods
- (void) dateChosen:(UIBarButtonItem *) barButton {
    if(barButton.tag ==123) {
        [dateView removeFromSuperview];
        
    }
   
}

- (void)dateChanged {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    self.dateOfBirthTextField.text = [dateFormatter stringFromDate:[datePicker date]];
}

- (BOOL)closeDatePicker:(id)sender {
    [pickerViewActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.dateOfBirthTextField resignFirstResponder];
    return YES;
}

- (void)doneButtonClicked {
    [self closeDatePicker:self];
}

#pragma mark - Validation Method
- (void)validateFields {
    if (![self.firstNameTextField.text isEqualToString:@""] && ![self.lastNameTextField.text isEqualToString:@""] && ![self.dateOfBirthTextField.text isEqualToString:@""] && ![self.addressTextView.text isEqualToString:@""] && [self.companyNameTextField.text isEqualToString:@""] && [self.companyAddressTextView.text isEqualToString:@""]) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.addButton setEnabled:NO];
        [self.addButton setAlpha:0.2];
    }
    else if(![self.companyNameTextField.text isEqualToString:@""] && ![self.companyAddressTextView.text isEqualToString:@""]) {
        [self.addButton setEnabled:YES];
        [self.addButton setAlpha:1.0];
        
    }
    else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.addButton setEnabled:NO];
        [self.addButton setAlpha:0.2];
    }
    
}

- (BOOL)checkForOnlyString:(NSString *)string {
    NSString *nameRegularExpression = @"[a-zA-Z\" \"]*$";
    NSPredicate *nameValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegularExpression];
    BOOL isValid = [nameValidation evaluateWithObject:string];
    return isValid;
}

- (void) hideAllInvalidAlerts {
    self.invalidAlertFirstNameLabel.hidden = YES;
    self.invalidAlertLastNameLabel.hidden = YES;
    self.invalidAlertDOBLabel.hidden = YES;
    self.invalidAlertCompanyNameLabel.hidden = YES;
}


- (void)dismissKeyboard {
    for(UIView *views in self.scrollView.subviews){
        if(([views isKindOfClass:[UITextField class]] ||[views
                                                         isKindOfClass:[UITextView class]]) && [views isFirstResponder]){
            [views resignFirstResponder];
            
            [self viewDidLayoutSubviews];
            
            
        }
    }
}

- (void)styleTextView {
    [[self.addressTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.addressTextView layer] setBorderWidth:0.2];
    [[self.addressTextView layer] setCornerRadius:5];
    
    [[self.companyAddressTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.companyAddressTextView layer] setBorderWidth:0.2];
    [[self.companyAddressTextView layer] setCornerRadius:5];
    
    [[self.companyListTableView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.companyListTableView layer] setBorderWidth:0.2];
    [[self.companyListTableView layer] setCornerRadius:5];
}



#pragma mark - Add/Submit/Cancel Methods

- (IBAction)addCompanyButtonClicked:(id)sender {
    NSMutableArray *companyDetail = [[NSMutableArray alloc] initWithObjects:self.companyNameTextField.text, self.companyAddressTextView.text, nil];
    [self.companyDetailArray addObject:companyDetail];
    [self.companyListTableView setHidden:NO];
    [self viewDidAppear:NO];
    [self.companyListTableView reloadData];
    [self.companyNameTextField setText:nil];
    [self.companyAddressTextView setText:nil];
    [self validateFields];
    [self hideCompanyDetail];
    self.contentOffsetHeight = self.scrollView.frame.size.height;
    [self viewDidLayoutSubviews];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)submitButtonClicked:(id)sender {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    //To avoid posting the same data multiple times.
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
   //If the submit is for new employee then add, otherwise update.
    if(self.isForAddingNewEmployee == YES) {
        NSManagedObject *newEmployee = [NSEntityDescription insertNewObjectForEntityForName:@"Employees" inManagedObjectContext:context];
        [newEmployee setValue:self.firstNameTextField.text forKeyPath:@"empFirstName"];
        [newEmployee setValue:self.lastNameTextField.text forKeyPath:@"empLastName"];
        [newEmployee setValue:self.dateOfBirthTextField.text forKeyPath:@"empDOB"];
        [newEmployee setValue:self.addressTextView.text forKeyPath:@"empAddress"];
         CompanyDetail *companyDetail = [[CompanyDetail alloc]init];
        [newEmployee setValue:[companyDetail transformedValue:self.companyDetailArray] forKeyPath:@"companyDetail"];
        
    }
    else {
        //Get the local data to post into the global/server data
        [self.employeeData setValue:self.firstNameTextField.text forKey:@"empFirstName"];
        [self.employeeData setValue:self.lastNameTextField.text forKey:@"empLastName"];
        [self.employeeData  setValue:self.dateOfBirthTextField.text forKey:@"empDOB"];
        [self.employeeData  setValue:self.addressTextView.text forKey:@"empAddress"];
        CompanyDetail *companyDetail = [[CompanyDetail alloc]init];
        self.employeeData.companyDetail = [companyDetail transformedValue:self.companyDetailArray];
        
    }

    NSString *submitActionMessage = nil;
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        submitActionMessage = SUBMIT_UNSUCCESS;
    }
    else{
        submitActionMessage = SUBMIT_SUCCESS;
        
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Employee" message:submitActionMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    [self performSelector:@selector(dismissAlertMessage:) withObject:alertView afterDelay:2.0];
    
}

-(void)dismissAlertMessage:(UIAlertView*)alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    if([alertView.message isEqualToString:SUBMIT_SUCCESS]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Datasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.companyDetailArray count] ;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"companyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[self.companyDetailArray objectAtIndex:indexPath.row] objectAtIndex:0];
    cell.detailTextLabel.text = [[self.companyDetailArray objectAtIndex:indexPath.row] objectAtIndex:1];
    return cell;
    
}

#pragma mark - TableView Delegate Method
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       [self.companyDetailArray removeObjectAtIndex:indexPath.row];
//        [self.employeeData.companyDetail removeObjectAtIndex:indexPath.row];
        [self.companyListTableView reloadData];
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    [context setRetainsRegisteredObjects:YES];
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end

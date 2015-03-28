//
//  DetailsViewController.m
//  EatAndGo
//
//  Created by Nguyen Minh on 13/9/14.
//  Copyright (c) 2014 EatAndGo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailsViewController.h"
#import "PayPalMobile.h"
#import "PayPalPaymentViewController.h"
#import "MONActivityIndicatorView.h"
#import "AFHTTPRequestOperationManager.h"

@interface DetailsViewController () <PayPalPaymentDelegate>

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@property (nonatomic, retain) NSString *beaconUUID;
@property (nonatomic) int beaconMajor;
@property (nonatomic) int beaconMinor;

@property (nonatomic, retain) MONActivityIndicatorView *indicatorView;

@property (nonatomic, retain) NSArray *arrItems;
@property (nonatomic, retain) id bill;
@property (nonatomic) float total;
@property (nonatomic, retain) NSMutableArray *itemIds;

@property (nonatomic, retain) NSString *myToken;

@end

@implementation DetailsViewController
@synthesize beaconUUID;
@synthesize beaconMajor;
@synthesize beaconMinor;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myToken = @"cc4e214549a6953137ab12110e2f3c79f97d9bc3427f4bdb2fe11f1e1d8a6163";
    
    self.tableView.allowsMultipleSelection = YES;
    
    [self.navigationItem setTitle:@"Eat & Go"];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(btnBack_Clicked)];
    //[UIBarButtonItem alloc] initWithBarButtonSystemItem: target:<#(id)#> action:<#(SEL)#>
    self.navigationItem.leftBarButtonItem = btnBack;
    
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.languageOrLocale = @"en";
    _payPalConfig.merchantName = @"BattleHack restaurant";
    
    
    // Init loading indicator
    self.indicatorView = [[MONActivityIndicatorView alloc] initWithMessage:@"Loading..."];
    self.indicatorView.internalSpacing = 3;
    [self showLoadingIndicator];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"push_id": self.myToken,
                                 @"uuid": @"B9407F30-F5F8-466E-AFF9-25556B57FE6D",
                                 @"major": @"18933",
                                 @"minor": @"21670"};
    [manager POST:@"http://speakmob.com:9000/bill/bill-with-beacon" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            if (responseObject != nil && [[responseObject objectForKey:@"status"] isEqualToString:@"ok"]) {
                self.bill = [responseObject objectForKey:@"bill"];
                NSLog(@"JSON: %@", [responseObject objectForKey:@"status"]);
                self.arrItems = [[responseObject objectForKey:@"bill"] objectForKey:@"items"];
                if (self.arrItems.count > 0) {
                    [self.tableView reloadData];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something wrong happenned" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        @catch (NSException *exception) {
            //
        }
        @finally {
            //
        }
        [self hideLoadingIndicator];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self hideLoadingIndicator];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't connect to server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    //_payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    //_payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnBack_Clicked {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.arrItems != nil && self.arrItems.count > 0) {
        return self.arrItems.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
    
    NSDictionary *item = [self.arrItems objectAtIndex:indexPath.row];
    
    UIImageView *imgStatus = (UIImageView *)[cell viewWithTag:1];
    if ([[item objectForKey:@"status"] intValue] == 0) {
        [imgStatus setImage:[UIImage imageNamed:@"btnNoSelect_Blue"]];
    } else if ([[item objectForKey:@"status"] intValue] == 1) {
        if ([[item objectForKey:@"pushId"] isEqualToString:self.myToken]) {
            [imgStatus setImage:[UIImage imageNamed:@"btnSelect_Blue"]];
        } else {
            [imgStatus setImage:[UIImage imageNamed:@"btnSelect_Orange"]];
        }
    } else if ([[item objectForKey:@"status"] intValue] == 2) {
        [imgStatus setImage:[UIImage imageNamed:@"btnSelect_Gray"]];
    }
    
    UIImageView *smallThumb = (UIImageView *)[cell viewWithTag:2];
    [smallThumb setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [item objectForKey:@"id"]]]];
    smallThumb.layer.cornerRadius = 4.0f;
    smallThumb.clipsToBounds = YES;
    
    UILabel *itemName = (UILabel *)[cell viewWithTag:3];
    [itemName setText:[item objectForKey:@"name"]];
    
    UILabel *itemPrice = (UILabel *)[cell viewWithTag:4];
    [itemPrice setText:[NSString stringWithFormat:@"%.2f$", [[item objectForKey:@"price"] floatValue]]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // To "clear" the footer view
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *item = [self.arrItems objectAtIndex:indexPath.row];
    if ([[item valueForKey:@"status"] intValue] == 0) {
        // send request to server
        [self updateBillWithForItem:item andStatus:YES forTableViewCell:cell];
    } else if ([[item valueForKey:@"status"] intValue] == 1) {
        if ([[item valueForKey:@"pushId"] isEqualToString:self.myToken]) {
            // send request to server
            [self updateBillWithForItem:item andStatus:NO forTableViewCell:cell];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Someone is paying for this item" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } else if ([[item valueForKey:@"status"] intValue] == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"This item has already been paid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    /*
    if ([[item objectForKey:@"status"] intValue] == 0) {
        UIImageView *checkbox = (UIImageView *)[cell viewWithTag:1];
        [checkbox setImage:[UIImage imageNamed:@"btnSelected_Blue"]];
    } else if  {
        [[item objectForKey:@"status"] intValue] == 0
    }*/
    
    //[self processPayment];
}

-(void)updateBillWithForItem:(NSDictionary *)item andStatus:(BOOL)status forTableViewCell:(UITableViewCell *)cell {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"bill_id": [self.bill objectForKey:@"id"],
                                 @"item_id": [item objectForKey:@"sId"],
                                 @"status": status ? @"true": @"false",
                                 @"push_id": self.myToken};
    NSLog(@"Param %@", parameters);
    [manager POST:@"http://speakmob.com:9000/bill/update-item" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            if (responseObject != nil && [[responseObject objectForKey:@"status"] isEqualToString:@"ok"]) {
                NSLog(@"JSON: %@", [responseObject objectForKey:@"status"]);
                self.arrItems = [[responseObject valueForKey:@"bill"] valueForKey:@"items"];
                [self calculateBillAndUpdatePayButton];
                [self.tableView reloadData];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something wrong happenned" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        @catch (NSException *exception) {
            //
        }
        @finally {
            //
        }
        [self hideLoadingIndicator];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self hideLoadingIndicator];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't connect to server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

-(void)calculateBillAndUpdatePayButton {
    self.total = 0;
    for (int i=0;i<self.arrItems.count;i++) {
        NSDictionary *item = [self.arrItems objectAtIndex:i];
        if ([[item objectForKey:@"status"] intValue] == 1 && [[item objectForKey:@"pushId"] isEqualToString:self.myToken]) {
            self.total += [[item objectForKey:@"price"] floatValue];
        }
    }
    if (self.total > 0.01) {
        UIBarButtonItem *btnPay = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Pay %.2f$", self.total] style:UIBarButtonItemStyleBordered target:self action:@selector(processPayment)];
        self.navigationItem.rightBarButtonItem = btnPay;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *item = [self.arrItems objectAtIndex:indexPath.row];
    if ([[item valueForKey:@"status"] intValue] == 0) {
        // send request to server
        [self updateBillWithForItem:item andStatus:NO forTableViewCell:cell];
    }
    /*
    UIImageView *checkbox = (UIImageView *)[cell viewWithTag:1];
    [checkbox setImage:[UIImage imageNamed:@"btnNoSelect_Blue"]];
     */
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)processPayment {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    self.itemIds = [[NSMutableArray alloc] init];
    
    for (int i=0;i<self.arrItems.count;i++) {
        NSDictionary *item = [self.arrItems objectAtIndex:i];
        if ([[item objectForKey:@"status"] intValue] == 1 && [[item objectForKey:@"pushId"] isEqualToString:self.myToken]) {
            PayPalItem *paypalItem = [PayPalItem itemWithName:[item objectForKey:@"name"]
                                                 withQuantity:1
                                                    withPrice:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[item objectForKey:@"price"]]]
                                                 withCurrency:@"SGD"
                                                      withSku:[item objectForKey:@"sId"]];
            [items addObject:paypalItem];
            [self.itemIds addObject:[item objectForKey:@"sId"]];
        }
    }
    
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
    
    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"0.00"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"0.00"];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:shipping
                                                                                    withTax:tax];
    
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"SGD";
    payment.shortDescription = @"Foods at BattleHack restaurant";
    payment.items = items;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Update payPalConfig re accepting credit cards.
    //self.payPalConfig.acceptCreditCards = self.acceptCreditCards;
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    //self.resultText = [completedPayment description];
    //[self showSuccess];
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    //self.resultText = nil;
    //self.successView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
    @try {
        NSDictionary *response = [completedPayment.confirmation objectForKey:@"response"];
        if ([[response objectForKey:@"state"] isEqualToString:@"approved"]) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"bill_id": [self.bill objectForKey:@"id"],
                                         @"paypal_time": [response valueForKey:@"create_time"],
                                         @"paypal_transaction_id": [response valueForKey:@"id"],
                                         @"push_id": self.myToken,
                                         @"item_ids": self.itemIds};
            NSLog(@"Param %@", parameters);
            [manager POST:@"http://speakmob.com:9000/bill/update-item" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                @try {
                    if (responseObject != nil && [[responseObject objectForKey:@"status"] isEqualToString:@"ok"]) {
                        NSLog(@"JSON: %@", [responseObject objectForKey:@"status"]);
                        self.arrItems = [[responseObject valueForKey:@"bill"] valueForKey:@"items"];
                        [self calculateBillAndUpdatePayButton];
                        [self.tableView reloadData];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something wrong happenned" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                }
                @catch (NSException *exception) {
                    //
                }
                @finally {
                    //
                }
                [self hideLoadingIndicator];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
                [self hideLoadingIndicator];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't connect to server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }];
        }
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        //
    }
    
}


#pragma mark - Activity indicator
-(void)showLoadingIndicator {
    [self.indicatorView startAnimating];
    [self.navigationController.view addSubview:self.indicatorView];
    //[NSTimer scheduledTimerWithTimeInterval:1 target:indicatorView selector:@selector(startAnimating) userInfo:nil repeats:NO];
}

-(void)hideLoadingIndicator {
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
}

@end

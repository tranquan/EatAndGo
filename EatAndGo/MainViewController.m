//
//  MainViewController.m
//  EatAndGo
//
//  Created by Nguyen Minh on 13/9/14.
//  Copyright (c) 2014 EatAndGo. All rights reserved.
//

#import "MainViewController.h"
#import "MONActivityIndicatorView.h"
#import "SVPullToRefresh.h"
#import "DetailsViewController.h"

@import CoreLocation;

@interface MainViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MONActivityIndicatorViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSString *strStore;
@property (nonatomic, retain) NSMutableArray *arrTables;
@property (nonatomic, retain) NSMutableArray *arrNearbyTables;

@property NSMutableArray *beacons;
@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;
@property CLBeaconRegion *region;

@property (nonatomic, retain) MONActivityIndicatorView *indicatorView;

@property int updateCount;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize UI
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0/255.0 green:129.0/255.0 blue:84.0/255.0 alpha:1.0f];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView addPullToRefreshWithActionHandler:^{
        //
        NSLog(@"Refresh");
        [self.tableView.pullToRefreshView stopAnimating];
        self.arrNearbyTables = nil;
        [self.tableView reloadData];
        [self.locationManager startRangingBeaconsInRegion:self.region];
        [self showLoadingIndicator];
    }];
    
    self.navigationItem.backBarButtonItem.title = @"Back";
    
    [self.view setBackgroundColor:[UIColor colorWithRed:254.0/255.0 green:242.0/255.0 blue:232.0/255.0 alpha:1.0f]];
    
    // Init loading indicator
    self.indicatorView = [[MONActivityIndicatorView alloc] initWithMessage:@"Finding your table..."];
    self.indicatorView.internalSpacing = 3;
    [self showLoadingIndicator];
    
    self.strStore = @"BattleHack restaurant";
    NSMutableDictionary *table1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Table 1 - Green", @"name",
                                   @"B9407F30-F5F8-466E-AFF9-25556B57FE6D", @"uuid",
                                   [NSNumber numberWithInt:18933], @"major", [NSNumber numberWithInt:21670], @"minor",
                                   [NSNumber numberWithInt:0], @"count", [NSNumber numberWithFloat:0], @"avarage", nil];
    NSMutableDictionary *table2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Table 2 - Purple", @"name",
                                   @"B9407F30-F5F8-466E-AFF9-25556B57FE6D", @"uuid",
                                   [NSNumber numberWithInt:33271], @"major", [NSNumber numberWithInt:30927], @"minor",
                                   [NSNumber numberWithInt:0], @"count", [NSNumber numberWithFloat:0], @"avarage", nil];
    NSMutableDictionary *table3 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Table 3 - Blue", @"name",
                                   @"B9407F30-F5F8-466E-AFF9-25556B57FE6D", @"uuid",
                                   [NSNumber numberWithInt:53725], @"major", [NSNumber numberWithInt:36531], @"minor",
                                   [NSNumber numberWithInt:0], @"count", [NSNumber numberWithFloat:0], @"avarage", nil];
    self.arrTables = [[NSMutableArray alloc] init];
    [self.arrTables addObject:table1];
    [self.arrTables addObject:table2];
    [self.arrTables addObject:table3];
    
    self.updateCount = 0;
    
    //self.beacons = [[NSMutableArray alloc] init];
    
    // This location manager will be used to demonstrate how to range beacons.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Populate the regions we will range once.
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    /*
    for (NSUUID *uuid in @[@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"])
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        self.rangedRegions[region] = [NSArray array];
    }*/
    
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] identifier:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    [self.locationManager startRangingBeaconsInRegion:self.region];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    /*
     CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    self.rangedRegions[region] = beacons;
    [self.beacons removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    /*
     for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
     {
     NSLog(@"Range: %@", range);
     NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
     if([proximityBeacons count])
     {
     self.beacons[range] = proximityBeacons;
     }
     }*/
    
    self.beacons = allBeacons;
    
    NSLog(@"Update beacons: %d", ++self.updateCount);
    for (int i=0;i<self.beacons.count;i++) {
        CLBeacon *beacon = [beacons objectAtIndex:i];
        //NSLog(@"Beacons: %@ %@ %@ %.2fm", [[beacon proximityUUID] UUIDString], beacon.major, beacon.minor, beacon.accuracy);
        if (beacon.accuracy > 0) { // sometime, value from the beacon is -1.00, I don't know what it means
            for (int i=0;i<self.arrTables.count;i++) {
                NSMutableDictionary *dictTable = [self.arrTables objectAtIndex:i];
                if ([[dictTable objectForKey:@"uuid"] isEqualToString:[[beacon proximityUUID] UUIDString]] && [[dictTable objectForKey:@"major"] intValue] == [beacon.major intValue] && [[dictTable objectForKey:@"minor"] intValue] == [beacon.minor intValue]) {
                    
                    int count = [[dictTable objectForKey:@"count"] intValue];
                    float totalValue = [[dictTable objectForKey:@"avarage"] floatValue]*count + beacon.accuracy;
                    count++;
                    [dictTable setObject:[NSNumber numberWithInt:count] forKey:@"count"];
                    [dictTable setObject:[NSNumber numberWithFloat:totalValue/count] forKey:@"avarage"];
                    NSLog(@"Beacon: %@ %.2fm %@ %@ %f", [dictTable objectForKey:@"name"], beacon.accuracy, [dictTable objectForKey:@"count"], [dictTable objectForKey:@"avarage"], totalValue);
                }
            }
        }
    }
    
    // check if any beacon have value for more than 5 times
    int index5TimeCount = -1;
    for (int i=0;i<self.arrTables.count;i++) {
        if ([[[self.arrTables objectAtIndex:i] objectForKey:@"count"] intValue] >= 3) {
            index5TimeCount = i;
        }
    }
    
    if (index5TimeCount >= 0) {
        NSLog(@"================FOUND NEAREST BEACON");
        [self.locationManager stopRangingBeaconsInRegion:self.region];
        float lowestValue = 100000;
        int lowestValueIndex = -1;
        self.arrNearbyTables = [[NSMutableArray alloc] init];
        
        for (int i=0;i<self.arrTables.count;i++) {
            NSDictionary *table = [self.arrTables objectAtIndex:i];
            if ([[table valueForKey:@"count"] intValue] > 0) {
                [self.arrNearbyTables addObject:table];
                NSLog(@"Beacon: %@ %@ %@", [[self.arrTables objectAtIndex:i] objectForKey:@"name"], [[self.arrTables objectAtIndex:i] valueForKey:@"count"], [[self.arrTables objectAtIndex:i] valueForKey:@"avarage"]);
                float tableAvgValue = [[[self.arrTables objectAtIndex:i] objectForKey:@"avarage"] floatValue];
                if (tableAvgValue < lowestValue) {
                    lowestValue = tableAvgValue;
                    lowestValueIndex = i;
                }
            }
        }
        
        if (lowestValueIndex >= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.strStore message:[NSString stringWithFormat:@"You're staying at %@", [[self.arrTables objectAtIndex:lowestValueIndex] objectForKey:@"name"]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Not this one", @"Yes", nil];
            [alert show];
            [self hideLoadingIndicator];
        }
        
        //NSLog(@"Lowest value: %d, %.2fm", lowestValueIndex, lowestValue);
    }

    //[self.tableView reloadData];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView reloadData];
    if (buttonIndex == 0) {
        // "Not this one" button
        
    } else {
        // Move to details view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *detailsVC = [storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];
        [self.navigationController pushViewController:detailsVC animated:YES];
        //[self.tableView reloadData];
    }
}

#pragma mark - UITableView datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrNearbyTables != nil) {
        [tableView viewWithTag:10].alpha = 1.0f;
        return self.arrNearbyTables.count;
    }
    [tableView viewWithTag:10].alpha = 0.0f;
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storeTableCell"];
    
    UIView *circleView = [cell viewWithTag:1];
    circleView.layer.cornerRadius = 24;
    circleView.layer.borderColor = [UIColor colorWithRed:45.0/255.0 green:186.0/255.0 blue:206.0/255.0 alpha:1.0].CGColor;
    circleView.layer.borderWidth = 2;
    
    
    circleView.clipsToBounds = YES;
    [circleView setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *dictTable = [self.arrNearbyTables objectAtIndex:indexPath.row];
    
    UILabel *lbDistance = (UILabel *)[cell viewWithTag:2];
    [lbDistance setText:[NSString stringWithFormat:@"%.1fm", [[dictTable objectForKey:@"avarage"] floatValue]]];
    [lbDistance setTextColor:[UIColor colorWithRed:45.0/255.0 green:186.0/255.0 blue:206.0/255.0 alpha:1.0]];
    
    UILabel *lbTableName = (UILabel *)[cell viewWithTag:3];
    [lbTableName setText:[dictTable objectForKey:@"name"]];
    
    [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableCell"]]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //[cell.textLabel setText:[dictTable objectForKey:@"name"]];
    //[cell.detailTextLabel setText:[NSString stringWithFormat:@"Distance: %.2fm", [[dictTable objectForKey:@"avarage"] floatValue]]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // To "clear" the footer view
    return [UIView new];
}

#pragma mark - UITableView datasource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *detailsVC = [storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];
    [self.navigationController pushViewController:detailsVC animated:YES];
}

/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 75)];
    
    UILabel *lbRestaurant = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 24)];
    [lbRestaurant setFont:[UIFont boldSystemFontOfSize:18]];
    [lbRestaurant setTextAlignment:NSTextAlignmentCenter];
    [lbRestaurant setText:self.strStore];
    
    UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 22)];
    [lbDescription setFont:[UIFont systemFontOfSize:16]];
    [lbDescription setText:@"Please chooose a table below"];
    
    [headerView addSubview:lbRestaurant];
    [headerView addSubview:lbDescription];
    
    return headerView;
}*/

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

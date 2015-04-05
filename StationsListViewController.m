//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "BikeStation.h"
#import "BikeData.h"
#import "MapViewController.h"

// plist NSLocationWhenInUseUsageDescription  & "Share location to find bike stations"

@interface StationsListViewController () <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, BikeDataDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *bikeStationArray;
@property NSMutableArray *searchArray;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property BikeData *bikeData;
@property BOOL isFiltered;

@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Chicago Bike Stations"]];

    self.bikeData = [BikeData new];
    self.bikeData.delegate = self;
    self.bikeStationArray = [NSMutableArray new];

    self.searchBar.delegate = self;

    self.locationManager = [CLLocationManager new];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.isFiltered == YES) {
        return self.searchArray.count;
    } else  {
        return self.bikeStationArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeCell"];

    if (self.isFiltered == YES) {
        BikeStation *bikes = [self.searchArray objectAtIndex:indexPath.row];
        cell.textLabel.text = bikes.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Available bikes: %@  >>  Distance: %.2f miles", bikes.availableBikes, bikes.distance/1000];
    } else {
        BikeStation *bikes = [self.bikeStationArray objectAtIndex:indexPath.row];
        cell.textLabel.text = bikes.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Available bikes: %@  >>  Distance: %.2f miles", bikes.availableBikes, bikes.distance/1000];
    }
    return cell;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 500 && location.verticalAccuracy < 500) {
            self.userLocation = location;
            [self.bikeData getBikeStationLocation:self.userLocation];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location not found"
                                                    message:@"Please make sure you have enabled location in your device settings"
                                                   delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - BikeStation Delegate

- (void)getArrayOfBikes:(NSMutableArray *)stations {

    self.bikeStationArray = stations;
    [self.tableView reloadData];
}

#pragma mark - UISearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length == 0) {
        self.isFiltered = NO;

    } else {
        self.isFiltered = YES;
        self.searchArray = [NSMutableArray new];

        // http://www.peterfriese.de/using-nspredicate-to-filter-data/
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.stationName CONTAINS %@", searchText];
        self.searchArray = [NSMutableArray arrayWithArray:[self.bikeStationArray filteredArrayUsingPredicate:predicate]];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)cell {
    MapViewController *mapVC = segue.destinationViewController;

    if (self.searchBar.text.length != 0) {
        mapVC.bikeStation = self.searchArray[[[self.tableView indexPathForCell:cell] row]];
    } else {
        mapVC.bikeStation = self.bikeStationArray[[[self.tableView indexPathForCell:cell] row]];
    }

    MKPointAnnotation *user = [MKPointAnnotation new];
    user.coordinate = self.userLocation.coordinate;
}

@end





















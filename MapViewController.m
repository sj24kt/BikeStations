//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "BikeStation.h"

// plist NSLocationAlwaysUsageDescription  & "Share your location to show nearest bikes"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *bikeStationAnnotation;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.bikeStation.title;

    [self displayUserView];
    [self displayUsersLocation];
    [self setRegionOnMap];
}

- (void)displayUserView {

    self.locationManager.delegate = self;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    [self.mapView setMapType:MKMapTypeStandard];
}

- (void)displayUsersLocation {
    self.locationManager.delegate = self;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;

    // Adds the specified annotation to the map view
    [self.mapView addAnnotation:self.bikeStation];
}

- (void)setRegionOnMap {

    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;

    MKCoordinateRegion region;
    region.center = self.bikeStation.coordinate;
    region.span = span;

    [self.mapView setRegion:region animated:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 1000 && location.verticalAccuracy < 1000) {
            self.userLocation = location;
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

#pragma mark - MapKit Delegate Methods

// set the annotation bike pin for the row tapped
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    // if this pin location is same as current location
    if ([annotation isEqual:mapView.userLocation]) {
        return nil;
    }

    // instantiate the pin with a reuseID
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];

    // the callout uses the title and subtitle text from the annotation object
    pin.canShowCallout = YES;
    pin.image = [UIImage imageNamed:@"bikeImage"];
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    // Add an image to the left callout.
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bikeImage"]];
    pin.leftCalloutAccessoryView = iconView;

    return pin;
}

// when the rightCalloutAccessoryView disclosure is tapped show an alert with directions to bike station
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

     // Make a directions request & set the current/source location
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];

    // set the destination location
    MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:self.bikeStation.coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placemark];
    request.destination = mapItem;


    // Get directions for specified request
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject;

        int counter = 1;
        NSMutableString *directionsString = [NSMutableString string];

        for (MKRouteStep *step in route.steps) {

             [directionsString appendFormat:@"%d: %@\n", counter, step.instructions];
             counter++;
        }

        UIAlertView *directionsAlert = [[UIAlertView alloc] initWithTitle:@"Directions:"
                                                                   message:directionsString
                                                                  delegate:self
                                                         cancelButtonTitle:self.title
                                                        otherButtonTitles:nil];

        [directionsAlert show];

         [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
     }];

    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {

    if ([overlay isKindOfClass:[MKPolyline class]]) {

        MKPolyline *route = overlay;
        MKPolylineRenderer *rendered = [[MKPolylineRenderer alloc] initWithPolyline:route];
        rendered.strokeColor = [UIColor colorWithRed:0.42 green:0.27 blue:0.89 alpha:1.00];
        rendered.lineWidth = 5.0;
        return rendered;
    } else {
        return nil;
    }
}

@end

























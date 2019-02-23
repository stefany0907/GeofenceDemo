//
//  ViewController.m
//  GeofenceDemo
//
//  Created by Matt Chen on 2/17/19.
//  Copyright © 2019 Matt Chen. All rights reserved.
//

#import "ViewController.h"
#import "MapKit/MapKit.h"
#import "MapPin.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusCheck;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL mapIsMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnno;

@property (strong,nonatomic) CLCircularRegion *geoRegion;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Turn off the Interface until permission is acquired
    
    MKCoordinateRegion pin = {{0.0, 0.0}, {0.0, 0.0}};
//    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(37.7749, -122.4194);

    pin.center.latitude = 37.7749;
    pin.center.longitude = -122.4194;
    pin.span.latitudeDelta = 0.01f;
    pin.span.longitudeDelta = 0.01f;
    [self.mapView setRegion:pin animated:YES];

    MapPin *bus = [[MapPin alloc] init];
    bus.title = @"Stefanyccr inc";
    bus.coordinate = pin.center;

    [self.mapView addAnnotation:bus];
    
//    MapPin *annotation = [[MapPin alloc] init];
//    annotation.title = @"Ahmedabad";
//    annotation.image = [UIImage imageNamed:@"icon1.png"];
//    annotation.subtitle = @"City";
//    annotation.coord = CLLocationCoordinate2DMake(42.292337, -83.717010);
//    [self.mapView addAnnotation:annotation];
    
    self.uiSwitch.enabled = NO;
    self.statusCheck.enabled = NO;
    
    self.eventLabel.text = @"Event";
    self.statusLabel.text = @"Status";
    self.mapIsMoving = NO;
    
    // Setup location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 20; //meters
    
    // Zoom the map close by default
    //    CLLocationCoordinate2D noLocation;
    CLLocationCoordinate2D noLocation = CLLocationCoordinate2DMake(37.7749, -122.4194);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500); // 500 by 500
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    NSLog(@"adjustedRegion");
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    NSLog(@"addCurrentAnnotation");
    // Create annotation for the user's location
    [self addCurrentAnnotation];
    
    NSLog(@"setUpGeoRegion");
    // Set up a geoRegion object
    [self setUpGeoRegion];
    
//    MKPointAnnotation *tmp = [[MKPointAnnotation alloc] init];
//    tmp.coordinate = noLocation;
//    [self.mapView addAnnotation:tmp];
//    MKPointAnnotation *ping = [[MKPointAnnotation alloc] init];
////    ping.coordinate = CLLocationCoordinate2DMake(42.292040, -83.716249);
//    [ping setCoordinate:CLLocationCoordinate2DMake(42.292040, -83.716249)];
//    [ping setTitle:@"Stefanyccr Inc"];
//    [self.mapView addAnnotation:ping];

    
    // Check if the davice is capable to do geofence
    if (([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) == YES) {
        CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
        if (currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse || currentStatus == kCLAuthorizationStatusAuthorizedAlways) {
            self.uiSwitch.enabled = YES;
        } else {
            [self.locationManager requestAlwaysAuthorization];
        }

        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//        UNAuthorizationOptions options =
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        self.statusLabel.text = @"GeoRegion not Supported";
    }
}



- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    if (currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse || currentStatus == kCLAuthorizationStatusAuthorizedAlways) {
        self.uiSwitch.enabled = YES;
    }
}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    self.mapIsMoving = YES;
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    self.mapIsMoving = NO;
}

- (void) setUpGeoRegion{
    //Create geo region to monitor
    self.geoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(42.294713, -83.708525) radius:100 identifier:@"MyRegionIdentifier"];
}

- (IBAction)switchTapped:(id)sender {
    if (self.uiSwitch.isOn) {
        NSLog(@"Switch is tapped on");
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringForRegion:self.geoRegion];
        self.statusCheck.enabled = YES;
    } else {
        NSLog(@"Switch is tapped off");
        self.statusCheck.enabled = NO;
        [self.locationManager stopMonitoringForRegion:self.geoRegion];
        [self.locationManager stopUpdatingLocation];
        self.mapView.showsUserLocation = NO;
    }
    
}

- (void) addCurrentAnnotation{
    self.currentAnno = [[MKPointAnnotation alloc] init];
    self.currentAnno.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnno.title = @"My Location";
}

- (void) centerMap:(MKPointAnnotation *)centerPoint{
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}



#pragma mark - location call backs
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    self.currentAnno.coordinate = locations.lastObject.coordinate;
    if (self.mapIsMoving == NO) {
        [self centerMap:self.currentAnno];
    }
}

- (IBAction)statusCheckTapped:(id)sender {
    [self.locationManager requestStateForRegion:self.geoRegion];
}

#pragma mark - geoFence call backs
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region {
    if (state == CLRegionStateUnknown) {
        self.statusLabel.text = @"Unknown";
    } else if (state == CLRegionStateInside) {
        self.statusLabel.text = @"Inside";
    } else if (state == CLRegionStateOutside) {
        self.statusLabel.text = @"Outside";
    } else {
        self.statusLabel.text = @"Else";
    }
}


- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region{
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"GeoFence Alert";
    note.alertBody = [NSString stringWithFormat:@"You entered the geofence"];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    self.eventLabel.text = @"Entered";
    NSLog(@"*******Entered the region*******");
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"GeoFence Alert";
    note.alertBody = [NSString stringWithFormat:@"You left the geofence"];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    self.eventLabel.text = @"Exit";
    NSLog(@"*******Exit the region*******");
}

@end

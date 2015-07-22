//
//  ViewController.m
//  MapsExample
//
//  Created by Manjula Jonnalagadda on 7/22/15.
//  Copyright (c) 2015 Manjula Jonnalagadda. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<MKMapViewDelegate,UISearchBarDelegate>{
    
    CLGeocoder *_geocoder;
}

@property(nonatomic,strong)CLLocationManager *manager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager=[[CLLocationManager alloc]init];
    [self.manager requestAlwaysAuthorization];
    
    UILongPressGestureRecognizer *gestureRecognizer=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    
    gestureRecognizer.minimumPressDuration=0.2;
    
    [self.mapView addGestureRecognizer:gestureRecognizer];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleGesture:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    CGPoint pt=[gestureRecognizer locationInView:gestureRecognizer.view];

    CLLocationCoordinate2D coord=[self.mapView convertPoint:pt toCoordinateFromView:self.mapView];
    CLLocation *location=[[CLLocation alloc]initWithLatitude:coord.latitude longitude:coord.longitude];
    
    if (!_geocoder) {
        _geocoder=[CLGeocoder new];
    }

    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }

        CLPlacemark *placemark=placemarks.firstObject;
        MKPointAnnotation *annotation=[[MKPointAnnotation alloc]init];
        annotation.title=placemark.name;
        annotation.subtitle=placemark.locality;
        annotation.coordinate=placemark.location.coordinate;
        [self.mapView addAnnotation:annotation];
        MKCoordinateSpan span=MKCoordinateSpanMake(0.5, 0.5);
        MKCoordinateRegion region=MKCoordinateRegionMake(placemark.location.coordinate, span);
        self.mapView.region=region;

    }];
    

    
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateSpan span=MKCoordinateSpanMake(0.5, 0.5);
    MKCoordinateRegion region=MKCoordinateRegionMake(mapView.userLocation.coordinate, span);
    mapView.region=region;
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (!_geocoder) {
        _geocoder=[CLGeocoder new];
    }
    [_geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        CLPlacemark *placemark=placemarks.firstObject;
        MKPointAnnotation *annotation=[[MKPointAnnotation alloc]init];
        annotation.coordinate=placemark.location.coordinate;
        annotation.title=placemark.name;
        annotation.subtitle=placemark.locality;
        [self.mapView addAnnotation:annotation];
        MKCoordinateSpan span=MKCoordinateSpanMake(0.5, 0.5);
        MKCoordinateRegion region=MKCoordinateRegionMake(placemark.location.coordinate, span);
        self.mapView.region=region;
    }];
    
}

@end

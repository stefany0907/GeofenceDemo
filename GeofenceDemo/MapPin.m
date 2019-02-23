//
//  MapPin.m
//  GeofenceDemo
//
//  Created by Matt Chen on 2/21/19.
//  Copyright © 2019 Matt Chen. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithTitle:(NSString *)newtitle Location:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self != nil) {
        self.title = newtitle;
        self.coordinate = location;

    }
    return self;
}

- (MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CustomAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"original"];
    return annotationView;
}
@end

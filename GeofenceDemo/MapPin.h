//
//  MapPin.h
//  GeofenceDemo
//
//  Created by Matt Chen on 2/21/19.
//  Copyright © 2019 Matt Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapPin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;


- (id)initWithTitle:(NSString *)newtitle Location:(CLLocationCoordinate2D)lcation;
- (MKAnnotationView *)annotationView;

@end

NS_ASSUME_NONNULL_END

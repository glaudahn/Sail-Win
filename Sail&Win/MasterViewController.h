//
//  ViewController.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 29.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>   // for LocationManager
#import <MapKit/MapKit.h>               // für Ortsdarstellung
#import "SetShipPositionDidChangeProtocol.h"
#import "SetBuoyPositionDidChangeProtocol.h"
#import "SetCountdownDidChangeProtocol.h"
#import "SpeedCalibrationDidChangeProtocol.h"

@class CLLocationManagerDelegate;

@interface MasterViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, SetShipPositionDidChangeProtocol, SetBuoyPositionDidChangeProtocol, SetCountdownDidChangeProtocol, SpeedCalibrationDidChangeProtocol>

@end

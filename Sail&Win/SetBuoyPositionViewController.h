//
//  SetBuoyPositionViewController.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 30.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "SetBuoyPositionDidChangeProtocol.h"


@interface SetBuoyPositionViewController : UIViewController

@property (strong, nonatomic) NSString *contentLongitude;                       // NSString-Wert Longitude
@property (strong, nonatomic) NSString *contentLatitude;                        // NSString-Wert Latitude
@property (strong, nonatomic) NSString *contentLongitudeBuoy;                   // NSString-Wert Longitude Buoy
@property (strong, nonatomic) NSString *contentLatitudeBuoy;                    // NSString-Wert Latitude Buoy
@property (strong, nonatomic) NSString *contentSetBuoyPositionLabel;            // NSString-Wert BuoyPositionLabel
@property (strong, nonatomic) NSString *contentprefferedSide;                   // NSString-Wert prefferedSide
@property (strong, nonatomic) id <SetBuoyPositionDidChangeProtocol> parentVC;      // Property zur Rückgabe an den Eltern VC

@end

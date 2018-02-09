//
//  SetShipViewController.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 30.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "SetShipPositionDidChangeProtocol.h"


@interface SetShipPositionViewController : UIViewController

@property (strong, nonatomic) NSString *contentLongitude;                       // NSString-Wert Longitude
@property (strong, nonatomic) NSString *contentLatitude;                        // NSString-Wert Latitude
@property (strong, nonatomic) NSString *contentLongitudeShip;                   // NSString-Wert Longitude Ship
@property (strong, nonatomic) NSString *contentLatitudeShip;                    // NSString-Wert Latitude Ship
@property (strong, nonatomic) NSString *contentSetShipPositionLabel;            // NSString-Wert ShipPositionLabel
@property (strong, nonatomic) NSString *contentprefferedSide;                   // NSString-Wert prefferedSide
@property (strong, nonatomic) id <SetShipPositionDidChangeProtocol> parentVC;      // Property zur Rückgabe an den Eltern VC

@end

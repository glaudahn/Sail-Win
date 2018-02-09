//
//  SpeedCalibrationViewController.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 28.04.15.
//  Copyright (c) 2015 Günter Laudahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "SpeedCalibrationDidChangeProtocol.h"

@interface SpeedCalibrationViewController : UIViewController

@property (strong, nonatomic) NSString *contentSpeedCalibrationSh;              // NSString-Wert
@property (strong, nonatomic) NSString *contentSpeedCalibrationCenter;          // NSString-Wert
@property (strong, nonatomic) NSString *contentSpeedCalibrationB;               // NSString-Wert
@property (strong, nonatomic) NSString *contentWindDirection;                   // NSString-Wert Windrichtung
@property (strong, nonatomic) id <SpeedCalibrationDidChangeProtocol> parentVC;  // Property zur Rückgabe an den Eltern VC

@end

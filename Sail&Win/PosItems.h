//
//  PosItems.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 31.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PosItems : NSObject

@property (strong, nonatomic) NSString *longitude;  //__________________________ NSString-Wert LongitudeTest
@property (strong, nonatomic) NSString *latitude;   //__________________________ NSString-Wert LatitudeTest
@property (strong, nonatomic) NSString *longitudeSailer;  //____________________ NSString-Wert LongitudeSailer
@property (strong, nonatomic) NSString *latitudeSailer;   //____________________ NSString-Wert LatitudeSailer
@property (strong, nonatomic) NSString *longitudeShip;  //______________________ NSString-Wert LongitudeShip
@property (strong, nonatomic) NSString *latitudeShip;   //______________________ NSString-Wert Latitudeship
@property (strong, nonatomic) NSString *longitudeBuoy;  //______________________ NSString-Wert LongitudeBuoy
@property (strong, nonatomic) NSString *latitudeBuoy;   //______________________ NSString-Wert LatitudeBuoy
@property (strong, nonatomic) NSString *longitudeTarget;  //____________________ NSString-Wert LongitudeTarget
@property (strong, nonatomic) NSString *latitudeTarget;   //____________________ NSString-Wert LatitudesTarget
@property (strong, nonatomic) NSString *remainTime;  //_________________________ NSString-Wert remainTime
@property (strong, nonatomic) NSString *disTarget;   //_________________________ NSString-Wert disTarget
@property (strong, nonatomic) NSString *estimateTime;   //______________________ NSString-Wert estimateTime
@property (strong, nonatomic) NSString *speedToTarget;   //_____________________ NSString-Wert speedToTarget
@property (strong, nonatomic) NSString *speed;             //___________________ NSString-Wert speed GPS
@property (strong, nonatomic) NSString *course;          //_____________________ NSString-Wert course
@property (strong, nonatomic) NSString *setStartLabel;      //__________________ NSString-Wert startLabel
@property (strong, nonatomic) NSString *setShipPositionLabel;  //_______________ NSString-Wert setShipPositionLabel
@property (strong, nonatomic) NSString *setBuoyPositionLabel;   //______________ NSString-Wert setBuoyPositionLabel
@property (strong, nonatomic) NSString *setCountDownLabel;   //_________________ NSString-Wert setCountDownLabel
@property (strong, nonatomic) NSString *horizontalAccuracy;     //______________ NSString-Wert horizGenauigkeit
@property (strong, nonatomic) NSString *preferredSide;          //______________ NSString-Wert horizGenauigkeit
@property (strong, nonatomic) NSString *leer;                   //______________ NSString-Wert horizGenauigkeit
@property (strong, nonatomic) NSString *SpeedCalSh;               //______________ NSString-Wert kal. Geschwindigkeit
@property (strong, nonatomic) NSString *SpeedCalCenter;               //______________ NSString-Wert kal. Geschwindigkeit
@property (strong, nonatomic) NSString *SpeedCalB;               //______________ NSString-Wert kal. Geschwindigkeit
@property (strong, nonatomic) NSString *windDegree;               //______________ NSString-Wert kal. Geschwindigkei
@end

//
//  ViewController.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 29.05.14.
//  Update by Guenter Laudahn on 05.03.2016
//  Version V.1.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import "MasterViewController.h"
#import <CoreLocation/CoreLocation.h>   // for LocationManager
#import "PosItems.h"    // für Werteuebergabe
#import "SetShipPositionViewController.h"   // für GPS Daten Übergabe
#import "SetBuoyPositionViewController.h"   // für GPS Daten Übergabe
#import "SetCountdownViewController.h"
#import "SpeedCalibrationViewController.h"
#import "DrawingView.h"


@interface MasterViewController () <CLLocationManagerDelegate, SetShipPositionDidChangeProtocol, SetBuoyPositionDidChangeProtocol, SetCountdownDidChangeProtocol>

///Debug define Anweisung
#define LogPretty NSLog(@"Zeile:  %d %s",__LINE__, __PRETTY_FUNCTION__);

#pragma mark ___________________________________________________________________ Properties

@property (strong, nonatomic) IBOutlet UILabel *masterLongitudeLabel;             //________ zur Darstellung Longitude im Master
@property (strong, nonatomic) IBOutlet UILabel *masterLatitudeLabel;              //________ zur Darstellung Latitude im Master
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *startLocation;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;                      //________ zur Darstellung der Uhrzeit
@property (strong, nonatomic) IBOutlet UILabel *estimateTime;                   //________ zur Darstellung der Time estimate
@property (strong, nonatomic) IBOutlet UILabel *disTarget;                      //________ zur Darstellung der Distance to Target
@property (strong, nonatomic) IBOutlet UILabel *timeRemain;                     //________ zur Darstellung der Time remain
@property (strong, nonatomic) IBOutlet UILabel *speedToTarget;                  //________ zur Darstellung der Speed To Target
@property (strong, nonatomic) IBOutlet UILabel *courseSailer;                   //________ zur Darstellung der Gradzahl
@property (strong, nonatomic) IBOutlet UILabel *horizonGenauigkeit;             //________ zur Darstellung der horizontalen Genauigkeit
@property (strong, nonatomic) IBOutlet UILabel *speed;                          //________ zur Darstellung der GPS Geschwindigkeit
#pragma mark ___________________________________________________________________ Buttons & Labels

@property (strong, nonatomic) IBOutlet UILabel *setShipMasterLabel;
@property (strong, nonatomic) IBOutlet UILabel *setBuoyMasterLabel;
@property (strong, nonatomic) IBOutlet UILabel *setCountMasterLabel;
@property (strong, nonatomic) IBOutlet UILabel *setStartMasterLabel;

//______________________________________________________________________________ for setButton and Label
@property UILabel *label;
@property UIButton *button;
@property UIButton *buttonSetShip;
@property UIButton *buttonSetBuoy;
@property UIButton *buttonStartCount;
@property UIButton *buttonSpeedCalibration;
@property UIButton *buttonTimeEstimate;
@property UIButton *buttonSpeedtoTarget;
@end


@implementation MasterViewController

    PosItems *posItems;                 // Anlegen einer Instanz von PosItems
    NSTimer *clockTimer;                // Anlegen einer Instanz von Timer für Uhrzeit
    NSTimer *timerCountDown;            // Anlegen einer Instanz von Timer für CountDown
    DrawingView *drawingView;           // Anlegen einer Instanz von DrawingView


// -----------------------------------------------------------------------------------------------------------------------------------------------Bereich für Testzwecke - später löschen

// Werte für Tabelle und Simulation später löschen

//Theorie:
//Abstände berechnen (Quelle: http://www.kompf.de/gps/distcalc.html):
//                    Quelldatei: Geo Daten Berechnung/ KN Berechnung neu vom 22.02.2016.numbers
//                    Formel zur Berechnung des Abstandes zwischen zwei GPS Werten P1 und P2:
//                    P1(lon1,lat1)  P2(lon2,lat2)
//                    lon und lat müssen in Bogenmaß angegeben werden, -> ( * Pi / 180 )
//                    dist wird in Meter errechnet
//                    
//                    dist = 1000 * 6378.388 * acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1))
//                    Beispiel1:
//                    Bezeichnung         GPS in °     im Bogenmass     Abstand der beiden Punkte in m
//                    Lon1 / Länge 1 /  X:  8,41321000      0,14683822        1593,42 m
//                    Lat1 / Breite 1 / Y: 49,99170000      0,87251976
//                    Lon2 / Länge 2 /  X:  8,42182000      0,14698849
//                    Lat2 / Breite 2 / Y: 50,00490000      0,87275015
//                    
//                    Beispiel2:  0,00000898280000 ist 1 m am Äquator  0,00001468 ist 1 m  in Berlin
//                    Bezeichnung             GPS in °          im Bogenmass     Abstand der beiden Punkte in m
//                    Lon1 / Länge 1 /  X:  0,00000897500      0,0000001566433        1 m
//                    Lat1 / Breite 1 / Y:  0                  0
//                    Lon2 / Länge 2 /  X:  0                  0
//                    Lat2 / Breite 2 / Y:  0                  0

//                    beim Lon1-Lon2 Abstand von 0,00000898280000  entspricht 1 m  am Äquator
//                    beim Lon1-Lon2 Abstand von 0,0000898280000  entspricht 10 m  am Äquator
//                    beim Lon1-Lon2 Abstand von 0,000898280000  entspricht 100 m  am Äquator
//                    beim Lon1-Lon2 Abstand von 0,00898280000  entspricht 1.000 m am Äquator
//                    beim Lon1-Lon2 Abstand von 0,0898280000  entspricht 10.000 m am Äquator
//                    der Breitenabstand ist überall gleich und ist bei 0,00000898280000  1 m


 //Testbatterie 1.

//    double xShStart = -122.030633;                     // xGPS Position des Startschiffes
//    double yShStart = 37.331820;                     // yGPS Position des Startschiffes
//    double xSaStart = -122.030533; //027 /2;                     // xGPS Position des Seglers
//    double ySaStart = 37.331920;                     // yGPS Position des Seglers
//    double xBStart = -122.030433;                      // xGPS Position der Boje
//    double yBStart = 37.331820;                      // yGPS Position der Boje

// Testbatterie 2. Schiff links

//    double xShStart = 0.0;                     // xGPS Position des Startschiffes (0,0)
//    double xSaStart = 0.00135;                     // xGPS Position des Seglers  ca. 150 m
//    double xBStart = 0.0027;                      // xGPS Position der Boje  ca. 300 m
//
//    double yShStart = 0.0;                     // yGPS Position des Startschiffes
//    double ySaStart = 0.0027;                     // yGPS Position des Seglers
//    double yBStart = 0.0000;                      // yGPS Position der Boje

    double xShStart = 0.0;                     // xGPS Position des Startschiffes
    double xSaStart = 0.00135;                     // xGPS Position des Seglers
    double xBStart = 0.0027;                      // xGPS Position der Boje

    double yShStart = 0.0;                     // yGPS Position des Startschiffes
    double ySaStart = 0.0010;                     // yGPS Position des Seglers
    double yBStart = 0.00;                      // yGPS Position der Boje


// Testbatterie 3. Schiff rechts

//double xShStart = 0.0027;                     // xGPS Position des Startschiffes
//double yShStart = 0.0;                     // yGPS Position des Startschiffes
//double xSaStart = 0.0027;                     // xGPS Position des Seglers
//double ySaStart = 0.0027;                     // yGPS Position des Seglers
//double xBStart = 0.0;                      // xGPS Position der Boje
//double yBStart = 0.0;                      // yGPS Position der Boje


// Testbatterie 4. Schiff links oben
////
//double xShStart = 0.0;                     // xGPS Position des Startschiffes
//double yShStart = 0.0027;                     // yGPS Position des Startschiffes
//double xSaStart = 0.0027;                     // xGPS Position des Seglers
//double ySaStart = 0.0027;                     // yGPS Position des Seglers
//double xBStart = 0.0;                      // xGPS Position der Boje
//double yBStart = 0.0;                      // yGPS Position der Boje


    int z = 0;
    int korrCounter = 1;
    id line = (@"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");



-(void)debugVariablen
{
    xShStart = posItems.longitudeShip.doubleValue;   // xGPS Position des Startschiffes
    yShStart = posItems.latitudeShip.doubleValue;    // yGPS Position des Startschiffes
    xBStart = posItems.longitudeBuoy.doubleValue;    // xGPS Position der Boje
    yBStart = posItems.latitudeBuoy.doubleValue;     // yGPS Position der Boje
    xSaStart = posItems.longitude.doubleValue;       // xGPS Position des Seglers
    ySaStart = posItems.latitude.doubleValue;        // yGPS Position des Seglers
    courseSa = posItems.course.doubleValue;     // xGPS Course des Startschiffes
    speedSa = posItems.speed.doubleValue;       // xGPS Speed des Startschiffes

    if (z == 0)
    {
        NSLog(@" ");
        NSLog(@"Nr.  xShStart    yShStart    xSaStart    ySaStart    xBStart      yBStart       xSh        ySh       xSa       ySa         xB          yB     WinkelSaTa  courseSa, speedSa, spToTarget, countNumberT xSaInc ySaInc    xTaInc   yTaInc        xCenter     yCenter   bevorzSeite    "); // M      Mx     My SaShDis SaBDis SaCenterDis ShBDis");
        NSLog(@"%@", line);
    }
    NSLog(@"%.2d   %f   %f   %f   %f   %f   %f   %f   %f   %f   %f   %f   %f   %f  %f %f  %f %ld %f %f   %f   %f   %f   %f  %@", korrCounter, xShStart, yShStart, xSaStart, ySaStart, xBStart, yBStart, xSh, ySh, xSa, ySa, xB, yB, winkelSaTa, courseSa, speedSa, speedSaToTarget, (long)countNumberTr, xSaInc, ySaInc,  xTaInc, yTaInc,   xCenter, yCenter ,  posItems.preferredSide); //, M, Mx ,My, disSaSh, disSaB, disSaCenter, disShB);        %.0f  %.0f  %.0f   %.0f    %.0f    %.0f      %.0f
    z = z +1;
    if (z == 10)
    {
        z = 0;
    }
}

-(void)simulationZwischenschalten

/// hier wird courseSa und speedSa verändert per Hand
// um die Simulation ein oder auszuschalten, im Bereich: VariablenFeld posItems füllen mit GPS Daten
// vom LocationManager den Aufruf  //[self simulationZwischenschalten] aktivieren
{
    
    korrCounter = korrCounter +1 ;           // Counter verändert courseSa und speedSa
    
    if (korrCounter > 0) {
        courseSa = 180;
        speedSa = 4;
    }
    if (korrCounter > 5) {
        courseSa = 0;
        speedSa = 4;
    }
    if (korrCounter > 10) {
        courseSa = 180;
        speedSa = 4;
   }
//    if (korrCounter > 30) {
//        courseSa = 20.0;
//        speedSa = 4;
//    }
//    if (korrCounter > 32) {
//        courseSa = 120.0;
//        speedSa = 4;
//
//    }
//    
//    if (korrCounter > 64) {
//        courseSa = 215.0;
//        speedSa = 4;
    
//    }
   // NSLog(@"korrCounter: %d", korrCounter);

    /// VariablenFeld posItems füllen mit Simulationsdaten
    
    
    xSaInc = speedSa * 0.00000901501 *  sin(courseSa / 180.0 * M_PI) ;//; //Änderungsanteil der x-Richtung bei vorgegebenen courseSA und speedSa
    ySaInc = speedSa * 0.00000901501 *  cos(courseSa / 180.0 * M_PI) ; //; //Änderungsanteil der y-Richtung bei vorgegebenen courseSA und speedSa
    
    xSaStart = xSaStart + xSaInc;
    ySaStart = ySaStart + ySaInc;
    
    posItems.longitudeShip= [NSString stringWithFormat:@"%f", xShStart];
    posItems.latitudeShip = [NSString stringWithFormat:@"%f", yShStart];
    posItems.longitudeBuoy = [NSString stringWithFormat:@"%f", xBStart];
    posItems.latitudeBuoy = [NSString stringWithFormat:@"%f", yBStart];
    posItems.longitude = [NSString stringWithFormat:@"%f", xSaStart];                                      ///Länge Segler
    posItems.latitude = [NSString stringWithFormat:@"%f", ySaStart];                                    ///Breite Segler
    posItems.horizontalAccuracy = [NSString stringWithFormat:@"%d", 5];                         /// horizontale Genauigkeit im m
    posItems.course = [NSString stringWithFormat:@"%.0f°", courseSa];                                                   ///Course vom GPS in grd
    posItems.speed = [NSString stringWithFormat:@"%.1f", speedSa];                                                     ///Geschwindigkeit vom GPS in m
}

// -------------------------------------------------------------------------------------------------------------------------------------------------Bereich für Testzwecke Ende - später löschen

#pragma mark ___________________________________________________________________ Variable festlegen

// Koordinaten initialisieren
// verwendete Abkürzungen Sa Sailer, Sh Startship, B Buoy, Sar Sailer Richtungspfeil

double xSh = 0;                     // xGPS Position des Startschiffes
double ySh = 0;                     // yGPS Position des Startschiffes
double xSa = 0;                     // xGPS Position des Seglers
double ySa = 0;                     // yGPS Position des Seglers
double xB = 0;                      // xGPS Position der Boje
double yB = 0;                      // yGPS Position der Boje
double courseSa = 0;                // Richtung Nord Course Segler
double speedSa = 0;                 // Geschwindigkeit des Seglers
double speedSaToTarget = 0;                 // Geschwindigkeit des Seglers
double xSaGespeichert = 0;          // alte xGPS Position des Seglers
double ySaGespeichert = 0;          // alte yGPS Position des Seglers
double xTaInc = 0;                  // Anteil der x-Richtung des Seglerweges bezogen auf GPS Speed und Course
double yTaInc = 0;                  // Anteil der y-Richtung des Seglerweges bezogen auf GPS Speed und Course

double xSaPfInc = 0;//; //Änderungsanteil der x-Richtung bei vorgegebenen courseSA und speedSa
double ySaPfInc = 0 ; //; //Änderungsanteil der y-Richtung bei vorgegebenen courseSA und speedSa

double xTa = 0;                     // x-Position nach Normierung des bevorzugten Ziels (Center, xSh oder xB nach Normierung)
double yTa = 0;                     // y-Position nach Normierung des bevorzugten Ziels (Center, xSh oder xB nach Normierung)
/// Hinweise zur Normierung:
/// Normierung bedeutet, dass


int Draw_X = 240;                   // Größe der verfügbaren Zeichnungsfläche in Pixel  320 x-Richtung
int Draw_Y = 240;                   // Größe der verfügbaren Zeichnungsfläche in Pixel  320 y-Richtung
int Zeichnungs_X = 200;             // Größe der benutzten Zeichnungsfläche in Pixel  290 x-Richtung
int Zeichnungs_Y = 200;             // Größe der benutzten Zeichnungsfläche in Pixel  290 y-Richtung

// Variablen für berechnete Werte für die Simulation und bei GPS Betrieb
double xSaInc = 0;                    // inkrementeller Anteil des Weges in x-Richtung des Seglers
double ySaInc = 0;                    // inkrementeller Anteil des Weges in y-Richtung des Seglers

//double xSh;                     // xGPS Position des Startschiffes
//double ySh;                     // yGPS Position des Startschiffes

double xSar = 0;                    // xGPS Position des Richtungspfeilspitze des Seglers
double ySar = 0;                    // yGPS Position des Richtungspfeilspitze des Seglers
double xCenter = 0;                 // xGPS Position des Center
double yCenter = 0;                 // yGPS Position des Center
double disToTargetSa = 0;          // Weg pro sek des Seglers in Zielrichtung
double timeEstimateSa = 0;          // erwartete Ankunftszeit an der Startlinie von Sa
double winkelSaTa = 0;              // Winkel von Sa zum Ziel

double xShBo = 0;                   //Werte im Bogenmass
double yShBo = 0;                   //Werte im Bogenmass
double xSaBo = 0;                   //Werte im Bogenmass
double ySaBo = 0;                   //Werte im Bogenmass
double xBBo = 0;                    //Werte im Bogenmass
double yBBo = 0;                    //Werte im Bogenmass
double xCenterBo = 0;               // xMittelpunkt Strecke xSh-xB im Bogenmass
double yCenterBo = 0;               // yMittelpunkt Strecke ySh-yB im Bogenmass
double xTaBo = 0;
double yTaBo = 0;

double disSaSh = 0;                 // Abstand Sa Sh
double disSaB = 0;                  // Abstand Sa B
double disShB = 0;                  // Abstand Sh B
double disSaCenter;                 // Abstand Sa Center
double disToTarget = 0;             // Abstand Sa zum Ziel
double disToBestArea = 0;           // Abstand Sa zum Ziel

double xSarGespeichert = 0;                 /// alter xSa gespeichert
double ySarGespeichert = 0;                 /// alter ySa gespeichert

double M = 0;                       /// Massstab ist der kleinere Wert aus Mx und My
double Mx = 0;                      // Massstab x-Richtung
double My = 0;                      // Massstab y-Richtung

double xMax = 0;                    // Werte für Massstabsberechnung, grösster xWert
double yMax = 0;                    // Werte für Massstabsberechnung, grösster yWert
double xMitte = 0;                  // Werte für Massstabsberechnung, gemittelter xWert
double yMitte = 0;                  // Werte für Massstabsberechnung, gemittelter yWert
double xMin = 0;                    // Werte für Massstabsberechnung, kleinster xWert
double yMin = 0;                    // Werte für Massstabsberechnung, kleinster yWert
int bevorStartSeite = 0;            // bevorzugte Seite = 0, dann Mitte; = 1, dann Sh; = 2, dann B
int windDirection = 0;              // Werte für Massstabsberechnung, kleinster yWert

double x_bestArea = 0;              // Werte für Ellepse bestArea,  x Wert
double y_bestArea = 0;              // Werte für Ellepse bestArea,  y Wert
double xl_bestArea = 0;             // Werte für Ellepse bestArea,  x Länge Wert
double yl_bestArea = 0;             // Werte für Ellepse bestArea,  y Länge Wert
double countNum = 0;                // Wert für die Abstandsberechnung zwischen Target und BestArea

NSInteger countNumberTr;             // Integer für Time remain
NSInteger secondsTr;                 // Integer für Time remain
NSInteger minutesTr;                 // Integer für Time remain
NSInteger hoursTr;                   // Integer für Time remain

NSInteger countNumberEt;             // Integer für Estimat Time
NSInteger secondsEt;                 // Integer für Estimat Time
NSInteger minutesEt;                 // Integer für Estimat Time
NSInteger hoursEt;                   // Integer für Estimat Time


#pragma mark ___________________________________________________________________ viewDidLoad

- (void)viewDidLoad                                                             // beim Laden des MasterViewControler erfolgt
{
    [super viewDidLoad];
    [self setButtonAndLabelForSelectedIphone];                                  // A1. Button und Label für das entsprechende iPhone setzen
    posItems = [[PosItems alloc]init];                                          // A2. VariablenFeld von PosItems initialisieren
    [self prepareLocationManager];                                              // A3. GPS LocationManager vorbereiten
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
    
//    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
//    [trianglePath moveToPoint:CGPointMake(0, view3.frame.size.height-100)];
//    [trianglePath addLineToPoint:CGPointMake(view3.frame.size.width/2,100)];
//    [trianglePath addLineToPoint:CGPointMake(view3.frame.size.width, view2.frame.size.height)];
//    [trianglePath closePath];
//    
//    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
//    [triangleMaskLayer setPath:trianglePath.CGPath];
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, size.width, size.height)];
//    
//    view.backgroundColor = [UIColor colorWithWhite:.75 alpha:1];
//    view.layer.mask = triangleMaskLayer;
//    [self.view addSubview:view];

    
}

#pragma mark ___________________________________________________________________ viewDidAppear

- (void)viewWillAppear:(BOOL)animated                                           // beim Erscheinen des MasterViewControler erfolgt
{
    [super viewWillAppear:animated];
    [self startLocationManager];                                                // A4. GPS Location Manager starten
    [self startTimerClock];                                                     // A5. Uhr vorbereiten und starten
}

- (void)viewWillDisappear:(BOOL)animated                                        // bei dem Verschwinden des MasterViewControler erfolgt
{
    [self stopLocationManager];                                                 // der GPS Location Manager wird gestoppt
    [self stopTimerClock];                                                      // die Uhr wird gestoppt
                                                                                // damit nach Schließen des Views nicht LocationManager und Clock doppelt laufen
}

#pragma mark ___________________________________________________________________ Uhr Methoden

-(void) startTimerClock                                                         // 5. Uhr vorbereiten
{
    clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clockTick:)userInfo:nil repeats:YES];
    [clockTimer fire];                                                          // bedeutet, dass clockTick sekündlich ausgeführt wird
}


- (void)stopTimerClock                                                          // der View-Controller wird aus dem Speicher entfernt und die Uhr angehalten.
{
    [clockTimer invalidate];
    clockTimer = nil;
}

- (void)clockTick:(NSTimer*)timer                                               // dieses wird jede Sekunde ausgeführt
{
    NSDate *today = [NSDate date];                                              // Das aktuelle Datum und die aktuelle Uhrzeit holen.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];            // Einen NSDateFormatter konfigurieren.
    [dateFormatter setDateFormat:@"HH:mm:ss"];                                  // Zeitformat auf HH:mm:ss setzen.
    NSString *currentTime = [dateFormatter stringFromDate:today];               // Uhrzeit dem String currentTime übergeben
    [self.timeLabel setText:currentTime];                                       // Uhrzeit im MasterView anzeigen
    [self showFlags];                                                           // Flags im MasterView anzeigen
}

#pragma mark ___________________________________________________________________ LocationManager Methoden

- (void) prepareLocationManager                                                 // A3. GPS LocationManager vorbereiten
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLHeadingFilterNone;
    self.locationManager.delegate = self;
}

- (void) startLocationManager                                                   // A4. GPS Location Manager starten
{
    [self.locationManager startUpdatingLocation];
}

- (void) stopLocationManager                                                    // GPS Location Manager stoppen
{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
                                                                                // Beim Starten des GPS LocationManagers erfolgt
                                                                                // B1. die originalen GPS Signale Breite, Länge, Genauigkeit, course und speed werden ermittelt
                                                                                // B2. Werte werden ins Variablenfeld posItems geschrieben
                                                                                // B3. Anzeige der Werte auf dem iPhone sekündlich
                                                                                // B4. Werte für die Map neu berechnen sekündlich
{
/// B1. die originalen GPS Signale Breite, Länge, Genauigkeit, Course und Speed werden ermittelt
    CLLocation *location = [locations lastObject];  ///location enthält alle Werte: location = <+37.33019345,-122.02598301> +/- 10.00m (speed 3.80 mps / course 85.48) @ 4/5/15, 8:33:58 AM
    NSString *formattedLatitude = [NSString stringWithFormat:@"%+.8f°", location.coordinate.latitude];
    NSString *formattedLongitude = [NSString stringWithFormat:@"%+.8f°", location.coordinate.longitude];         ///L1.
    NSString *horizontalAccuracy = [NSString stringWithFormat:@"%.0f", location.horizontalAccuracy];
    NSString *course = [NSString stringWithFormat:@"%.0f°", location.course];
    NSString *speed = [NSString stringWithFormat:@"%.1f", location.speed  * 1.9438444924574];
    

    
/// B2. Werte werden ins Variablenfeld posItems geschrieben
    posItems.latitude = formattedLatitude;                                      ///Länge
    posItems.longitude = formattedLongitude;                                    ///Breite
    posItems.horizontalAccuracy = horizontalAccuracy;                           /// horizontale Genauigkeit im m
    posItems.course = course;                                                   ///Course vom GPS in grd
    posItems.speed = speed;                                                     ///Geschwindigkeit vom GPS in kn
    
    //[self simulationZwischenschalten]; // Hier werden simulierte Werte eingespielt, muss abgeschaltet werden bei Realbetrieb        ##############################################################################

/// B3. Auslesen aus posItems und Anzeige der Werte auf dem iPhone sekündlich
    [self.masterLongitudeLabel setText:posItems.longitude];                     // Longitude von Sa im MasterView anzeigen
    [self.masterLatitudeLabel setText:posItems.latitude];                       // Latitude von Sa im MasterView anzeigen
    [self.horizonGenauigkeit setText:posItems.horizontalAccuracy];              // horizontale im MasterView anzeigen
    [self.courseSailer setText:posItems.course];
    [self.speed setText:posItems.speed];                                    // speed im MasterView anzeigen
    
    
    
//    if ([course  isEqual: @"-1°"])                                              // wenn kein aktueller course ermittelbar, dann
//    {
//        [self.courseSailer setText:posItems.leer];                              // courseSailer im MasterView  leer anzeigen
//    }
//    else
//    {
//    [self.courseSailer setText:posItems.course];                                // courseSailer im MasterView anzeigen
//    }
//
//    if ([speed  isEqual: @"-1.9"])                                              // wenn keine aktuelle spesd ermittelbar, dann
//    {
//        [self.speed setText:posItems.leer];                                     // speed im MasterView  leer anzeigen
//        [self.speedToTarget setText:posItems.leer];                             // speedToTarget im MasterView  leer anzeigen
//        [self.timeRemain setText:posItems.leer];                                // timeRemain  leer anzeigen
//        [self.horizonGenauigkeit setText:posItems.leer];                        // horizonGenauigkeit im MasterView  leer anzeigen
//    }
//    else
//    {

    //        [self.speedToTarget setText:posItems.speedToTarget];                    // Speed to Target im MasterView anzeigen
//    }
    
/// B4. Werte für die Map neu berechnen sekündlich
    [self transformLocation];
}


#pragma mark ___________________________________________________________________ CountDownMethoden

-(void)timerCountDownMethode
{
/// Hier ist die vom TimerCountDownStart ausgelöste Methode zum Anzeigen der Countdownzeit
    if (countNumberTr > 0)                                                       // CountnumberCd hat die in Picker eingestellte Zeit
    {
    countNumberTr --;
    hoursTr = (countNumberTr /3600);
    minutesTr = (countNumberTr % 3600) / 60;
    secondsTr = (countNumberTr % 3600) % 60;
    self.timeRemain.text = [NSString stringWithFormat:@"%.2li:%.2li", (long)minutesTr, (long)secondsTr]; // Anzeigen der Countdownzeit
    }
    else
    {
    [self timerCountDownStop];                                                  // wenn CountDownZeit zu ende, dann löschen des Timers
    }
}


-(void)timerCountDownStart
{
///Hier wird der TimerCountDown gestartet durch Start drücken
    timerCountDown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCountDownMethode) userInfo:nil repeats:YES];
    [timerCountDown fire];
}

/// Hier wird der TimerCountDown gestoppt
-(void)timerCountDownStop  
{
    [timerCountDown invalidate];
    timerCountDown = nil;

}

    #pragma mark _________________________________________________________________________________________ Berechnungs Methoden

- (void) transformLocation
{
/// T1: Übernahme der Koordinaten Sh-Ship, B-Buoy, Sa-Sailer, courseSa und speedSa
/// T2: Ermittlung der kleinsten Werte der Koordinaten von Ship, Buoy und Sailer und Wert subtrahieren
///     damit wird ein Punkt auf die Koordinaten (0;0) gesetzt
/// T3: Distance Sa-Sh  Distance Sa-B  Distance Sa-Center Distance Sh-B errechnen
/// T4: DistanceToTarget der bevorzugte Seite einstellen
/// T5: Winkel berechen, der die Richtung vom Target zum Segler angiebt (Richtung des Kompass)
/// T6: Anteil der Bewegung in Richtung Startpunkt (speedSaToTarget) wird berechnet
/// T7: Restzeit zum Startpunkt berechnen

/// T1 - Übernahme der Koordinaten Ship, Buoy, Sailer, courseSa, speedSa und Wind
    xSh = posItems.longitudeShip.doubleValue;   // xGPS Position des Startschiffes
    ySh = posItems.latitudeShip.doubleValue;    // yGPS Position des Startschiffes
    xB = posItems.longitudeBuoy.doubleValue;    // xGPS Position der Boje
    yB = posItems.latitudeBuoy.doubleValue;     // yGPS Position der Boje
    xSa = posItems.longitude.doubleValue;       // xGPS Position des Seglers
    ySa = posItems.latitude.doubleValue;        // yGPS Position des Seglers
    speedSa = posItems.speed.doubleValue;       // xGPS Geschwindigkeit des Seglers
    courseSa = posItems.course.doubleValue;        // yGPS Course des Seglers
    //NSLog(@"xSh: %f ySh: %f xSa: %f ySa: %f xB: %f yB: %f  speedSa: %f courseSa: %f", xSh, ySh, xSa, ySa, xB, yB,  speedSa, courseSa);
/// x Werte + 360°, y Werte + 90° Spalte 15-22
/// dadurch verschwinden die negativen Werte
    xSh = xSh + 360;
    ySh = ySh + 90;
    xSa = xSa + 360;
    ySa = ySa + 90;
    xB = xB + 360;
    yB = yB + 90;

/// T2: xMin, yMin berechnen Spalte 23 24
/// damit wird der kleinste Längen- und Breitengrad berechnet
    xMin = MIN(xSh, xSa);
    xMin = MIN(xMin, xB);
    yMin = MIN(ySh, yB);
    yMin = MIN(yMin, yB);
    
/// den kleinsten xWert auf Null setzen durch Subtraktion aller xWerte mit xMin Spalte 26 - 32
/// den kleinsten yWert auf Null setzen durch Subtraktion mit yMin Spalte
    xSh = xSh - xMin;
    ySh = ySh - yMin;
    xSa = xSa - xMin;
    ySa = ySa - yMin;
    xB = xB - xMin;
    yB = yB - yMin;
    
/// wenn ein xWert > 180, dann diesen von 360 abziehen
    if (xSh > 180)
    {
        xSh = 360 - xSh;
    }
    if (xSa > 180)
    {
        xSa = 360 - xSa;
    }
    if (xB > 180)
    {
        xB = 360 - xB;
    }

    
    
/// Center Koordinaten berechnen, Center ist der Mittelpunkt der Strecke Sh-B
    xCenter = (xSh + xB)/2;
    yCenter = (ySh + yB)/2;
   
/// Positionswerte in Bogenmass umrechen für weitere Berechnungen
    xShBo = xSh / 180.0 * M_PI;
    yShBo = ySh / 180.0 * M_PI;
    xBBo =   xB / 180.0 * M_PI;
    yBBo =   yB / 180.0 * M_PI;
    xSaBo = xSa / 180.0 * M_PI;
    ySaBo = ySa / 180.0 * M_PI;
    xCenterBo = xCenter / 180.0 * M_PI;
    yCenterBo = yCenter / 180.0 * M_PI;


    #pragma mark _______________________________________________________________________________________________________________________________Speed, Distance to Target und Time Estimate
/// Berechnen von Speed, Distance to Target und Time Estimate
/// T3: Distance Sa-Sh  Distance Sa-B  Distance Sa-Center Distance Sh-B errechnen

    disSaSh = (acos(sin(ySaBo) * sin(yShBo) + cos(ySaBo) * cos(yShBo) * cos((xShBo - xSaBo)))) * 6366.707045 *1000;                 // Distance Sa-Sh errechnen in m
    disSaB = (acos(sin(ySaBo) * sin(yBBo) + cos(ySaBo) * cos(yBBo) * cos((xBBo - xSaBo))))  * 6366.707045 *1000;                    // Distance Sa-B errechnen in m
    disSaCenter = (acos(sin(ySaBo) * sin(yCenterBo) + cos(ySaBo) * cos(yCenterBo) * cos((xCenterBo - xSaBo))))  * 6366.707045 *1000;// Distance Sa-Center errechnen in m
    disShB = (acos(sin(yShBo) * sin(yBBo) + cos(yShBo) * cos(yBBo) * cos((xBBo - xShBo)))) * 6366.707045 *1000;                     // Distance Sh-B errechnen in m
    
//        NSLog(@"Segler Schiff %f",disSaSh);
//            NSLog(@"Segler Boje %f",disSaB);
//            //NSLog(@"disSaCenter %f",disSaCenter);
//            NSLog(@"Schiff Boje %f",disShB);
//    
    

/// T4: DistanceToTarget der bevorzugte Seite einstellen
/// xTa und yTa nehmen hier die Koordinaten von xSa und ySa auf, korrigiert um den Zielwert
    disToTarget = disSaCenter;                                                  // Standard ist Center
    bevorStartSeite = 0;                                                        // wenn bevorStartSeite = 0
    xTa = xSa - xCenter;                                                        // Tangens(xTa/yTa) berechnet den Winkel Zwischen Target und Segler
    yTa = ySa -yCenter;                                                         // da xSa;ySa Werte bezüglich 0;0 Koordinatenursprung sind, muss xTa;yTa auf das Ziel normiert werden
    xTaBo = xCenterBo;
    yTaBo = yCenterBo;
    
    if ([posItems.preferredSide  isEqual: @"StartShip"])
    {
        disToTarget = disSaSh;                                                  // bevorzugte Seite ist StartShiff
        bevorStartSeite = 1;                                                    // wenn bevorStartSeite = 1
        xTa = xSa - xSh;                                                        // Tangens(xTa/yTa) berechnet den Winkel Zwischen Target und Segler
        yTa = ySa - ySh;                                                         // da xSa;ySa Werte bezüglich 0;0 Koordinatenursprung sind, muss xTa;yTa auf das Ziel normiert werden
        xTaBo = xShBo;
        yTaBo = yShBo;
    }
    if ([posItems.preferredSide  isEqual: @"StartBuoy"])
    {
        disToTarget = disSaB;                                                   // bevorzugte Seite ist StartBuoy
        bevorStartSeite = 2;                                                    // wenn bevorStartSeite = 2
        xTa = xSa - xB;                                                         // Tangens(xTa/yTa) berechnet den Winkel Zwischen Target und Segler
        yTa = ySa -yB;                                                          // da xSa;ySa Werte bezüglich 0;0 Koordinatenursprung sind, muss xTa;yTa auf das Ziel normiert werden
        xTaBo = xBBo;
        yTaBo = yBBo;
    }

/// T5: Winkel berechen, der die Richtung vom Target zum Segler angiebt (Richtung des Kompass)
    winkelSaTa = acos((yTaBo - ySaBo) / (sqrt((xTaBo - xSaBo) * (xTaBo - xSaBo) + (yTaBo - ySaBo) * (yTaBo - ySaBo)))) * 180 / M_PI;

    if ((xTaBo - xSaBo) < 0 )
    {
        winkelSaTa = 360 - winkelSaTa;                                          // Berechnungsformel gibt nur Werte bis 180°
    }                                                                           // entsprechend des Vorzeichens von (xTaBo - xSaBo) werden die restlichen Werte berechnent
    
/// T6: Anteil der Bewegung in Richtung Startpunkt (speedSaToTarget) wird berechnet
    speedSaToTarget = speedSa  * cos((courseSa - winkelSaTa)  / 180 * M_PI);
    posItems.speedToTarget = [NSString stringWithFormat:@"%.1f", speedSaToTarget]; // Speichern der Geschwindigkeit zum Ziel in posItems, Ausgabe in B3.
    
/// T7: Restzeit zum Startpunkt berechnen
    countNumberEt = (disToTarget / speedSa);  // countNumberT ist die Zeit in sec für den Weg DisToTarget mit der Geschw. speedToTarget (Time Remain)
    
/// estimateTime zum Startpunkt berechnen
        hoursEt = (countNumberEt /3600);
        minutesEt = (countNumberEt % 3600) / 60;
        secondsEt = (countNumberEt % 3600) % 60;
        posItems.estimateTime = [NSString stringWithFormat:@"%.2li:%.2li", (long)minutesEt, (long)secondsEt];

 
    if (courseSa < 0)
    {
        posItems.estimateTime = @"";    //Wenn der Course < 0 ist, dann wird Estimate Time ausgeblendet =""
    }
    
    if (speedSaToTarget > 0)                                                    // so lange ein Geschwindigkeitsanteil in Richtung voreingestellte Startposition existiert, Zeitanzeige, sonst Meter in rot
    {
        self.speedToTarget.textColor = [UIColor blackColor];                    // Schriftfarbe von speedToTarget schwarz, weil speedToTarget positiv
        self.estimateTime.textColor = [UIColor blackColor];                     // Schriftfarbe von estimateTime schwarz, weil estimateTime positiv
        [self.buttonTimeEstimate setTitle:@"Time Estimate [min]" forState:UIControlStateNormal];
        [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonSpeedtoTarget setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
        else
    {
        posItems.estimateTime = [NSString stringWithFormat:@"%.0f", disToTarget];
        self.speedToTarget.textColor = [UIColor redColor];                      // Schriftfarbe rot, weil speedToTarget negativ
        self.estimateTime.textColor = [UIColor redColor];                       // Schriftfarbe von estimateTime rot, weil estimateTime negativ
        [self.buttonTimeEstimate setTitle:@"Distance to Target [m]" forState:UIControlStateNormal];
        [self.buttonTimeEstimate setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.buttonSpeedtoTarget setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    [self.estimateTime setText:posItems.estimateTime];                          // Zeit oder Abstand zum Ziel im MasterView anzeigen
    [self.speedToTarget setText:posItems.speedToTarget];                        // Speed to Target im MasterView anzeigen
    
/// Abstand zum Startpunkt aus den gemessenen Geschwindigkeit und der timeRemain berechnen
    
    if (countNumberTr > 0)
    {
        countNum = countNumberTr;
        disToBestArea = 1848.0 * posItems.SpeedCalSh.doubleValue / 3600 * countNum;
        //disToBestArea = 1848.0 * 4 / 3600 * countNum;
        //NSLog(@"disToBestArea %f",disToBestArea);
        /// hier fehlt noch die Auswahl des Ziels bei Targetwechsel
    
        //NSLog(@"countNumberTr: %ld ", (long)countNumberTr);
        //NSLog(@"posItems.SpeedCalSh: %ld ", (long)posItems.SpeedCalSh.intValue);
        //NSLog(@"disToBestArea: %f ", disToBestArea);
        //NSLog(@"disShB. %f",disShB);
    
    }
        //NSLog(@"posItems.SpeedCalB: %ld ", (long)posItems.SpeedCalB.intValue);
        //NSLog(@"posItems.SpeedCalCenter: %ld ", (long)posItems.SpeedCalCenter.intValue);

    
    
/// xMax xMin xMitte berechnen  Zeile 33 - 38
    
    xMax = MAX(xSh, xSa);
    xMax = MAX(xMax, xB);
    xMin = MIN(xSh, xSa);
    xMin = MIN(xMin, xB);
    yMax = MAX(ySh, ySa);
    yMax = MAX(yMax, yB);
    yMin = MIN(ySh, ySa);
    yMin = MIN(yMin, yB);
    xMitte = (xMax + xMin) / 2;
    yMitte = (yMax + yMin) / 2;
    
///∆Werte berechnen  Zeile 39 - 46, ∆Werte sind die Abstände vom Mittelpunkt
    
    xSh = xSh - xMitte;
    ySh = ySh - yMitte;
    xSa = xSa - xMitte;
    ySa = ySa- yMitte;
    xSar = xSar - xMitte;
    ySar = ySar - yMitte;
    xB = xB - xMitte;
    yB = yB - yMitte;
    xCenter = xCenter - xMitte;
    yCenter = yCenter - yMitte;
    
/// xTa und yTa nehmen hier die Koordinaten vom x- und y-Wert auf, entsprechend der bevorzugten Seite zum Zeichnen der Linie zum Startpunkt
    
    xTa = xCenter;                                                              // bevorzugte Seite ist Center
    yTa = yCenter;
    
    if (bevorStartSeite == 1)
    {
        xTa = xSh;                                                              // bevorzugte Seite ist StartSchiff
        yTa = ySh;
    }
    if ([posItems.preferredSide  isEqual: @"StartBuoy"])
    {
        xTa = xB;                                                              // bevorzugte Seite ist StartBoje
        yTa = yB;
    }
    
/// x und yMassstab  berechnen Zeile 47 - 48
/// M ist benutzte Zeichenfläche / xMax - xMin
/// der kleinere Massstab muss verwendet werden

    Mx = Zeichnungs_X / (xMax - xMin);
    My = Zeichnungs_X / (yMax - yMin);
    M = MIN(Mx, My);
   
/// Berechnung der Richtunganteile zum Zeichnen des aktuellen Kurses an Sa
    xSaInc = speedSa * 0.10104901501 *  sin(courseSa / 180.0 * M_PI) ;          //Änderungsanteil der x-Richtung bei vorgegebenen courseSA und speedSa
    ySaInc = speedSa * 0.10104901501 *  cos(courseSa / 180.0 * M_PI) ;          //Änderungsanteil der y-Richtung bei vorgegebenen courseSA und speedSa
    xSar = xSa + xSaInc;                                                        //Änderungsanteil wird zur xSa Position addiert
    ySar = ySa + ySaInc;                                                        //Änderungsanteil wird zur ySa Position addiert

/// Plazieren auf der Zeichnungsfläche
    xSh = (Draw_X - Zeichnungs_X) / 2 + (Zeichnungs_X / 2) + (M * xSh);          // ben. und gesamt. Zeichnungsfläche berücks.
    ySh = Draw_Y-((Draw_Y - Zeichnungs_Y) / 2 + (Zeichnungs_Y / 2) + (M * ySh));                /// um einen Rand zu erzeugen
    xSa = (Draw_X - Zeichnungs_X) / 2 + (Zeichnungs_X / 2)  + (M * xSa);        // y-Wert von Draw_Y abziehen, um Zeichenfläche zu spiegeln
    ySa = Draw_Y-((Draw_Y - Zeichnungs_Y) / 2 + (Zeichnungs_Y / 2)  + (M * ySa));
    xSar = (Draw_X - Zeichnungs_X) / 2 + (Zeichnungs_X / 2)  + (M * xSar);      // y-Wert von Draw_Y abziehen, um Zeichenfläche zu spiegeln
    ySar = Draw_Y-((Draw_Y - Zeichnungs_Y) / 2 + (Zeichnungs_Y / 2)  + (M * ySar));
    xB = (Draw_X - Zeichnungs_X) / 2 + (Zeichnungs_X / 2) + (M * xB);
    yB = Draw_Y-((Draw_Y - Zeichnungs_Y) / 2 + (Zeichnungs_Y / 2) + (M * yB));
    xCenter = (Draw_X - Zeichnungs_X) / 2 + (Zeichnungs_X / 2) + (M * xCenter);
    yCenter = Draw_Y-((Draw_Y - Zeichnungs_Y) / 2 + (Zeichnungs_Y / 2) + (M * yCenter));
    xTa = (Draw_X - Zeichnungs_X) / 2 + (Zeichnungs_X / 2) + (M * xTa);
    yTa = Draw_Y-((Draw_Y - Zeichnungs_Y) / 2 + (Zeichnungs_Y / 2) + (M * yTa));
    
    windDirection = posItems.windDegree.intValue;                               // Windrichtung wird übergeben
    if ([posItems.windDegree  isEqual: @"?"]) {
        windDirection = -1;                                                     // Wind ist noch nicht gesetzt über SetWind
    }
    
/// bestArea berechnen
    
    double normWert = 0;
    
    normWert = sqrt((xSh - xB) * (xSh - xB) + (ySh - yB) * (ySh - yB));
    //disToBestArea = normWert;
    
    
     //NSLog(@"normWert %f",normWert);
    normWert = normWert * disToBestArea / disShB;
    
    
//    NSLog(@"normWert %f",normWert);
//    NSLog(@"disToBestArea %f",disToBestArea);
//    NSLog(@"disShB %f",disShB);
//    NSLog(@"yl_bestArea %f",y_bestArea);
//        NSLog(@"speedSa %f",speedSa);
    
        x_bestArea = 180; //lokale Variable für Ellipse x-Kordinate
        y_bestArea = 60; //lokale Variable für Ellipse y-Kordinate
        xl_bestArea = 20; //lokale Variable für Ellipse xLänge-Kordinate
        yl_bestArea = 40; //lokale Variable für Ellipse yLänge-Kordinate
        yl_bestArea = normWert; //Zwischenlösung zur Übergabe des Kreisradius

    
    //[self debugVariablen];
    
//// Werte zum Zeichnen an DrawView übergeben
    [drawingView update:xSh update:ySh update:xB update:yB update:xSa update:ySa update:xSar update:ySar update:xCenter update:yCenter update:(int)xTa update:(int)yTa update:(int)windDirection update:(int)x_bestArea update:(int)y_bestArea update:(int)xl_bestArea update:(int)yl_bestArea];
    
}
#pragma mark ___________________________________________________________________ DrawingMap

-(void)appearMap
{
/// DrawingView erstellen oder löschen für unterschiedliche Grössen
    int exist = 0;
    for (UIView *subview in [self.view subviews])
    {
        if (subview.tag == 6)
        {
            [subview removeFromSuperview];      // Wenn View vorhanden, dann löschen
            exist = 1;
        }
    }
    if (exist == 0)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {    // The iOS device = iPhone or iPod Touch
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            //NSLog(@"iOSDeviceScreenSize.height: %f", iOSDeviceScreenSize.height);
            
            //NSLog(@"iOSDeviceScreenSize.height: %f", iOSDeviceScreenSize.height);
            
            if (iOSDeviceScreenSize.height == 480)  // 320 x 480
            {   // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation: 3.5 inch screen (diagonally measured)
                drawingView = [[DrawingView alloc]initWithFrame:CGRectMake(10,65,300,210)];
            }
            if (iOSDeviceScreenSize.height == 568)  //  320 x 568
            {   // iPhone 5 and iPod Touch 5th generation: 4 inch screen (diagonally measured)
                drawingView = [[DrawingView alloc]initWithFrame:CGRectMake(10,65,300,230)]; /// (0,65,320,320)
            }
            if (iOSDeviceScreenSize.height == 667)  //  375 x 667
            {   // iPhone 6 6s: 4.7 inch screen (diagonally measured)
                drawingView = [[DrawingView alloc]initWithFrame:CGRectMake(10,65,355,275)];
            }
            if (iOSDeviceScreenSize.height == 736)  //  414 x 736
            {   // iPhone 6 Plus  6s Plus 5.5 inch screen (diagonally measured)
                drawingView = [[DrawingView alloc]initWithFrame:CGRectMake(10, 65, 394, 320)];
            }
        }
        else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {   // The iOS device = iPad
        }
        [drawingView setBackgroundColor: [UIColor cyanColor]];
        drawingView.tag = 6;
        [self.view addSubview:drawingView];
    }
}

#pragma mark ___________________________________________________________________ ShowFlags Methoden

-(void)showFlags ///5. Flag anzeigen
{
    int wert1 = 0; // ShipFlag
    int wert2 = 0; // BuoyFlag
    int wert3 = 0; // CountdownFlag
    int wert4 = 0; // StartFlag
    
    wert1 = [posItems.latitudeShip intValue];                                   // wenn setShip nicht 0, grün, sonst rot
    if (wert1 == 0)
    {
        self.setShipMasterLabel.backgroundColor = [UIColor redColor];
        wert4 = 1;
    } else
        (self.setShipMasterLabel.backgroundColor = [UIColor greenColor]);
    
    wert2 = [posItems.latitudeBuoy intValue];                                   // wenn setBuoy nicht 0, grün, sonst rot
    if (wert2 == 0)
    {
        self.setBuoyMasterLabel.backgroundColor = [UIColor redColor];
        wert4 = 1;
    } else
        (self.setBuoyMasterLabel.backgroundColor = [UIColor greenColor]);
    
    wert3 = [posItems.remainTime intValue];                                     // wenn setCount nicht 0, grün, sonst rot
    if (wert3 == 0)
    {
        self.setCountMasterLabel.backgroundColor = [UIColor redColor];
        wert4 = 1;
    } else
        (self.setCountMasterLabel.backgroundColor = [UIColor greenColor]);
    if (wert4 == 1)                                                             // wenn setStart nicht 0, grün, sonst rot
    {
        self.setStartMasterLabel.backgroundColor = [UIColor redColor];
        
    } else
    {
        posItems.setStartLabel = @"1"; // wenn alle grün dann = 1
        (self.setStartMasterLabel.backgroundColor = [UIColor greenColor]);
    }
}

#pragma mark ______________________________________________SetShipPositionVC kommen hier zurück

- (void)longShipDidChange:(NSString *)newLongitude latiShipDidChange:(NSString *)newLatitude prefSideDidChange:(NSString *)newPreferredSide
{
    // _______________________Die Werte vom SetShipPositionVC kommen hier zurück
    posItems.longitudeShip = newLongitude;
    posItems.latitudeShip = newLatitude;
    posItems.preferredSide = newPreferredSide;
    // Den View-Controller der zweiten Szene wieder ausblenden.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)longBuoyDidChange:(NSString *)newLongitude latiBuoyDidChange:(NSString *)newLatitude prefSideDidChange:(NSString *)newPreferredSide
{
    // ______________ Die Werte vom SetBuoyPositionVC kommen hier zurück
    posItems.longitudeBuoy = newLongitude;
    posItems.latitudeBuoy = newLatitude;
    posItems.preferredSide = newPreferredSide;
    // Den View-Controller der zweiten Szene wieder ausblenden.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)werteCountDownDidChange:(NSString *)newRemainTime
{
    //  Wenn auf im CountDownController auf done gedrückt wurde, kommt hier newRemainTime vom CountDownVC Picker in sec zurück
    posItems.remainTime = newRemainTime;                                        // wird in posItems.remainTime gespeichert
    countNumberTr = posItems.remainTime.integerValue;                           // und angezeigt
    hoursTr = (countNumberTr /3600);
    minutesTr = (countNumberTr % 3600) / 60;
    secondsTr = (countNumberTr % 3600) % 60;
    self.timeRemain.text = [NSString stringWithFormat:@"%.2li:%.2li", (long)minutesTr, (long)secondsTr];
    [self timerCountDownStop];                                                  // der alte Timer wird gestoppt
    [self.navigationController popViewControllerAnimated:YES];                  // Den View-Controller der zweiten Szene wieder ausblenden.
    [self.buttonStartCount setTitle:@"Start" forState:UIControlStateNormal];     //Label des Set Count Button wird in Start umbenannt
}

- (void)wertSpeedCalShDidChange:(NSString *)newSpeedCalSh wertSpeedCalCenterDidChange:(NSString *)newSpeedCalCenter wertSpeedCalBDidChange:(NSString *)newSpeedCalB wertWindDirectionDidChange:newWindDirection;
{
    // ______________ Die Werte vom SpeedCalalibrationVC kommen hier zurück
    posItems.SpeedCalSh = newSpeedCalSh;
    posItems.SpeedCalCenter = newSpeedCalCenter;
    posItems.SpeedCalB = newSpeedCalB;
    posItems.windDegree = newWindDirection;
//    NSLog(@"posItems.SpeedCalSh: %@", posItems.SpeedCalSh);
//    NSLog(@"posItems.SpeedCalCenter: %@", posItems.SpeedCalCenter);
//    NSLog(@"posItems.SpeedCalB: %@", posItems.SpeedCalB);
//    NSLog(@"posItems.windDegree: %@", posItems.windDegree);
    
    // Den View-Controller der zweiten Szene wieder ausblenden.
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  __________________________________________________________________ Button Actions

-(void)pressButtonSpeedCalibration:(UIButton*) sender
//______________________________________________________________________________ pressButtonSpeedCal
{
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueSpeedCalibration" sender:self];
}
-(IBAction)buttonSetBuoyPositionPressed:(id)sender
//______________________________________________________________________________ pressButtonSetBuoyPosition
{
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueSetBuoyPosition" sender:self];
}
-(IBAction)buttonHelpPressed:(id)sender
    //__________________________________________________________________________ pressButtonHelp
{
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueHelpfromMVCToHVC" sender:self];
}
-(IBAction)buttonSetShipPositionPressed:(id)sender
    //__________________________________________________________________________ pressButtonSetShipPosition
{
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueSetShipPosition" sender:self];
}

-(IBAction)buttonMapPressed:(id)sender
//______________________________________________________________________________ pressButtonMap
{
    [self appearMap];
}
//______________________________________________________________________________ pressButton Start / Set Count
-(void)pressButtonStartCount:(UIButton*) sender
{
    if ([[sender currentTitle]  isEqual: @"Set Count"])                          // wenn Button heißt Set Count, dann öffnen der Zeiteinstellung für den Countdown
    {
        [self performSegueWithIdentifier:@"segueSetCountDown" sender:self];      // wenn die Zeiteinstellung mit done beendet wird, wird der Button in Start umbenannt
    }
    if ([[sender currentTitle]  isEqual: @"Start"])                              // wenn Button heißt Start, dann prüfen, ob alle Flags grün sind
    {
        if (posItems.setStartLabel.intValue == 1)                                // wenn alles grün, dann wird der Timer gestartet
        {
            if (timerCountDown == nil)                                           // wenn timerCountDown nicht läuft, dann
            {
                [self timerCountDownStart];
                [self.buttonStartCount setTitle:@"Set Count" forState:UIControlStateNormal];     //Label des Set Count Button wird in Start umbenannt
            }
        }
        else
        {
            [self performSegueWithIdentifier:@"segueStart" sender:self];         //wenn nicht alles grün, dann StartFesnter anzeigen
        }
    }
}

//______________________________________________________________________________ pressButtonTimeEstimate
-(void)pressButtonTimeEstimate:(UIButton*) sender
{

    //__________________________________________________________________________ pressButtonTime Estimate
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueTimeEstimate" sender:self];
}

//______________________________________________________________________________ pressButtonTimeRemain
-(void)pressButtonTimeRemain:(UIButton*) sender
{

    //__________________________________________________________________________ pressButtonTimeRemain
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueTimeRemain" sender:self];
}

//______________________________________________________________________________ pressButtonSpeedToTarget
-(void)pressButtonSpeedToTarget:(UIButton*) sender
{

    //__________________________________________________________________________ pressButtonSpeedToTarget
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueSpeedToTarget" sender:self];
}

//______________________________________________________________________________ pressButtonSpeed
-(void)pressButtonSpeed:(UIButton*) sender
{
    
    //__________________________________________________________________________ pressButtonSpeed
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueSpeedToTarget" sender:self];
}

//______________________________________________________________________________ pressButtonAccuracy
-(void)pressButtonAccuracy:(UIButton*) sender
{
    
    //__________________________________________________________________________ pressButtonAccuracy
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueAccuracy" sender:self];
}
//______________________________________________________________________________ pressButtonCourse
-(void)pressButtonCourse:(UIButton*) sender
{
    
    //__________________________________________________________________________ pressButtonCourse
    //den Segue mit seinem Identifier aufrufen
    [self performSegueWithIdentifier:@"segueCourse" sender:self];
}

#pragma mark ___________________________________________________________________ prepareForSegue Methode

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//______________________________________________________________________________ for SetShipPosition Segue
{
    if ([segue.identifier isEqualToString:@"segueSetShipPosition"])
    {
        SetShipPositionViewController *editController = segue.destinationViewController;
        editController.contentLongitude = posItems.longitude;
        editController.contentLatitude = posItems.latitude;
        editController.contentLongitudeShip = posItems.longitudeShip;
        editController.contentLatitudeShip = posItems.latitudeShip;
        editController.contentSetShipPositionLabel = posItems.setShipPositionLabel;
        editController.contentprefferedSide = posItems.preferredSide;
        //Der Controller übergibt sich selbst als Referenz an die zu öffnende Szene
        editController.parentVC = self;
        
    }
    else if ([segue.identifier isEqualToString:@"segueSetBuoyPosition"])
    {
        SetBuoyPositionViewController *editController = segue.destinationViewController;
        editController.contentLongitude = posItems.longitude;
        editController.contentLatitude = posItems.latitude;
        editController.contentLongitudeBuoy = posItems.longitudeBuoy;
        editController.contentLatitudeBuoy = posItems.latitudeBuoy;
        editController.contentSetBuoyPositionLabel = posItems.setBuoyPositionLabel;
        editController.contentprefferedSide = posItems.preferredSide;
        //Der Controller übergibt sich selbst als Referenz an die zu öffnende Szene
        editController.parentVC = self;
    }
    
    else if ([segue.identifier isEqualToString:@"segueSetCountDown"])
    {
        SetCountdownViewController *editController = segue.destinationViewController;
        editController.contentRemainTimeHours = @"--";
        //Der Controller übergibt sich selbst als Referenz an die zu öffnende Szene
        editController.parentVC = self;
    }
    
    else if ([segue.identifier isEqualToString:@"segueSpeedCalibration"])
    {
        //NSLog(@"wind: %@", posItems.windDegree);
        SpeedCalibrationViewController *editController = segue.destinationViewController;
        editController.contentSpeedCalibrationSh = posItems.SpeedCalSh;
        editController.contentSpeedCalibrationCenter = posItems.SpeedCalCenter;
        editController.contentSpeedCalibrationB = posItems.SpeedCalB;
        editController.contentWindDirection = posItems.windDegree;
        //Der Controller übergibt sich selbst als Referenz an die zu öffnende Szene
        editController.parentVC = self;
    }
}
#pragma mark ___________________________________________________________________ Select iPhone Typ
///_____________________________________________________________________________ Button und Label für das entsprechende iPhone setzen

//Pixelgröße der iPhones getestet
//5
//H: 568 B: 320
//H: 568 B: 320
//
//6
//H: 667 B: 375
//H: 667 B: 375
//
//6Plus
//H: 736 B: 414
//H: 736 B: 414
//
//7
//H:667 B:375
//H:1334 B:750
//
//7Plus
//H:736  B:414
//H:1920 B:1080
//
//8
//H:667  B:375
//H:1334  B:750
//
//8Plus
//H:736  B:414
//H:1920  B:1080
//
//SE
//H:568  B:320
//H:1920  B:1080
//
//X
//H: 812 B: 375
//H: 2436 B: 1125


/////_____________________________________________________________________________ Button und Label für das entsprechende iPhone setzen
//-(void)setButtonAndLabelForSelectedIphone
//{
//    //if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//        //CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//
//        //            NSLog(@"screenHeight: %f",screenHeight);
//        //            NSLog(@"screenWidt: %f",screenWidth);
//
//        if( screenHeight > 480 && screenHeight < 667 )
//        {
//            // iPhone 5/5s screenHeight=568 ,screenWidth=320
//            //NSLog(@"Günti's iPhone 5/5s");
//            [self setButtonAndLabelForiPhone5];
//        } else if ( screenHeight > 480 && screenHeight < 736 ){
//            // iPhone 6/6s screenHeight=667 ,screenWidth=375
//            //NSLog(@"iPhone 6/6s");
//            [self setButtonAndLabelForiPhone6];
//        } else if ( screenHeight > 480 ){
//            // iPhone 6/6s Plus screenHeight=736 ,screenWidth=414
//            //NSLog(@"Günti's iPhone 6/6s Plus");
//            [self setButtonAndLabelForiPhone6Plus];
//        } else {
//            // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation screenHeight=480 ,screenWidth=320
//            //NSLog(@"Günti's iPhone 4/4s");
//            [self setButtonAndLabelForiPhone4];
//        }
//    }
//}


///_____________________________________________________________________________ Button und Label für das entsprechende iPhone setzen
-(void)setButtonAndLabelForSelectedIphone
{
    //if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
                    NSLog(@"screenHeight: %f",screenHeight);
                    NSLog(@"screenWidt: %f",screenWidth);
        
        if( screenHeight > 480 && screenHeight < 667 )
        {
            // iPhone 5/5s screenHeight=568 ,screenWidth=320
             NSLog(@"Günti's iPhone 5/5s/SE");
            [self setButtonAndLabelForiPhone5];
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            // iPhone 6/6s screenHeight=667 ,screenWidth=375
             NSLog(@"iPhone 6/6s/7/8");
            [self setButtonAndLabelForiPhone6];
        } else if ( screenHeight > 480 && screenHeight < 812 ){
            // iPhone 6/6s Plus screenHeight=736 ,screenWidth=414
             NSLog(@"Günti's iPhone 6/6s/7/8 Plus");
            [self setButtonAndLabelForiPhone6Plus];
        } else if ( screenHeight > 480 ){
            // iPhone X screenHeight=812 ,screenWidth=375
             NSLog(@"Günti's iPhone X");
            [self setButtonAndLabelForiPhoneX];
        } else {
            // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation screenHeight=480 ,screenWidth=320
             NSLog(@"Günti's iPhone 4/4s");
            [self setButtonAndLabelForiPhone4];
        }
    }
}
/// ____________________________________________________________________________ set Button and Label      setButtonAndLabelForiPhone4
-(void)setButtonAndLabelForiPhone4
{
//NSLog(@"setze iPhone 4s");
    
    // _____________________________________________________________________ Label masterLatitudeLabel
    
    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 135, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLatitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    //[self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLatitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [self.masterLatitudeLabel setText:@"188.8888888"];
    [self.view addSubview:self.masterLatitudeLabel];
    
    // _____________________________________________________________________ Label masterLongitudeLabel
    
    self.masterLongitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 75, 135, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLongitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLongitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [self.masterLongitudeLabel setText:@"188.8888888"];
    [self.view addSubview:self.masterLongitudeLabel];
    
    // _____________________________________________________________________ Label setShipMasterLabel
    self.setShipMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 112, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setShipMasterLabel];
    
    // _____________________________________________________________________ Label setBuoyMasterLabel
    self.setBuoyMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 112, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setBuoyMasterLabel];
    
    // _____________________________________________________________________ Label setCountMasterLabel
    self.setCountMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 164, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setCountMasterLabel];
    
    // _____________________________________________________________________ Label setStartMasterLabel
    self.setStartMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 164, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setStartMasterLabel];
    
    // _________________________________________________________________________ Label Current Time
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 , 212 , 280 , 55)];
    self.timeLabel.textColor = [UIColor blackColor];
    [self.timeLabel setShadowColor:[UIColor whiteColor]];
    [self.timeLabel setShadowOffset:CGSizeMake(3, 3) ];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont fontWithName:@"Helvetica" size:68] ;
    self.timeLabel.text = @"88:88:88";
    [self.view addSubview:self.timeLabel];
    // _________________________________________________________________________ Label timeEstimate
    self.estimateTime = [[UILabel alloc]initWithFrame:CGRectMake(125 , 277 , 175 , 56)];
    self.estimateTime.textColor = [UIColor blackColor];
    [self.estimateTime setShadowColor:[UIColor whiteColor]];
    [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
    self.estimateTime.textAlignment = NSTextAlignmentRight;
    self.estimateTime.font = [UIFont fontWithName:@"Helvetica" size:68] ;
    self.estimateTime.text = @"88:88";
    self.estimateTime.tag = 8;
    [self.view addSubview:self.estimateTime];
    
    // _________________________________________________________________________ Label timeRemain
    self.timeRemain = [[UILabel alloc]initWithFrame:CGRectMake(125 , 341 , 175 , 56)];
    self.timeRemain.textColor = [UIColor blackColor];
    [self.timeRemain setShadowColor:[UIColor whiteColor]];
    [self.timeRemain setShadowOffset:CGSizeMake(3, 3) ];
    self.timeRemain.textAlignment = NSTextAlignmentRight;
    self.timeRemain.font = [UIFont fontWithName:@"Helvetica" size:68] ;
    self.timeRemain.text = @"88:88";
    [self.view addSubview:self.timeRemain];
    
    // _________________________________________________________________________ Label speedToTarget
    self.speedToTarget = [[UILabel alloc]initWithFrame:CGRectMake(125 , 405 , 175 , 56)];
    self.speedToTarget.textColor = [UIColor blackColor];
    [self.speedToTarget setShadowColor:[UIColor whiteColor]];
    [self.speedToTarget setShadowOffset:CGSizeMake(3, 3) ];
    self.speedToTarget.textAlignment = NSTextAlignmentRight;
    self.speedToTarget.font = [UIFont fontWithName:@"Helvetica" size:68];
    self.speedToTarget.text = @"88.8";
    [self.view addSubview:self.speedToTarget];
    
    // _____________________________________________________________________ Button Set Ship
    
    self.buttonSetShip = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetShip setFrame:CGRectMake(20, 105, 112, 44)];
    [self.buttonSetShip setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetShip.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetShip setTitle:@"Set Ship" forState:UIControlStateNormal];
    [self.buttonSetShip setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetShip.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetShip setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonSetShip.tag = 1;
    [self.buttonSetShip addTarget:self action:@selector(buttonSetShipPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetShip];
    
    // _____________________________________________________________________ Button Set Buoy
    
    self.buttonSetBuoy = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetBuoy setFrame:CGRectMake(188, 105, 112, 44)];
    [self.buttonSetBuoy setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetBuoy.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetBuoy setTitle:@"Set Buoy" forState:UIControlStateNormal];
    [self.buttonSetBuoy setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetBuoy.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetBuoy setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonSetBuoy.tag = 2;
    [self.buttonSetBuoy addTarget:self action:@selector(buttonSetBuoyPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetBuoy];
    
    
    
    // _____________________________________________________________________ Button StartCount
    
    self.buttonStartCount = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonStartCount setFrame:CGRectMake(20, 157, 112, 44)];
    [self.buttonStartCount setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonStartCount.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonStartCount setTitle:@"Set Count" forState:UIControlStateNormal];
    [self.buttonStartCount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonStartCount.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonStartCount setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonStartCount setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonStartCount setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonStartCount.tag = 3;
    [self.buttonStartCount addTarget:self action:@selector(pressButtonStartCount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonStartCount];
    
    // _____________________________________________________________________ Button Set Speed
    
    self.buttonSpeedCalibration = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSpeedCalibration setFrame:CGRectMake(188, 157, 112, 44)];
    [self.buttonSpeedCalibration setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSpeedCalibration.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSpeedCalibration setTitle:@"Set Speed" forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSpeedCalibration.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSpeedCalibration setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.buttonSpeedCalibration addTarget:self action:@selector(pressButtonSpeedCalibration:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSpeedCalibration];
    
    // _________________________________________________________________________ Button Time Estimate
    
    self.buttonTimeEstimate = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonTimeEstimate setFrame:CGRectMake(20, 276, 49, 44)];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonTimeEstimate setTitle:@"Time Estimate" forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.buttonTimeEstimate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	self.buttonTimeEstimate.titleLabel.numberOfLines = 2;
    self.buttonTimeEstimate.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.buttonTimeEstimate addTarget:self action:@selector(pressButtonSpeedToTarget:) forControlEvents:UIControlEventTouchUpInside];
    self.buttonTimeEstimate.tag = 5;
    [self.view addSubview:self.buttonTimeEstimate];

    // _________________________________________________________________________ Button Time Remain

    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(20.0, 341.0, 49.0, 44.0)];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Time Remain  [min]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	self.button.titleLabel.numberOfLines = 3;
    self.button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonTimeRemain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];

    // _________________________________________________________________________ Button Speed to Target
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(20.0, 405.0, 49.0, 44.0)];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Speed to Target   [kn]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	self.button.titleLabel.numberOfLines = 3;
    self.button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonSpeedToTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
}
/// ____________________________________________________________________________ set Button and Label      setButtonAndLabelForiPhone 5/5S
-(void)setButtonAndLabelForiPhone5
{
//NSLog(@"setze iPhone 5/5s");
    [self.view setBackgroundColor:[UIColor lightGrayColor]];  // Hintergrundfarbe des Views setzen
    
    //[self.view setBackgroundColor:[UIColor whiteColor]];  // Hintergrundfarbe des Views setzen
    
    // _____________________________________________________________________ Label masterLatitudeLabel
    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 135, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLatitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    //[self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLatitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [self.masterLatitudeLabel setText:@"188.8888888"];
    [self.view addSubview:self.masterLatitudeLabel];

    // _____________________________________________________________________ Label masterLongitudeLabel
    
    self.masterLongitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 75, 135, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLongitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLongitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [self.masterLongitudeLabel setText:@"188.8888888"];
    [self.view addSubview:self.masterLongitudeLabel];
    
    // _____________________________________________________________________ Label setShipMasterLabel
    self.setShipMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 112, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setShipMasterLabel];
    
    // _____________________________________________________________________ Label setBuoyMasterLabel
    self.setBuoyMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 112, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setBuoyMasterLabel];
    
    // _____________________________________________________________________ Label setCountMasterLabel
    self.setCountMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 164, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setCountMasterLabel];
    
    // _____________________________________________________________________ Label setStartMasterLabel
    self.setStartMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 164, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setStartMasterLabel];
  
     // _____________________________________________________________________ Button Set Ship
    self.buttonSetShip = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetShip setFrame:CGRectMake(20.0, 105.0, 112.0, 44.0)];
    [self.buttonSetShip setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetShip.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetShip setTitle:@"Set Ship" forState:UIControlStateNormal];
    [self.buttonSetShip setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetShip.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetShip setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonSetShip.tag = 1;
    [self.buttonSetShip addTarget:self action:@selector(buttonSetShipPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetShip];

    // _____________________________________________________________________ Button Set Buoy
    self.buttonSetBuoy = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetBuoy setFrame:CGRectMake(188.0, 105.0, 112.0, 44.0)];
    [self.buttonSetBuoy setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetBuoy.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetBuoy setTitle:@"Set Buoy" forState:UIControlStateNormal];
    [self.buttonSetBuoy setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetBuoy.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetBuoy setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonSetBuoy.tag = 2;
    [self.buttonSetBuoy addTarget:self action:@selector(buttonSetBuoyPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetBuoy];
    
        // _____________________________________________________________________ Button StartCount
        self.buttonStartCount = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonStartCount setFrame:CGRectMake(20.0, 157.0, 112.0, 44.0)];
        [self.buttonStartCount setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
        self.buttonStartCount.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonStartCount setTitle:@"Set Count" forState:UIControlStateNormal];
        [self.buttonStartCount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.buttonStartCount.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
        [self.buttonStartCount setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.buttonStartCount setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonStartCount setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.buttonStartCount.tag = 3;
        [self.buttonStartCount addTarget:self action:@selector(pressButtonStartCount:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonStartCount];
    
        // _____________________________________________________________________ Button Set Speed
        self.buttonSpeedCalibration = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonSpeedCalibration setFrame:CGRectMake(188.0, 157.0, 112.0, 44.0)];
        [self.button setBackgroundColor: [UIColor yellowColor]];
        [self.buttonSpeedCalibration setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
        self.buttonSpeedCalibration.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonSpeedCalibration setTitle:@"Set Speed" forState:UIControlStateNormal];
        [self.buttonSpeedCalibration setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.buttonSpeedCalibration.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
        [self.buttonSpeedCalibration setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.buttonSpeedCalibration setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonSpeedCalibration setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.buttonSpeedCalibration addTarget:self action:@selector(pressButtonSpeedCalibration:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonSpeedCalibration];
    
    // _____________________________________________________________________ Label Current Time
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 , 212 , 280 , 55)]; /// (x, y, Breite, Höhe)
    //[self.timeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setShadowOffset:CGSizeMake(3, 3) ];         // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:68]];
    [self.timeLabel setText:@"88:88:88"];
    [self.view addSubview:self.timeLabel];

    // _____________________________________________________________________ Button Time Estimate
    self.buttonTimeEstimate = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonTimeEstimate setFrame:CGRectMake(20, 310, 60, 55)];
    //[self.buttonTimeEstimate setBackgroundColor: [UIColor yellowColor]];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonTimeEstimate setTitle:@"Time Estimate [min]" forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.buttonTimeEstimate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.buttonTimeEstimate.titleLabel.numberOfLines = 3;
    self.buttonTimeEstimate.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonTimeEstimate.tag = 5;
    [self.buttonTimeEstimate addTarget:self action:@selector(pressButtonTimeEstimate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonTimeEstimate];

    // _____________________________________________________________________ Label timeEstimate
    self.estimateTime = [[UILabel alloc]initWithFrame:CGRectMake(90 , 310 , 210 , 55)];
    //[self.estimateTime setBackgroundColor: [UIColor yellowColor]];
    self.estimateTime.textColor = [UIColor blackColor];
    [self.estimateTime setShadowColor:[UIColor whiteColor]];
    [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
    self.estimateTime.textAlignment = NSTextAlignmentRight;
    [self.estimateTime setShadowColor:[UIColor whiteColor]];
    [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
    self.estimateTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:68] ;
    self.estimateTime.text = @"88:88";
    self.estimateTime.tag = 8;
    [self.view addSubview:self.estimateTime];
    
    // _____________________________________________________________________ Button Time Remain
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(20, 375, 60, 55)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Time Remain  [min]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 3;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonTimeRemain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];

    // _____________________________________________________________________ Label timeRemain
    self.timeRemain = [[UILabel alloc]initWithFrame:CGRectMake(90 , 375 , 210 , 55)];
    //[self.timeRemain setBackgroundColor: [UIColor yellowColor]];
    self.timeRemain.textColor = [UIColor blackColor];
    [self.timeRemain setShadowColor:[UIColor whiteColor]];
    [self.timeRemain setShadowOffset:CGSizeMake(3, 3) ];
    self.timeRemain.textAlignment = NSTextAlignmentRight;
    self.timeRemain.font = [UIFont fontWithName:@"Helvetica-Bold" size:70] ;
    //self.timeRemain.text = @"88:88";
    [self.view addSubview:self.timeRemain];
    
    // _____________________________________________________________________ Button Course
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(20, 443, 60, 50)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Course  [°]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonCourse:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label Course
    self.courseSailer = [[UILabel alloc] initWithFrame:CGRectMake(90 , 443 , 65 , 50)];
    //[self.courseSailer setBackgroundColor: [UIColor yellowColor]];
    self.courseSailer.textColor = [UIColor blackColor];
    [self.courseSailer setShadowColor:[UIColor whiteColor]];
    [self.courseSailer setShadowOffset:CGSizeMake(2, 2) ];
    self.courseSailer.textAlignment = NSTextAlignmentCenter;
    self.courseSailer.font = [UIFont fontWithName:@"Helvetica-Bold" size:30] ;
    self.courseSailer.text = @"888°";
    [self.view addSubview:self.courseSailer];
    
    // _____________________________________________________________________ Button Accuracy
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(20 ,503 ,60 ,45)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Accuracy [m]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonAccuracy:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];

    // _____________________________________________________________________ Label Accuracy
    self.horizonGenauigkeit = [[UILabel alloc] initWithFrame:CGRectMake(90, 503, 65, 45)]; /// (x, y, Breite, Höhe)
    //[self.horizonGenauigkeit setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setShadowOffset:CGSizeMake(2, 2) ];         // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setTextAlignment:NSTextAlignmentCenter];
    [self.horizonGenauigkeit setFont:[UIFont fontWithName:@"Helvetica-Bold" size:30]];
    [self.horizonGenauigkeit setText:@"888"];
    [self.view addSubview:self.horizonGenauigkeit];

    // _____________________________________________________________________ Button Speed to Target
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(165, 443, 55, 50)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Speed to Target [kn]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 3;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonSpeedToTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label speedToTarget
    self.speedToTarget = [[UILabel alloc]initWithFrame:CGRectMake(230, 443, 70, 50)];
    //[self.speedToTarget setBackgroundColor: [UIColor yellowColor]];
    self.speedToTarget.textColor = [UIColor blackColor];
    [self.speedToTarget setShadowColor:[UIColor whiteColor]];
    [self.speedToTarget setShadowOffset:CGSizeMake(2, 2) ];
    self.speedToTarget.textAlignment = NSTextAlignmentCenter;
    self.speedToTarget.font = [UIFont fontWithName:@"Helvetica-Bold" size:30] ;
    self.speedToTarget.text = @"88,8";
    [self.view addSubview:self.speedToTarget];
    
    // _____________________________________________________________________ Button Speed
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(165, 503, 55, 45)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Speed    [kn]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
// _____________________________________________________________________________ Label Speed
        self.speed = [[UILabel alloc]initWithFrame:CGRectMake(230, 503, 70, 45)];
       // [self.speed setBackgroundColor: [UIColor yellowColor]];
        self.speed.textColor = [UIColor blackColor];
        [self.speed setShadowColor:[UIColor whiteColor]];
        [self.speed setShadowOffset:CGSizeMake(2, 2) ];
        self.speed.textAlignment = NSTextAlignmentCenter;
        self.speed.font = [UIFont fontWithName:@"Helvetica-Bold" size:30] ;
        self.speed.text = @"88,8";
        [self.view addSubview:self.speed];
    
    }
/// ____________________________________________________________________________ set Button and Label      setButtonAndLabelForiPhone 6/6S
-(void)setButtonAndLabelForiPhone6
{
    
    NSLog(@"setze iPhone 6/6s");
    [self.view setBackgroundColor:[UIColor lightGrayColor]];  // Hintergrundfarbe des Views setzen
    
    //[self.view setBackgroundColor:[UIColor whiteColor]];  // Hintergrundfarbe des Views setzen
    
    //    // _____________________________________________________________________ Linie horizontal
    //
    //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(179, 64, 16, 602)]; /// (x, y, Breite, Höhe)
    //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.view addSubview:self.masterLatitudeLabel];
    //
    //    // _____________________________________________________________________ Linie vertikal
    //
    //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 325, 374, 20)]; /// (x, y, Breite, Höhe)
    //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.view addSubview:self.masterLatitudeLabel];
    //
    //    // _____________________________________________________________________ Linie vertikal
    //
    //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 374, 20)]; /// (x, y, Breite, Höhe)
    //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.view addSubview:self.masterLatitudeLabel];
    //
    //
    //    // _____________________________________________________________________ Linie vertikal
    //
    //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 475, 374, 20)]; /// (x, y, Breite, Höhe)
    //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.view addSubview:self.masterLatitudeLabel];
    //
    //
    //    // _____________________________________________________________________ Linie vertikal
    //
    //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 550, 374, 20)]; /// (x, y, Breite, Höhe)
    //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    //    [self.view addSubview:self.masterLatitudeLabel];
    //
    
    // _____________________________________________________________________ Label masterLatitudeLabel
    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 150, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLatitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLatitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [self.masterLatitudeLabel setText:@"188.8888888"];
    [self.view addSubview:self.masterLatitudeLabel];
    
    // _____________________________________________________________________ Label masterLongitudeLabel
    self.masterLongitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 75, 150, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLongitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLongitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [self.masterLongitudeLabel setText:@"188.8888888"];
    [self.view addSubview:self.masterLongitudeLabel];
    
    // _____________________________________________________________________ Label setShipMasterLabel
    self.setShipMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(164, 120, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setShipMasterLabel];
    
    // _____________________________________________________________________ Label setBuoyMasterLabe
    self.setBuoyMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 120, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setBuoyMasterLabel];
    
    // _____________________________________________________________________ Label setCountMasterLabel
    self.setCountMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(164, 184, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setCountMasterLabel];
    
    // _____________________________________________________________________ Label setStartMasterLabel
    self.setStartMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 184, 15, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setStartMasterLabel];
    
    // _____________________________________________________________________ Button Set Ship
    self.buttonSetShip = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetShip setFrame:CGRectMake(20.0, 111.0, 130.0, 48.0)];
    [self.buttonSetShip setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetShip.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetShip setTitle:@"Set Ship" forState:UIControlStateNormal];
    [self.buttonSetShip setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetShip.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetShip setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //self.buttonSetShip.tag = 1;
    [self.buttonSetShip addTarget:self action:@selector(buttonSetShipPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetShip];
    
    // _____________________________________________________________________ Button Set Buoy
    self.buttonSetBuoy = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetBuoy setFrame:CGRectMake(225, 111.0, 130.0, 48.0)];
    [self.buttonSetBuoy setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetBuoy.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetBuoy setTitle:@"Set Buoy" forState:UIControlStateNormal];
    [self.buttonSetBuoy setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetBuoy.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetBuoy setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //self.buttonSetBuoy.tag = 2;
    [self.buttonSetBuoy addTarget:self action:@selector(buttonSetBuoyPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetBuoy];
    
    // _____________________________________________________________________ Button StartCount
    self.buttonStartCount = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonStartCount setFrame:CGRectMake(20.0, 175.0, 130.0, 48.0)];
    [self.buttonStartCount setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonStartCount.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonStartCount setTitle:@"Set Count" forState:UIControlStateNormal];
    [self.buttonStartCount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonStartCount.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonStartCount setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonStartCount setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonStartCount setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //self.buttonStartCount.tag = 3;
    [self.buttonStartCount addTarget:self action:@selector(pressButtonStartCount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonStartCount];

    // _____________________________________________________________________ Button Set Speed
    self.buttonSpeedCalibration = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSpeedCalibration setFrame:CGRectMake(225.0, 175.0, 130.0, 48.0)];
    // [self.button setBackgroundColor: [UIColor yellowColor]];
    [self.buttonSpeedCalibration setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSpeedCalibration.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSpeedCalibration setTitle:@"Set Speed" forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSpeedCalibration.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSpeedCalibration setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.buttonSpeedCalibration addTarget:self action:@selector(pressButtonSpeedCalibration:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSpeedCalibration];
    
    // _____________________________________________________________________ Label Current Time
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 , 235 , 335 , 75)]; /// (x, y, Breite, Höhe)
    //[self.timeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
    //[self.timeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setShadowOffset:CGSizeMake(3, 3) ];         // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:75]];
    [self.timeLabel setText:@"88:88:88"];
    [self.view addSubview:self.timeLabel];
    
    // _____________________________________________________________________ Button Time Estimate
    self.buttonTimeEstimate = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonTimeEstimate setFrame:CGRectMake(25, 345, 70, 55)];
    //[self.buttonTimeEstimate setBackgroundColor: [UIColor yellowColor]];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonTimeEstimate setTitle:@"Time Estimate [min]" forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.buttonTimeEstimate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.buttonTimeEstimate.titleLabel.numberOfLines = 3;
    self.buttonTimeEstimate.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonTimeEstimate.tag = 5;
    [self.buttonTimeEstimate addTarget:self action:@selector(pressButtonTimeEstimate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonTimeEstimate];
    
    // _____________________________________________________________________ Label timeEstimate
    self.estimateTime = [[UILabel alloc]initWithFrame:CGRectMake(115 , 345 , 235 , 55)];
    //[self.estimateTime setBackgroundColor: [UIColor yellowColor]];
    self.estimateTime.textColor = [UIColor blackColor];
    [self.estimateTime setShadowColor:[UIColor whiteColor]];
    [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
    self.estimateTime.textAlignment = NSTextAlignmentRight;
    [self.estimateTime setShadowColor:[UIColor whiteColor]];
    [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
    self.estimateTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:70] ;
    self.estimateTime.text = @"88:88";
    self.estimateTime.tag = 8;
    [self.view addSubview:self.estimateTime];
    
    // _____________________________________________________________________ Button Time Remain
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(25, 420, 70, 55)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Time Remain  [min]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 3;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonTimeRemain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label timeRemain
    self.timeRemain = [[UILabel alloc]initWithFrame:CGRectMake(115 , 420 , 235 , 55)];
    //[self.timeRemain setBackgroundColor: [UIColor yellowColor]];
    self.timeRemain.textColor = [UIColor blackColor];
    [self.timeRemain setShadowColor:[UIColor whiteColor]];
    [self.timeRemain setShadowOffset:CGSizeMake(3, 3) ];
    self.timeRemain.textAlignment = NSTextAlignmentRight;
    self.timeRemain.font = [UIFont fontWithName:@"Helvetica-Bold" size:70] ;
    //self.timeRemain.text = @"88:88";
    [self.view addSubview:self.timeRemain];
    
    // _____________________________________________________________________ Button Course
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(25, 495, 60, 55)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Course  [°]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonCourse:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label Course
    self.courseSailer = [[UILabel alloc] initWithFrame:CGRectMake(90, 495, 90, 55)];
    //[self.courseSailer setBackgroundColor: [UIColor yellowColor]];
    self.courseSailer.textColor = [UIColor blackColor];
    [self.courseSailer setShadowColor:[UIColor whiteColor]];
    [self.courseSailer setShadowOffset:CGSizeMake(2, 2) ];
    self.courseSailer.textAlignment = NSTextAlignmentCenter;
    self.courseSailer.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
    self.courseSailer.text = @"888°";
    [self.view addSubview:self.courseSailer];
    
    // _____________________________________________________________________ Button Accuracy
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(25 ,570 ,60 ,55)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Accuracy [m]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonAccuracy:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label Accuracy
    self.horizonGenauigkeit = [[UILabel alloc] initWithFrame:CGRectMake(90, 570, 90, 55)]; /// (x, y, Breite, Höhe)
    //[self.horizonGenauigkeit setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setShadowOffset:CGSizeMake(2, 2) ];         // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setTextAlignment:NSTextAlignmentCenter];
    [self.horizonGenauigkeit setFont:[UIFont fontWithName:@"Helvetica-Bold" size:40]];
    [self.horizonGenauigkeit setText:@"888"];
    [self.view addSubview:self.horizonGenauigkeit];
    
    // _____________________________________________________________________ Button Speed to Target
    self.buttonSpeedtoTarget = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSpeedtoTarget setFrame:CGRectMake(185, 495, 55, 55)];
    //[self.buttonSpeedtoTarget setBackgroundColor: [UIColor yellowColor]];
    [self.buttonSpeedtoTarget setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonSpeedtoTarget setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonSpeedtoTarget.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSpeedtoTarget setTitle:@"Speed to Target [kn]" forState:UIControlStateNormal];
    self.buttonSpeedtoTarget.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.buttonSpeedtoTarget setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.buttonSpeedtoTarget.titleLabel.numberOfLines = 3;
    self.buttonSpeedtoTarget.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.buttonSpeedtoTarget setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonSpeedtoTarget setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.buttonSpeedtoTarget addTarget:self action:@selector(pressButtonSpeedToTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSpeedtoTarget];
    
    // _____________________________________________________________________ Label speedToTarget
    self.speedToTarget = [[UILabel alloc]initWithFrame:CGRectMake(245, 495, 110, 55)];
    //[self.speedToTarget setBackgroundColor: [UIColor yellowColor]];
    self.speedToTarget.textColor = [UIColor blackColor];
    [self.speedToTarget setShadowColor:[UIColor whiteColor]];
    [self.speedToTarget setShadowOffset:CGSizeMake(2, 2) ];
    self.speedToTarget.textAlignment = NSTextAlignmentCenter;
    self.speedToTarget.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
    self.speedToTarget.text = @"88,8";
    [self.view addSubview:self.speedToTarget];
    
    // _____________________________________________________________________ Button Speed
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(185, 570, 55, 55)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Speed    [kn]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________________ Label Speed
    self.speed = [[UILabel alloc]initWithFrame:CGRectMake(245, 570, 110, 55)];
    //[self.speed setBackgroundColor: [UIColor yellowColor]];
    self.speed.textColor = [UIColor blackColor];
    [self.speed setShadowColor:[UIColor whiteColor]];
    [self.speed setShadowOffset:CGSizeMake(2, 2) ];
    self.speed.textAlignment = NSTextAlignmentCenter;
    self.speed.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
    self.speed.text = @"88,8";
    [self.view addSubview:self.speed];
    
}
/// ____________________________________________________________________________ set Button and Label      setButtonAndLabelForiPhone 6Plus/6S Plus
-(void)setButtonAndLabelForiPhone6Plus
{
    //NSLog(@"setze iPhone 6/6s Plus");
    [self.view setBackgroundColor:[UIColor lightGrayColor]];  // Hintergrundfarbe des Views setzen
    
//        // _____________________________________________________________________ Linie vertikal
//    
//        self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(197, 64, 20, 672)]; /// (x, y, Breite, Höhe)
//        [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.view addSubview:self.masterLatitudeLabel];
//    
        // _____________________________________________________________________ Linie horizontal
//    
//        self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 385, 374, 20)]; /// (x, y, Breite, Höhe)
//        [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.view addSubview:self.masterLatitudeLabel];
//    
//        // _____________________________________________________________________ Linie horizontal
//    
//        self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 474, 374, 20)]; /// (x, y, Breite, Höhe)
//        [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.view addSubview:self.masterLatitudeLabel];
//    
//    
//        // _____________________________________________________________________ Linie horizontal
//    
//        self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 675, 374, 20)]; /// (x, y, Breite, Höhe)
//        [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.view addSubview:self.masterLatitudeLabel];
//    
//    
//        // _____________________________________________________________________ Linie horizontal
//    
//        self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 550, 374, 20)]; /// (x, y, Breite, Höhe)
//        [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
//        [self.view addSubview:self.masterLatitudeLabel];
//    
//    
    // _____________________________________________________________________ Label masterLatitudeLabel
    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 78, 177, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLatitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
    [self.masterLatitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLatitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [self.masterLatitudeLabel setText:@"188.8888888°"];
    [self.view addSubview:self.masterLatitudeLabel];
    
    // _____________________________________________________________________ Label masterLongitudeLabel
    self.masterLongitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 78, 177, 22)]; /// (x, y, Breite, Höhe)
    //[self.masterLongitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLongitudeLabel setzen
    [self.masterLongitudeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.masterLongitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [self.masterLongitudeLabel setText:@"188.8888888°"];
    [self.view addSubview:self.masterLongitudeLabel];
    
    // _____________________________________________________________________ Label setShipMasterLabel
    self.setShipMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(177, 135, 20, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setShipMasterLabel];
    
    // _____________________________________________________________________ Label setBuoyMasterLabel
    self.setBuoyMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 135, 20, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setBuoyMasterLabel];
    
    // _____________________________________________________________________ Label setCountMasterLabel
    self.setCountMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(177, 208, 20, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setCountMasterLabel];

    // _____________________________________________________________________ Label setStartMasterLabel
    self.setStartMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 208, 20, 31)]; /// (x, y, Breite, Höhe)
    [self.view addSubview:self.setStartMasterLabel];
    
    // _____________________________________________________________________ Button Set Ship
    self.buttonSetShip = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetShip setFrame:CGRectMake(20, 122, 137, 56)];
    [self.buttonSetShip setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetShip.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetShip setTitle:@"Set Ship" forState:UIControlStateNormal];
    [self.buttonSetShip setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetShip.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetShip setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetShip setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonSetShip.tag = 1;
    [self.buttonSetShip addTarget:self action:@selector(buttonSetShipPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetShip];
    
    // _____________________________________________________________________ Button Set Buoy
    self.buttonSetBuoy = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSetBuoy setFrame:CGRectMake(257, 122, 137, 56)];
    [self.buttonSetBuoy setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSetBuoy.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSetBuoy setTitle:@"Set Buoy" forState:UIControlStateNormal];
    [self.buttonSetBuoy setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSetBuoy.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSetBuoy setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSetBuoy setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonSetBuoy.tag = 2;
    [self.buttonSetBuoy addTarget:self action:@selector(buttonSetBuoyPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSetBuoy];
    
    // _____________________________________________________________________ Button StartCount
    self.buttonStartCount = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonStartCount setFrame:CGRectMake(20, 196, 137, 56)];
    [self.buttonStartCount setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonStartCount.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonStartCount setTitle:@"Set Count" forState:UIControlStateNormal];
    [self.buttonStartCount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonStartCount.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonStartCount setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonStartCount setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonStartCount setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonStartCount.tag = 3;
    [self.buttonStartCount addTarget:self action:@selector(pressButtonStartCount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonStartCount];
    
    // _____________________________________________________________________ Button Set Speed
    self.buttonSpeedCalibration = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSpeedCalibration setFrame:CGRectMake(257, 200, 137, 56)];
    // [self.button setBackgroundColor: [UIColor yellowColor]];
    [self.buttonSpeedCalibration setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    self.buttonSpeedCalibration.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonSpeedCalibration setTitle:@"Set Speed" forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.buttonSpeedCalibration.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.buttonSpeedCalibration setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSpeedCalibration setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.buttonSpeedCalibration addTarget:self action:@selector(pressButtonSpeedCalibration:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSpeedCalibration];
    
    // _____________________________________________________________________ Label Current Time
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 , 275 , 374 , 75)]; /// (x, y, Breite, Höhe)
    //[self.timeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setShadowOffset:CGSizeMake(3, 3) ];         // Hintergrundfarbe von timeLabel setzen
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:75]];
    [self.timeLabel setText:@"88:88:88"];
    [self.view addSubview:self.timeLabel];
    
    // _____________________________________________________________________ Button Time Estimate
    self.buttonTimeEstimate = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonTimeEstimate setFrame:CGRectMake(25, 387, 70, 66)];
    //[self.buttonTimeEstimate setBackgroundColor: [UIColor yellowColor]];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.buttonTimeEstimate setTitle:@"Time Estimate [min]" forState:UIControlStateNormal];
    self.buttonTimeEstimate.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.buttonTimeEstimate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.buttonTimeEstimate.titleLabel.numberOfLines = 3;
    self.buttonTimeEstimate.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15];
    [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonTimeEstimate setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.buttonTimeEstimate.tag = 5;
    [self.buttonTimeEstimate addTarget:self action:@selector(pressButtonTimeEstimate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonTimeEstimate];
    
    // _____________________________________________________________________ Label timeEstimate
    self.estimateTime = [[UILabel alloc]initWithFrame:CGRectMake(115 , 387 , 282 , 66)];
    //[self.estimateTime setBackgroundColor: [UIColor yellowColor]];
    self.estimateTime.textColor = [UIColor blackColor];
    [self.estimateTime setShadowColor:[UIColor whiteColor]];
    [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
    self.estimateTime.textAlignment = NSTextAlignmentRight;
    [self.estimateTime setShadowColor:[UIColor whiteColor]];
    [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
    self.estimateTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:70] ;
    self.estimateTime.text = @"88:88";
    self.estimateTime.tag = 8;
    [self.view addSubview:self.estimateTime];
    
    // _____________________________________________________________________ Button Time Remain
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(25, 473, 70, 66)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Time Remain  [min]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 3;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonTimeRemain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label timeRemain
    self.timeRemain = [[UILabel alloc]initWithFrame:CGRectMake(115 , 473 , 282 , 66)];
    //[self.timeRemain setBackgroundColor: [UIColor yellowColor]];
    self.timeRemain.textColor = [UIColor blackColor];
    [self.timeRemain setShadowColor:[UIColor whiteColor]];
    [self.timeRemain setShadowOffset:CGSizeMake(3, 3) ];
    self.timeRemain.textAlignment = NSTextAlignmentRight;
    self.timeRemain.font = [UIFont fontWithName:@"Helvetica-Bold" size:70] ;
    //self.timeRemain.text = @"88:88";
    [self.view addSubview:self.timeRemain];
    
    // _____________________________________________________________________ Button Course
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(25, 559, 60, 66)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Course  [°]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonCourse:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label Course
    self.courseSailer = [[UILabel alloc] initWithFrame:CGRectMake(90, 559, 90, 66)];
    //[self.courseSailer setBackgroundColor: [UIColor yellowColor]];
    self.courseSailer.textColor = [UIColor blackColor];
    [self.courseSailer setShadowColor:[UIColor whiteColor]];
    [self.courseSailer setShadowOffset:CGSizeMake(2, 2) ];
    self.courseSailer.textAlignment = NSTextAlignmentCenter;
    self.courseSailer.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
    self.courseSailer.text = @"888°";
    [self.view addSubview:self.courseSailer];
    
    // _____________________________________________________________________ Button Accuracy
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(25 ,645 ,60 ,66)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Accuracy [m]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonAccuracy:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // _____________________________________________________________________ Label Accuracy
    self.horizonGenauigkeit = [[UILabel alloc] initWithFrame:CGRectMake(90, 645, 90, 66)]; /// (x, y, Breite, Höhe)
    //[self.horizonGenauigkeit setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setShadowOffset:CGSizeMake(2, 2) ];         // Hintergrundfarbe von timeLabel setzen
    [self.horizonGenauigkeit setTextAlignment:NSTextAlignmentCenter];
    [self.horizonGenauigkeit setFont:[UIFont fontWithName:@"Helvetica-Bold" size:40]];
    [self.horizonGenauigkeit setText:@"888"];
    [self.view addSubview:self.horizonGenauigkeit];
    
    // _____________________________________________________________________ Button Speed to Target
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(195, 559, 60, 66)];
    ////[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Speed to Target [kn]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.button.titleLabel.numberOfLines = 3;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonSpeedToTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    
    // _____________________________________________________________________ Label speedToTarget
    self.speedToTarget = [[UILabel alloc]initWithFrame:CGRectMake(265, 559, 129, 66)];
    //[self.speedToTarget setBackgroundColor: [UIColor yellowColor]];
    self.speedToTarget.textColor = [UIColor blackColor];
    [self.speedToTarget setShadowColor:[UIColor whiteColor]];
    [self.speedToTarget setShadowOffset:CGSizeMake(2, 2) ];
    self.speedToTarget.textAlignment = NSTextAlignmentCenter;
    self.speedToTarget.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
    self.speedToTarget.text = @"88,8";
    [self.view addSubview:self.speedToTarget];
    
    // _____________________________________________________________________ Button Speed
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(195, 645, 60, 66)];
    //[self.button setBackgroundColor: [UIColor yellowColor]];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Speed    [kn]" forState:UIControlStateNormal];
    self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.button.titleLabel.numberOfLines = 2;
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
    [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(pressButtonSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    
    // _____________________________________________________________________________ Label Speed
    self.speed = [[UILabel alloc]initWithFrame:CGRectMake(265, 645, 129, 66)];
    //[self.speed setBackgroundColor: [UIColor yellowColor]];
    self.speed.textColor = [UIColor blackColor];
    [self.speed setShadowColor:[UIColor whiteColor]];
    [self.speed setShadowOffset:CGSizeMake(2, 2) ];
    self.speed.textAlignment = NSTextAlignmentCenter;
    self.speed.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
    self.speed.text = @"88,8";
    [self.view addSubview:self.speed];
}

/// ____________________________________________________________________________ set Button and Label      setButtonAndLabelForiPhone X

- (void) setButtonAndLabelForiPhoneX
{
    NSLog(@"setze iPhone X");

        [self.view setBackgroundColor:[UIColor lightGrayColor]];  // Hintergrundfarbe des Views setzen
        
        //[self.view setBackgroundColor:[UIColor whiteColor]];  // Hintergrundfarbe des Views setzen
        
        //    // _____________________________________________________________________ Linie horizontal
        //
        //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(179, 64, 16, 602)]; /// (x, y, Breite, Höhe)
        //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.view addSubview:self.masterLatitudeLabel];
        //
        //    // _____________________________________________________________________ Linie vertikal
        //
        //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 325, 374, 20)]; /// (x, y, Breite, Höhe)
        //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.view addSubview:self.masterLatitudeLabel];
        //
        //    // _____________________________________________________________________ Linie vertikal
        //
        //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 374, 20)]; /// (x, y, Breite, Höhe)
        //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.view addSubview:self.masterLatitudeLabel];
        //
        //
        //    // _____________________________________________________________________ Linie vertikal
        //
        //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 475, 374, 20)]; /// (x, y, Breite, Höhe)
        //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.view addSubview:self.masterLatitudeLabel];
        //
        //
        //    // _____________________________________________________________________ Linie vertikal
        //
        //    self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 550, 374, 20)]; /// (x, y, Breite, Höhe)
        //    [self.masterLatitudeLabel setBackgroundColor: [UIColor whiteColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
        //    [self.view addSubview:self.masterLatitudeLabel];
        //
        
        // _____________________________________________________________________ Label masterLatitudeLabel
        self.masterLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 150, 22)]; /// (x, y, Breite, Höhe)
        //[self.masterLatitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLatitudeLabel setzen
        [self.masterLatitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        [self.masterLatitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLatitudeLabel setzen
        [self.masterLatitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLatitudeLabel setzen
        [self.masterLatitudeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.masterLatitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [self.masterLatitudeLabel setText:@"188.8888888"];
        [self.view addSubview:self.masterLatitudeLabel];
        
        // _____________________________________________________________________ Label masterLongitudeLabel
        self.masterLongitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 90, 150, 22)]; /// (x, y, Breite, Höhe)
        //[self.masterLongitudeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von masterLongitudeLabel setzen
        [self.masterLongitudeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
        [self.masterLongitudeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von masterLongitudeLabel setzen
        [self.masterLongitudeLabel setShadowOffset:CGSizeMake(1, 1) ];         // Hintergrundfarbe von masterLongitudeLabel setzen
        [self.masterLongitudeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.masterLongitudeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [self.masterLongitudeLabel setText:@"188.8888888"];
        [self.view addSubview:self.masterLongitudeLabel];
        
        // _____________________________________________________________________ Label setShipMasterLabel
        self.setShipMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(164, 135, 15, 31)]; /// (x, y, Breite, Höhe)
        [self.view addSubview:self.setShipMasterLabel];
        
        // _____________________________________________________________________ Label setBuoyMasterLabe
        self.setBuoyMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 135, 15, 31)]; /// (x, y, Breite, Höhe)
        [self.view addSubview:self.setBuoyMasterLabel];
        
        // _____________________________________________________________________ Label setCountMasterLabel
        self.setCountMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(164, 199, 15, 31)]; /// (x, y, Breite, Höhe)
        [self.view addSubview:self.setCountMasterLabel];
        
        // _____________________________________________________________________ Label setStartMasterLabel
        self.setStartMasterLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 199, 15, 31)]; /// (x, y, Breite, Höhe)
        [self.view addSubview:self.setStartMasterLabel];
        
        // _____________________________________________________________________ Button Set Ship
        self.buttonSetShip = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonSetShip setFrame:CGRectMake(20.0, 126.0, 130.0, 48.0)];
        [self.buttonSetShip setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
        self.buttonSetShip.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonSetShip setTitle:@"Set Ship" forState:UIControlStateNormal];
        [self.buttonSetShip setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.buttonSetShip.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
        [self.buttonSetShip setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.buttonSetShip setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonSetShip setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        //self.buttonSetShip.tag = 1;
        [self.buttonSetShip addTarget:self action:@selector(buttonSetShipPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonSetShip];
        
        // _____________________________________________________________________ Button Set Buoy
        self.buttonSetBuoy = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonSetBuoy setFrame:CGRectMake(225, 126.0, 130.0, 48.0)];
        [self.buttonSetBuoy setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
        self.buttonSetBuoy.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonSetBuoy setTitle:@"Set Buoy" forState:UIControlStateNormal];
        [self.buttonSetBuoy setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.buttonSetBuoy.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
        [self.buttonSetBuoy setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.buttonSetBuoy setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonSetBuoy setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        //self.buttonSetBuoy.tag = 2;
        [self.buttonSetBuoy addTarget:self action:@selector(buttonSetBuoyPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonSetBuoy];
        
        // _____________________________________________________________________ Button StartCount
        self.buttonStartCount = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonStartCount setFrame:CGRectMake(20.0, 190.0, 130.0, 48.0)];
        [self.buttonStartCount setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
        self.buttonStartCount.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonStartCount setTitle:@"Set Count" forState:UIControlStateNormal];
        [self.buttonStartCount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.buttonStartCount.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
        [self.buttonStartCount setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.buttonStartCount setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonStartCount setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        //self.buttonStartCount.tag = 3;
        [self.buttonStartCount addTarget:self action:@selector(pressButtonStartCount:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonStartCount];
        
        // _____________________________________________________________________ Button Set Speed
        self.buttonSpeedCalibration = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonSpeedCalibration setFrame:CGRectMake(225.0, 190.0, 130.0, 48.0)];
        // [self.button setBackgroundColor: [UIColor yellowColor]];
        [self.buttonSpeedCalibration setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
        self.buttonSpeedCalibration.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonSpeedCalibration setTitle:@"Set Speed" forState:UIControlStateNormal];
        [self.buttonSpeedCalibration setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.buttonSpeedCalibration.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
        [self.buttonSpeedCalibration setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.buttonSpeedCalibration setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonSpeedCalibration setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.buttonSpeedCalibration addTarget:self action:@selector(pressButtonSpeedCalibration:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonSpeedCalibration];
        
        // _____________________________________________________________________ Label Current Time
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 , 250 , 335 , 75)]; /// (x, y, Breite, Höhe)
        //[self.timeLabel setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
        //[self.timeLabel setTextColor:[UIColor blackColor]];       // Hintergrundfarbe von timeLabel setzen
        [self.timeLabel setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
        [self.timeLabel setShadowOffset:CGSizeMake(3, 3) ];         // Hintergrundfarbe von timeLabel setzen
        [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:75]];
        [self.timeLabel setText:@"88:88:88"];
        [self.view addSubview:self.timeLabel];
        
        // _____________________________________________________________________ Button Time Estimate
        self.buttonTimeEstimate = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonTimeEstimate setFrame:CGRectMake(25, 360, 70, 55)];
        //[self.buttonTimeEstimate setBackgroundColor: [UIColor yellowColor]];
        [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonTimeEstimate setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buttonTimeEstimate.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonTimeEstimate setTitle:@"Time Estimate [min]" forState:UIControlStateNormal];
        self.buttonTimeEstimate.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.buttonTimeEstimate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.buttonTimeEstimate.titleLabel.numberOfLines = 3;
        self.buttonTimeEstimate.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15];
        [self.buttonTimeEstimate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonTimeEstimate setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.buttonTimeEstimate.tag = 5;
        [self.buttonTimeEstimate addTarget:self action:@selector(pressButtonTimeEstimate:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonTimeEstimate];
        
        // _____________________________________________________________________ Label timeEstimate
        self.estimateTime = [[UILabel alloc]initWithFrame:CGRectMake(115 , 360 , 235 , 55)];
        //[self.estimateTime setBackgroundColor: [UIColor yellowColor]];
        self.estimateTime.textColor = [UIColor blackColor];
        [self.estimateTime setShadowColor:[UIColor whiteColor]];
        [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
        self.estimateTime.textAlignment = NSTextAlignmentRight;
        [self.estimateTime setShadowColor:[UIColor whiteColor]];
        [self.estimateTime setShadowOffset:CGSizeMake(3, 3) ];
        self.estimateTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:70] ;
        self.estimateTime.text = @"88:88";
        self.estimateTime.tag = 8;
        [self.view addSubview:self.estimateTime];
        
        // _____________________________________________________________________ Button Time Remain
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setFrame:CGRectMake(25, 435, 70, 55)];
        //[self.button setBackgroundColor: [UIColor yellowColor]];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.button setTitle:@"Time Remain  [min]" forState:UIControlStateNormal];
        self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.button.titleLabel.numberOfLines = 3;
        self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.button addTarget:self action:@selector(pressButtonTimeRemain:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.button];
        
        // _____________________________________________________________________ Label timeRemain
        self.timeRemain = [[UILabel alloc]initWithFrame:CGRectMake(115 , 435 , 235 , 55)];
        //[self.timeRemain setBackgroundColor: [UIColor yellowColor]];
        self.timeRemain.textColor = [UIColor blackColor];
        [self.timeRemain setShadowColor:[UIColor whiteColor]];
        [self.timeRemain setShadowOffset:CGSizeMake(3, 3) ];
        self.timeRemain.textAlignment = NSTextAlignmentRight;
        self.timeRemain.font = [UIFont fontWithName:@"Helvetica-Bold" size:70] ;
        //self.timeRemain.text = @"88:88";
        [self.view addSubview:self.timeRemain];
        
        // _____________________________________________________________________ Button Course
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setFrame:CGRectMake(25, 510, 60, 55)];
        //[self.button setBackgroundColor: [UIColor yellowColor]];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.button setTitle:@"Course  [°]" forState:UIControlStateNormal];
        self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.button.titleLabel.numberOfLines = 2;
        self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.button addTarget:self action:@selector(pressButtonCourse:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.button];
        
        // _____________________________________________________________________ Label Course
        self.courseSailer = [[UILabel alloc] initWithFrame:CGRectMake(90, 510, 90, 55)];
        //[self.courseSailer setBackgroundColor: [UIColor yellowColor]];
        self.courseSailer.textColor = [UIColor blackColor];
        [self.courseSailer setShadowColor:[UIColor whiteColor]];
        [self.courseSailer setShadowOffset:CGSizeMake(2, 2) ];
        self.courseSailer.textAlignment = NSTextAlignmentCenter;
        self.courseSailer.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
        self.courseSailer.text = @"888°";
        [self.view addSubview:self.courseSailer];
        
        // _____________________________________________________________________ Button Accuracy
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setFrame:CGRectMake(25 ,595 ,60 ,55)];
        //[self.button setBackgroundColor: [UIColor yellowColor]];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.button setTitle:@"Accuracy [m]" forState:UIControlStateNormal];
        self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.button.titleLabel.numberOfLines = 2;
        self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.button addTarget:self action:@selector(pressButtonAccuracy:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.button];
        
        // _____________________________________________________________________ Label Accuracy
        self.horizonGenauigkeit = [[UILabel alloc] initWithFrame:CGRectMake(90, 595, 90, 55)]; /// (x, y, Breite, Höhe)
        //[self.horizonGenauigkeit setBackgroundColor: [UIColor yellowColor]];  // Hintergrundfarbe von timeLabel setzen
        [self.horizonGenauigkeit setShadowColor:[UIColor whiteColor]];       // Hintergrundfarbe von timeLabel setzen
        [self.horizonGenauigkeit setShadowOffset:CGSizeMake(2, 2) ];         // Hintergrundfarbe von timeLabel setzen
        [self.horizonGenauigkeit setTextAlignment:NSTextAlignmentCenter];
        [self.horizonGenauigkeit setFont:[UIFont fontWithName:@"Helvetica-Bold" size:40]];
        [self.horizonGenauigkeit setText:@"888"];
        [self.view addSubview:self.horizonGenauigkeit];
        
        // _____________________________________________________________________ Button Speed to Target
        self.buttonSpeedtoTarget = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonSpeedtoTarget setFrame:CGRectMake(185, 510, 55, 55)];
        //[self.buttonSpeedtoTarget setBackgroundColor: [UIColor yellowColor]];
        [self.buttonSpeedtoTarget setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonSpeedtoTarget setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buttonSpeedtoTarget.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonSpeedtoTarget setTitle:@"Speed to Target [kn]" forState:UIControlStateNormal];
        self.buttonSpeedtoTarget.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.buttonSpeedtoTarget setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.buttonSpeedtoTarget.titleLabel.numberOfLines = 3;
        self.buttonSpeedtoTarget.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
        [self.buttonSpeedtoTarget setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonSpeedtoTarget setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.buttonSpeedtoTarget addTarget:self action:@selector(pressButtonSpeedToTarget:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonSpeedtoTarget];
        
        // _____________________________________________________________________ Label speedToTarget
        self.speedToTarget = [[UILabel alloc]initWithFrame:CGRectMake(245, 510, 110, 55)];
        //[self.speedToTarget setBackgroundColor: [UIColor yellowColor]];
        self.speedToTarget.textColor = [UIColor blackColor];
        [self.speedToTarget setShadowColor:[UIColor whiteColor]];
        [self.speedToTarget setShadowOffset:CGSizeMake(2, 2) ];
        self.speedToTarget.textAlignment = NSTextAlignmentCenter;
        self.speedToTarget.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
        self.speedToTarget.text = @"88,8";
        [self.view addSubview:self.speedToTarget];
        
        // _____________________________________________________________________ Button Speed
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setFrame:CGRectMake(185, 595, 55, 55)];
        //[self.button setBackgroundColor: [UIColor yellowColor]];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.button setTitle:@"Speed    [kn]" forState:UIControlStateNormal];
        self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.button.titleLabel.numberOfLines = 2;
        self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:12];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.button addTarget:self action:@selector(pressButtonSpeed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.button];
        
        // _____________________________________________________________________________ Label Speed
        self.speed = [[UILabel alloc]initWithFrame:CGRectMake(245, 595, 110, 55)];
        //[self.speed setBackgroundColor: [UIColor yellowColor]];
        self.speed.textColor = [UIColor blackColor];
        [self.speed setShadowColor:[UIColor whiteColor]];
        [self.speed setShadowOffset:CGSizeMake(2, 2) ];
        self.speed.textAlignment = NSTextAlignmentCenter;
        self.speed.font = [UIFont fontWithName:@"Helvetica-Bold" size:40] ;
        self.speed.text = @"88,8";
        [self.view addSubview:self.speed];
        
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  SpeedCalibrationViewController.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 28.04.15.
//  Copyright (c) 2015 Günter Laudahn. All rights reserved.
//

#import "SpeedCalibrationViewController.h"

#define grad 0  // ________________________für die Spalten des PickerView


@interface SpeedCalibrationViewController () <UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate>

#pragma mark ___________________________________________________________________ Properties

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *startLocation;

- (IBAction)setWindDirectionPressed:(id)sender;
- (IBAction)setSpeedToShipPressed:(id)sender;
- (IBAction)setSpeedToBuoyPressed:(id)sender;
- (IBAction)setSpeedToCenterPressed:(id)sender;

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIProgressView *shipProgressView;
@property (strong, nonatomic) IBOutlet UIView *buoyProgressView;
@property (strong, nonatomic) IBOutlet UIView *centerProgressView;

@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *windDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *anzeigeSpeedShip;
@property (weak, nonatomic) IBOutlet UILabel *anzeigeSpeedBuoy;
@property (weak, nonatomic) IBOutlet UILabel *anzeigeSpeedCenter;

@property (strong, nonatomic) NSMutableArray *gradArray;                        // für Gradzahl
@property float selectedgrad;                                                   // für Grad
@property UIButton *button;

- (void)showHidePicker:(UIView *)pickerContainerView hide: (BOOL) hide;


@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation SpeedCalibrationViewController

NSTimer *countdownTimer;                                                        // Anlegen einer Instanz von Timer, um die countdownzeit anzuzeigen

NSInteger countNumber;                                                          // Integer für Timer
NSInteger selector;                                                             // Integer für Timer
double setSpeed = 0;
double sumSpeed = 0;


#pragma mark ___________________________________________________________________ viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.windDirectionLabel setText:self.contentWindDirection];
    [self.anzeigeSpeedShip setText:self.contentSpeedCalibrationSh];
    [self.anzeigeSpeedCenter setText:self.contentSpeedCalibrationCenter];
    [self.anzeigeSpeedBuoy setText:self.contentSpeedCalibrationB];
    [self prepareLocationManager];
    [self pickerInit];                                                          // Picker initialisieren
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    //self.progressView.center = self.view.center;

    self.selectedgrad = self.contentWindDirection.doubleValue;
    
    //NSLog(@"x %f y %f",_progressView.frame.size.height, _progressView.frame.size.width);
    //NSLog(@"x %f y %f",_progressView.frame.origin.x, _progressView.frame.origin.y);
    
    //CGRectMake(100, 3, 5, 6);
    self.progressView.frame = CGRectMake(20, 290, 285, 0);                    // x, y,
    self.progressView.tag = 10;
    
    [self.view addSubview:self.progressView];
    
}

- (void) viewDidLayoutSubviews
{
    self.pickerContainerView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self timerCountDownStop];                                                  //Timer abschalten beim Verlassen
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
{
    /// B1. die originalen GPS Signale Breite, Länge, Genauigkeit, Course und Speed werden ermittelt
    CLLocation *location = [locations lastObject];  ///location enthält alle Werte: location = <+37.33019345,-122.02598301> +/- 10.00m (speed 3.80 mps / course 85.48) @ 4/5/15, 8:33:58 AM

    //NSString *speed = [NSString stringWithFormat:@"%.1f", location.speed  * 1.9438444924574];
    
    setSpeed = location.speed * 1.9438444924574;
}


#pragma mark ___________________________________________________________________ Programmteil für die Zeitvorgabe

#pragma mark ___________________________________________________________________ Timer einrichten

#pragma mark ___________________________________________________________________ CountDownMethoden

-(void)timerCountDownMethode
{
    /// Hier ist die vom TimerCountDownStart ausgelöste Methode zum Anzeigen der Countdownzeit
    if (countNumber < 10)                                                       // CountnumberCd hat die in Picker eingestellte Zeit
    {
        
        sumSpeed = sumSpeed + setSpeed;
        //NSLog(@"setSpeed %f sumSpeed %f countNumber %ld ", setSpeed, sumSpeed, (long)countNumber);
        if (selector == 1)
        {
        self.anzeigeSpeedShip.text = [NSString stringWithFormat:@"%.1f", sumSpeed / countNumber]; // Anzeigen der Countdownzeit
        self.progressView.progress = ((float)countNumber +1)/10.0f;
        }
        if (selector == 2)
        {
        self.anzeigeSpeedBuoy.text = [NSString stringWithFormat:@"%.1f", sumSpeed / countNumber]; // Anzeigen der Countdownzeit
        self.progressView.progress = ((float)countNumber +1)/10.0f;
        }
        if (selector == 3)
        {
        self.anzeigeSpeedCenter.text = [NSString stringWithFormat:@"%.1f", sumSpeed / countNumber]; // Anzeigen der Countdownzeit
        self.progressView.progress = ((float)countNumber +1)/10.0f;
        }
        countNumber ++;
    }
    else
    {
        [self timerCountDownStop];                                              // wenn CountDownZeit zu ende, dann löschen des Timers
        [self removeButtonWait];                                                // Button Wait entfernen
        selector = 0;
        sumSpeed = 0;
        setSpeed = 0;
    }
}

-(void)timerCountDownStart
{

        countNumber = 0;
        countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCountDownMethode) userInfo:nil repeats:YES];
        [countdownTimer fire];
   
}

/// Hier wird der TimerCountDown gestoppt
-(void)timerCountDownStop
{
    [countdownTimer invalidate];
    countdownTimer = nil;
    [self stopLocationManager];
}

#pragma mark Buttons

- (IBAction)setSpeedToShipPressed:(id)sender
{
    if (selector == 0)
    {
    [self setButtonShWait];                                                     // Button WaitSh setzen
    NSLog(@"Hier ist SetSpeedToShipPressed ");
    selector =1;
    [self startLocationManager];
    [self timerCountDownStart];
    }
}

- (IBAction)setSpeedToBuoyPressed:(id)sender
{
    if (selector == 0)
    {
        [self setButtonCenterWait];                                             // Button WaitSh setzen
        NSLog(@"Hier ist SetSpeedToBuoyPressed ");
        selector = 2;
        [self startLocationManager];
        [self timerCountDownStart];
    }

}

- (IBAction)setSpeedToCenterPressed:(id)sender
{
    if (selector == 0)
    {
        [self setButtonBWait];                                                 // Button WaitB setzen
        NSLog(@"Hier ist SetSpeedToCenterPressed ");
        selector = 3;
        [self startLocationManager];
        [self timerCountDownStart];
    }

}

- (IBAction)setWindDirectionPressed:(id)sender
{
    [self showHidePicker:self.pickerContainerView hide:NO];
}

- (IBAction)doneButtonPressed:(id)sender                                        // done Button vom Controller
{
    
    NSLog(@"done self.selectedgrad %f", self.selectedgrad);
    [self timerCountDownStop];
    self.windDirectionLabel.text = [NSString stringWithFormat:@"%.0f°", self.selectedgrad];
    [self showHidePicker:self.pickerContainerView hide:YES];
    [self removeButtonWait];                                                    // Button Wait entfernen
    NSString *newSpeedCalSh = self.anzeigeSpeedShip.text;
    NSString *newSpeedCalCenter = self.anzeigeSpeedCenter.text;
    NSString *newSpeedCalB = self.anzeigeSpeedBuoy.text;
    NSString *newWindDirection = self.windDirectionLabel.text;
    [self.parentVC wertSpeedCalShDidChange:newSpeedCalSh wertSpeedCalCenterDidChange:newSpeedCalCenter wertSpeedCalBDidChange:newSpeedCalB wertWindDirectionDidChange:newWindDirection];
}

- (IBAction)okButtonPressed:(id)sender                                          // ok Button vom Picker
{
    self.windDirectionLabel.text = [NSString stringWithFormat:@"%.0f°", self.selectedgrad];
    [self showHidePicker:self.pickerContainerView hide:YES];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self showHidePicker:self.pickerContainerView hide:YES];                    // cancel Button vom Picker
}

// _____________________________________________________________________________ Button Wait

-(void)setButtonShWait                                                            // Button WaitSh setzen
{
self.button = [UIButton buttonWithType:UIButtonTypeCustom];
[self.button setFrame:CGRectMake(20.0, 81.0, 200.0, 44.0)];
[self.button setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
//self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
[self.button setTitle:@"Wait " forState:UIControlStateNormal];
[self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
[self.button setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
//[self.button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
//[self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
self.button.tag = 4;
//[self.button addTarget:self action:@selector(pressButtonWait:) forControlEvents:UIControlEventTouchUpInside];
[self.view addSubview:self.button];
}

-(void)setButtonCenterWait                                                            // Button WaitCenter setzen
{
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(20.0, 133.0, 200.0, 44.0)];
    [self.button setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    //self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Wait " forState:UIControlStateNormal];
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.button setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    //[self.button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    //[self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.button.tag = 4;
    //[self.button addTarget:self action:@selector(pressButtonWait:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

-(void)setButtonBWait                                                            // Button WaitB setzen
{
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(20.0, 185.0, 200.0, 44.0)];
    [self.button setBackgroundImage:[UIImage imageNamed:@"Button Xcode.png"] forState:UIControlStateNormal];
    //self.button.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.button setTitle:@"Wait " forState:UIControlStateNormal];
    [self.button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.button.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    [self.button setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    //[self.button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    //[self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.button.tag = 4;
    //[self.button addTarget:self action:@selector(pressButtonWait:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}


-(void)removeButtonWait                                                         // Button Wait entfernen
// vorhandene Anzeigeelemente löschen
{
    for (UIView *subview in [self.view subviews])
    {
        if (subview.tag == 4)
        {
            [subview removeFromSuperview];
        }
    }
}


#pragma mark Picker Einstellung

-(void)pickerInit{
    
    self.gradArray = [[NSMutableArray alloc] init];
    for (float h = 0; h < 360; h += 5)
    {
        [self.gradArray addObject:[NSNumber numberWithFloat:h]];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)showHidePicker:(UIView *)pickerContainerView hide: (BOOL) hide
{
    CGRect containerEndFrame = pickerContainerView.frame;
    if (hide) {
        containerEndFrame.origin.y = containerEndFrame.origin.y + containerEndFrame.size.height;
    }else{
        containerEndFrame.origin.y = containerEndFrame.origin.y - containerEndFrame.size.height;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    pickerContainerView.frame = containerEndFrame;
    [UIView commitAnimations];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case grad:
            return [self.gradArray count];
            break;
        default:
            return 0;
            break;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case grad:
            return [NSString stringWithFormat:@"%@°", [self.gradArray objectAtIndex:row]];
            break;
        default:
            return nil;
            break;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedgrad = [[self.gradArray objectAtIndex:[self.pickerView selectedRowInComponent:grad]] floatValue];
}

@end

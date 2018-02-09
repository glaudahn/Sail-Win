//
//  SetCountdownViewController.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 30.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import "SetCountdownViewController.h"

#define secLabel 0  // ________________________für die Spalten des PickerView
#define min 1  // _____________________________für die Spalten des PickerView
#define sec 2 // ______________________________für die Spalten des PickerView
#define minLabel 3  // ________________________für die Spalten des PickerView


@interface SetCountdownViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *timeCountDownLabel; //______________ Property Label zur Anzeige der Clock
@property (strong, nonatomic) IBOutlet UILabel *remainTimeLabel;  //______________ Property Label zur Anzeige der RemainTime
@property (weak, nonatomic) IBOutlet UITextField *setCountDownLabel;//______________ Property Label zur Anzeige des Status
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@property (strong, nonatomic) NSMutableArray *minArray; // ____________________________________für PickerView
@property (strong, nonatomic) NSMutableArray *secArray; // __________________________________für PickerView
@property (strong, nonatomic) NSMutableArray *minLabelArray; // _____________________________für PickerView
@property (strong, nonatomic) NSMutableArray *secLabelArray; // _____________________________für PickerView

@property float selectedmin; // _____________________________________________________________für PickerView
@property float selectedsec; // _____________________________________________________________für PickerView
@property float selectedminLabel; // _____________________________________________________________für PickerView
@property float selectedsecLabel; // _____________________________________________________________für PickerView


@end

@implementation SetCountdownViewController

NSInteger countNumberRemain;  // __________________________Integer für den CountDownZähler
NSInteger secondsRemain;      // __________________________Integer für den CountDownZähler
NSInteger minutesRemain;      // __________________________Integer für den CountDownZähler
NSInteger hoursRemain;        // __________________________Integer für den CountDownZähler;
NSTimer *countdownTimer;    //___________________________ Anlegen einer Instanz von Timer, um die Uhrzeit anzuzeigen


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self pickerInit];                    //______________________________________Picker initialisieren
    [self startTimerCountdown];                   //______________________________________ Clock starten
}

#pragma mark Picker Einstellung

-(void)pickerInit{

    self.minArray = [[NSMutableArray alloc] init];
    for (float h = 0; h < 60; h++)
    {
        [self.minArray addObject:[NSNumber numberWithFloat:h]];
    }
    self.secArray = [[NSMutableArray alloc] init];
    for (float w = 0; w < 60; w++)
    {
        [self.secArray addObject:[NSNumber numberWithFloat:w]];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case sec:
            return [self.secArray count];
            break;
        case min:
            return [self.minArray count];
            break;
        case secLabel:
            return 1;
            break;
        case minLabel:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case sec:
            //return [NSString stringWithFormat:@"%@d", [self.secArray objectAtIndex:row]];
            return [NSString stringWithFormat:@"%02ld", (long)row];
            break;
        case min:
            return [NSString stringWithFormat:@"%02ld", (long)row];
            break;
        case secLabel:
            return [NSString stringWithFormat:@"%@", @"min"];
            //return [NSString stringWithFormat:@"%@", [self.secLabelArray objectAtIndex:row]];
            break;
        case minLabel:
            //return [NSString stringWithFormat:@"%@", [self.minLabelArray objectAtIndex:row]];
            return [NSString stringWithFormat:@"%@", @"sec"];
            break;
        default:
            return nil;
            break;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedmin = [[self.minArray objectAtIndex:[self.pickerView selectedRowInComponent:min]] floatValue];
    self.selectedsec = [[self.secArray objectAtIndex:[self.pickerView selectedRowInComponent:sec]] floatValue];
    countNumberRemain = (self.selectedmin * 60) + self.selectedsec;
    hoursRemain = (countNumberRemain /3600);
    minutesRemain = (countNumberRemain % 3600) / 60;
    secondsRemain = (countNumberRemain % 3600) % 60;
    
    self.remainTimeLabel.text = [NSString stringWithFormat:@"%.2li:%.2li", (long)minutesRemain, (long)secondsRemain];
    int wert = [self.remainTimeLabel.text intValue];       //____________________ wenn 0 dann rot
    if (wert == 0)
    {
        self.setCountDownLabel.backgroundColor = [UIColor redColor];
    }
    else
        (self.setCountDownLabel.backgroundColor = [UIColor greenColor]);
}

#pragma mark ___________________________________________________________________ Timer einrichten

-(void) startTimerCountdown
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDownTick:)userInfo:nil repeats:YES];//_________________________________ Uhr starten
    [countdownTimer fire];    // Den Timer sofort auslösen.
}

- (void)stopTimerCountdown
{
    // Der View-Controller wird aus dem Speicher entfernt.
    // Den Timer anhalten.
    [countdownTimer invalidate];
    countdownTimer = nil;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)countDownTick:(NSTimer*)timer
{

    NSDate *today = [NSDate date];// Das aktuelle Datum und die aktuelle Uhrzeit holen.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// Einen NSDateFormatter konfigurieren.
    //NSLocale *german = [[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"];
    //[dateFormatter setLocale:german];
    //[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"GMT+1"]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];// Das NSDate-Objekt in einen NSString konvertieren.
    [self.timeCountDownLabel setText:currentTime];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.remainTimeLabel.text = self.contentRemainTimeHours;
    int wert = [self.remainTimeLabel.text intValue];
    
    if (wert == 0)
    {
        self.setCountDownLabel.backgroundColor = [UIColor redColor];
    } else
        (self.setCountDownLabel.backgroundColor = [UIColor greenColor]);
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self stopTimerCountdown]; //Uhr abschalten beim Verlassen
}


- (IBAction)doneButtonPressed:(id)sender
{
    NSString *newRemain = [NSString stringWithFormat:@"%.0ld", (long)countNumberRemain];// Den aktuellen Werte aus dem Textfeld holen.
    [self.parentVC werteCountDownDidChange:newRemain];// Die RemainTime über eine Methode an den Eltern-View-Controlller, übergeben.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

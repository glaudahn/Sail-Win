//
//  SetBuoyPositionViewController.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 30.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import "SetBuoyPositionViewController.h"

@interface SetBuoyPositionViewController ()

@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;                 // Property Label zur Anzeige der Longitude
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;                  // Property Label zur Anzeige der Latitude
@property (strong, nonatomic) IBOutlet UITextField *longitudeText;              // Property Text zur Anzeige der Longitude
@property (strong, nonatomic) IBOutlet UITextField *latitudeText;               // Property Text zur Anzeige der Latitude
@property (strong, nonatomic) IBOutlet UITextField *preferredSideText;          // Property Text zur Anzeige der preferredSide
@property (weak, nonatomic) IBOutlet UITextField *setBuoyPositionLabel;         // Property Text zur Anzeige des Labels
@property (weak, nonatomic) IBOutlet UISwitch *buoyStartlinePositionSwitch;     // Property Switch zum Umschalten Kurs auf Startschiff oder Mitte
- (IBAction)setBuoyPositionPressed:(id)sender;                                  // Button SetBuoyPosition
@property (weak, nonatomic) IBOutlet UILabel *la;


@end

@implementation SetBuoyPositionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.longitudeLabel.text = self.contentLongitude;  //_______________________ GPS Label werden aus PosItems gesetzt
    self.latitudeLabel.text = self.contentLatitude;
    self.longitudeText.text = self.contentLongitudeBuoy;   //___________________ GPS Texte werden aus PosItems gesetzt
    self.latitudeText.text = self.contentLatitudeBuoy;
    self.preferredSideText.text = self.contentprefferedSide;                    // die bevorzugte Seite in die Anzeige schreiben
    int wert = [self.longitudeText.text intValue];       //____________________ wenn GPS Text nicht 0, grün, sonst rot
    if (wert == 0)
    {
        self.setBuoyPositionLabel.backgroundColor = [UIColor redColor];
    } else
        (self.setBuoyPositionLabel.backgroundColor = [UIColor greenColor]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.buoyStartlinePositionSwitch addTarget:self action:@selector(switchToShip:)
                               forControlEvents:UIControlEventValueChanged];    // Switch mit dem View verbinden
    if ([self.contentprefferedSide  isEqual:@"StartBuoy"])                         // wenn Startschiff die bevorzugte Seite ist dann Switch on, sonst off
    {
        [self.buoyStartlinePositionSwitch setOn:YES animated:YES];               // Switch auf aus stellen zur Anzeige
    } else {
        [self.buoyStartlinePositionSwitch setOn:NO animated:YES];               // Switch auf ein stellen zur Anzeige
    }
}


- (IBAction)setBuoyPositionPressed:(id)sender
{
    self.longitudeText.text = self.contentLongitude;        //__________________ GPS Texte werden aus GPS Label gesetzt
    self.latitudeText.text = self.contentLatitude;
    int wert = [self.longitudeText.text intValue];          //__________________ wenn GPS Text nicht 0, grün, sonst rot
     if (wert == 0)
    {
        self.setBuoyPositionLabel.backgroundColor = [UIColor redColor];
    } else
        (self.setBuoyPositionLabel.backgroundColor = [UIColor greenColor]);
}

- (IBAction)doneButtonPressed:(id)sender
{
    // Die aktuellen Werte aus dem Textfeldern holen.
    NSString *newText1 = self.longitudeText.text;
    NSString *newText2 = self.latitudeText.text;
    NSString *newText3 = self.preferredSideText.text;

    // Die Werte über eine Methode an den Eltern-View-Controller übergeben.
    [self.parentVC longBuoyDidChange:newText1 latiBuoyDidChange:newText2 prefSideDidChange:newText3];
}

// Switch
- (void)switchToShip:(UISwitch *)switchStatus
{
    if ([switchStatus isOn]) {
        self.preferredSideText.text = @"StartBuoy";
    } else {
        self.preferredSideText.text = @"Center";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

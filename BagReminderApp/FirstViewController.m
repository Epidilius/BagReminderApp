//
//  FirstViewController.m
//  BagReminderApp
//
//  Created by Joel Cright on 2015-11-04.
//  Copyright (c) 2015 Joel Cright. All rights reserved.
//

#import "FirstViewController.h"

//TODO: Swipe to delete
//TODO: Vars
//File location
//Some file name constants
//Array for locations
//Array for toggles
    ///Maybe have a pair list, with the location as a string (eg "-70,45") and the toggle as a bool

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //TODO: Get file lcoation, save to member
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)SetHomeButton:(id)sender {
    //TODO: Set location as home
}

-(void)SaveLocation:(NSString*)aTextToSave:(NSString*)aFileToSaveTo {
    //TODO
}

-(bool)CheckIfFileExists:(NSString*)aDir {
    if ([[NSFileManager defaultManager] fileExistsAtPath:aDir])
    {
        return true;
    }
    else
    {
        return false;
    }
}

-(bool)SaveFile:(NSData*)aFileData:(NSString*)aDir {
   return [[NSFileManager defaultManager] createFileAtPath:aDir
                                                  contents:aFileData
                                                attributes:nil];
}

-(void)LoadFile:(NSString*)aDir {
    if ([[NSFileManager defaultManager] fileExistsAtPath:aDir])
    {
        //File exists
        NSData *file = [[NSData alloc] initWithContentsOfFile:aDir];
        if (file)
        {
            //TODO: Set up the arrays and text in the container
            //Parse and loop through it here
        }
    }
    else
    {
        NSLog(@"File does not exist");
    }
}

-(void)AddLocationToContainer {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show View" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [_view addSubview:button];
}

//Done on startup
//TODO: Call this is Load
-(void)CreateDirectory:(NSString*)aDir {
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:aDir])	//Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:aDir
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
}

@end

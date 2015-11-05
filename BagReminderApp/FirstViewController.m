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
    //Make a struct for the locations. Have lat, lng, id, toggle, etc. Make array of these

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self addButtonsToScrollView];
    
    //CGFloat width = [UIScreen mainScreen].bounds.size.width;
    //self.UIScrollMainPage.contentSize = CGSizeMake(self.UIScrollMainPage.frame.size.width/2,
    //                                               self.UIScrollMainPage.contentSize.height);
    
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
    //TODO: Add to the struct and the array of those structs
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Flip"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(flipView:)];
    self.navigationItem.rightBarButtonItem = flipButton;
}

- (void)addButtonsToScrollView
{
    NSInteger buttonCount = 15;
    
    CGRect buttonFrame = CGRectMake(5.0f, 5.0f, 10.0f, 40.0f);
    
    for (int index = 1; index <buttonCount; index++) {
        buttonFrame.origin.x = self.UIScrollMainPage.frame.size.width-20;
        
        UISwitch *toggle = [[UISwitch alloc] init];
        [toggle setFrame:buttonFrame];
        [toggle setTag:index+1];
        
        buttonFrame.origin.y += buttonFrame.size.height+5.0f;
        
        [self.UIScrollMainPage addSubview:toggle];
    }
    
    CGSize contentSize = self.UIScrollMainPage.frame.size;
    contentSize.height = buttonFrame.origin.y;
    [self.UIScrollMainPage setContentSize:contentSize];
    
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

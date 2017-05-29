//
//  ResultsScreenViewController.m - The results screen shown after a game is completed.
//  COMP_4768_Project
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import "ResultsScreenViewController.h"
#import "ViewController.h"

@interface ResultsScreenViewController ()

@end

@implementation ResultsScreenViewController

// Synthesize variables
@synthesize pointsTotalLabel;
@synthesize totalPoints;
@synthesize nextRoundButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // If both users guess right they get a bonus mark.
    if (totalPoints == 2) {
        totalPoints = 3;
    }
    
    // Disable the next round button, a feature we couldn't get finished.
    [nextRoundButton setEnabled:NO];
    nextRoundButton.hidden = YES;
    
    // Set the point label the game's points.
    pointsTotalLabel.text = [NSString stringWithFormat:@"%d", totalPoints];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Method called when the main menu button is pressed.
 */
- (IBAction)mainMenuButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"goToMainMenu" sender:self];
}

# pragma mark - Segue Methods

/**
 * This method handles passing data between view controllers.
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToMainMenu"]) {
        ViewController *mainVC = segue.destinationViewController;
        [mainVC.backgroundMusicPlayer stop]; // Stop background music on main page.
    }
}

@end

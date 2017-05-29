//
//  ResultsScreenViewController.h - The results screen shown after a game is completed.
//  COMP_4768_Project
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MultipeerConnectivity;

@interface ResultsScreenViewController : UIViewController

# pragma mark - Outlet Variables.

@property (weak, nonatomic) IBOutlet UILabel *pointsTotalLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextRoundButton;


# pragma mark - Button Methods

- (IBAction)mainMenuButtonPressed:(UIButton *)sender;

// The point total to print on the screen.
@property int totalPoints;

# pragma mark - Multipeer Variables

// MultipeerConnectivity advertisor is used to start the connection.
@property (nonatomic, strong) MCAdvertiserAssistant *rAdvertisor;

// MultipeerConnectivity session initializes the sending and receiving process.
@property (nonatomic, strong) MCSession *rSession;

// The user's peer ID.
@property (nonatomic, strong) MCPeerID *resultsPeerID;

@end

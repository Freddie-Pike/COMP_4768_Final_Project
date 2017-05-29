//
//  ViewController.m - The main viewcontroller in the project that is the main menu of the program.
//  COMP_4768_Project
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondScreen.h"

@import MultipeerConnectivity;
@import AVFoundation;

@interface ViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate>

# pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *connectionLabel; // Updates when player connects
@property (weak, nonatomic) IBOutlet UIButton *playButton; // Used to enable/disable play button when player connects.

# pragma mark - Button Methods

- (IBAction)connectButtonPressed:(UIButton *)sender; // Will be used to connected to other players.
- (IBAction)playButtonPressed:(UIButton *)sender; // Used to play a game with another player
- (IBAction)disconnectButtonPressed:(id)sender; // Used to disconnect from a game.

# pragma mark - Audio Player Variables.

@property AVAudioPlayer* backgroundMusicPlayer;

# pragma mark - Multipeer Variables

// MultipeerConnectivity advertisor is used to start the connection.
@property (nonatomic, strong) MCAdvertiserAssistant *advertisor;

// MultipeerConnectivity session initializes the sending and receiving process.
@property (nonatomic, strong) MCSession *session;

@property (nonatomic, strong) MCPeerID *myPeerID;

# pragma mark - Functionality variables.

@property NSMutableArray *connected_list; // A list of all connected users.
@property int myPeerIndex; // Variable that determines the user's index in the connected user list.

// Word Bank Variables
@property NSArray* wordBankList;
@property NSArray* gameWordList;
@property NSArray* wbAnimals;
@property NSArray* wbTransport;
@property NSArray* wbWeather;
@property NSArray* wbEmotions;
@property NSArray* wbFood;
@property NSArray* wbSuperheroes;
@property NSArray* wbVideoGames;
@property NSArray* wbLogos;

// Variable that contains the list of random indices for the word bank.
@property NSMutableArray* randomIndexList;

@end

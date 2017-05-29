//
//  PracticeAreaViewController.h
//  COMP_4768_Project
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MultipeerConnectivity;
@import AVFoundation;

@interface PracticeAreaViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate>

# pragma mark - outlets

// Button variables.
@property (weak, nonatomic) IBOutlet UIButton *clearImage;
@property (weak, nonatomic) IBOutlet UIButton *submitImage;

// Colour variables.
@property (weak, nonatomic) IBOutlet UIButton *blackSelected;
@property (weak, nonatomic) IBOutlet UIButton *redSelected;
@property (weak, nonatomic) IBOutlet UIButton *blueSelected;
@property (weak, nonatomic) IBOutlet UIButton *greenSelected;
@property (weak, nonatomic) IBOutlet UIButton *eraserSelected;

// Word Bank Buttons
@property (weak, nonatomic) IBOutlet UIButton *wordBankButton1;
@property (weak, nonatomic) IBOutlet UIButton *wordBankButton2;
@property (weak, nonatomic) IBOutlet UIButton *wordBankButton3;
@property (weak, nonatomic) IBOutlet UIButton *wordBankButton4;
@property (weak, nonatomic) IBOutlet UIButton *wordBankButton5;

// The space where the user draws.
@property (weak, nonatomic) IBOutlet UIImageView *drawSpace;

#pragma mark - Multipeer Variables

// MultipeerConnectivity advertisor is used to start the connection.
@property (nonatomic, strong) MCAdvertiserAssistant *drawingAdvertisor;

// MultipeerConnectivity session initializes the sending and receiving process.
@property (nonatomic, strong) MCSession *drawingSession;
@property (nonatomic, strong) MCPeerID *pPeerID;
@property NSMutableArray *connected_list;

# pragma mark - Audio Player Variables.

@property AVAudioPlayer* backgroundMusicPlayer; // The background music of the application.
@property AVAudioPlayer* drawingSoundsMusicPlayer; // The sound that is made when the user draws.
@property AVAudioPlayer* resetSoundMusicPlayer; // The sound that is made when the reset button is pressed.

# pragma mark - Game Variables.

// Variable that determines the user's index in the connected user list.
@property int myPeerIndex;

// Round value that determines when to update the game state.
@property int roundCounter;

// Variable that counts the number of points each player has received.
@property int points;
@property NSString* chosenWord;
@property NSString* pictureGuess;
@property NSString* pictureAnswer;
@property NSString* secondPlayerGuess;

// A random list of indexes.
@property NSMutableArray* randomIndexList;

# pragma mark - Button Methods

- (IBAction)connectButtonPressed:(UIButton *)sender;
- (IBAction)submitButtonPressed:(UIButton *)sender;

// Word Bank Methods
- (IBAction)wordBankButtonPressed:(UIButton *)sender;

# pragma mark - Drawing related Variables.

// Color variables
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;

// Check if the mouse was moved.
@property BOOL wasMouseMoved;
@property CGPoint pointLastTouched; // Grabs the point last touched by the user

@end

//
//  SecondScreen.h - The drawing area in which the two players will play.
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MultipeerConnectivity;
@import AVFoundation;

@interface SecondScreen : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate> 

# pragma mark - Outlets

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

// Timer label where the time will be updated to.
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

#pragma mark - Multipeer Variables

// MultipeerConnectivity advertisor is used to start the connection.
@property (nonatomic, strong) MCAdvertiserAssistant *drawingAdvertisor;

// MultipeerConnectivity session initializes the sending and receiving process.
@property (nonatomic, strong) MCSession *drawingSession;

// The current user's Peer ID.
@property (nonatomic, strong) MCPeerID *drawingPeerID;

// The list of all connected users in the session.
@property NSMutableArray *connected_list;

# pragma mark - Audio Player Variables.

@property AVAudioPlayer* drawingSoundsMusicPlayer; // The sound that is made when the user draws.
@property AVAudioPlayer* resetSoundMusicPlayer; // The sound that is made when the reset button is pressed.

# pragma mark - Game Variables.

// Variable that determines the user's index in the connected user list.
@property int myPeerIndex;

// Round value that determines when to update the game state.
@property int roundCounter;

// Variable that counts the number of points each player has received.
@property int points;

// The image that is sent to the other player.
@property UIImage *imageToSend;

// Variables that are associated with choosing the correct word.
@property NSString* chosenWord;
@property NSString* pictureGuess;
@property NSString* pictureAnswer;
@property NSString* secondPlayerGuess;

// Segue Variables
@property (nonatomic, strong) NSString *testString;

# pragma mark - Button Methods

- (IBAction)submitButtonPressed:(UIButton *)sender;
- (IBAction)wordBankButtonPressed:(UIButton *)sender;

# pragma mark - Drawing related Variables.

// Color variables
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;

// Check if the mouse was moved.
@property BOOL wasMouseMoved;
@property CGPoint pointLastTouched; // Grabs the point last touched by the user

# pragma mark - Game variables.

// Variable that contains the list of random indices for the word bank.
@property NSMutableArray* wordBankIndicesList;

// WordList of the game
@property NSArray* gameWordList;

// Timer related variables.
@property float timer;
@property float timerDuration;
@property float timerDecrementAmount;


@end

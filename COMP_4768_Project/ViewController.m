//
//  ViewController.m - The main viewcontroller in the project that is the main menu of the program.
//  COMP_4768_Project
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import "ViewController.h"
#import "SecondScreen.h"
#import "PracticeAreaViewController.h"

NSString *const SERVICETYPE = @"project"; // The service type for this app
Boolean isConnected; // Used to update the connection label.
int numberOfButtons = 5; // Number of wordbank buttons that'll be on the next screen.

@interface ViewController ()
@end

@implementation ViewController

// Synthesize Variables
// Interface Outlets
@synthesize playButton;
@synthesize connectionLabel;
// Variables used to create games
@synthesize myPeerIndex;
@synthesize connected_list;
// Mulitpeer
@synthesize advertisor;
@synthesize myPeerID;
// Syntheize wordbank variables
@synthesize wordBankList;
@synthesize gameWordList;
@synthesize randomIndexList;
@synthesize wbAnimals;
@synthesize wbTransport;
@synthesize wbWeather;
@synthesize wbEmotions;
@synthesize wbFood;
@synthesize wbSuperheroes;
@synthesize wbVideoGames;
@synthesize wbLogos;
// Background Music Player
@synthesize backgroundMusicPlayer;


- (void)viewDidLoad {
    // Set the background to a gradiant background.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    [playButton setEnabled:NO]; // Disable the play button until a player is connected.
    
    // Multipeer Setup
    // First, prepare the session.
    myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:myPeerID];
    self.session.delegate = self;
    
    // Then start advertising.
    advertisor = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICETYPE discoveryInfo:nil session:self.session];
    [advertisor start];
    
    // Create the word bank and the words in it.
    [self createWordBank];
    
    // Timer used to update the connection status label.
    [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector:@selector(refreshConnectionStatus) userInfo: nil repeats:YES];
    
    // On load to the main screen we will not be connected to anybody.
    isConnected = false;
    
    // Set up the background music player.
    NSURL *musicUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mainMenuBackgroundMusic" ofType:@"mp3"]];
    backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicUrl error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Change the settings for the background music so it loops.
    backgroundMusicPlayer.currentTime = 0;
    [backgroundMusicPlayer setNumberOfLoops:-1];
    [backgroundMusicPlayer play];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Timer Method

/**
 * Refresh the connection status with new values every 0.2 seconds.
 */
- (void)refreshConnectionStatus {
    if (isConnected) {
        // Grab the connected Peer and put it in the label.
        NSArray *peerIDs = self.session.connectedPeers;
        NSString *connectedUser = [peerIDs[0] displayName];
        connectionLabel.text = [NSString stringWithFormat:@"%@", connectedUser];
        [playButton setEnabled:YES]; //
    }
    else {
        connectionLabel.text = @"Nobody"; // Nobody is currently connected.
        [playButton setEnabled:NO]; // Player Button is

    }
}

# pragma mark - Browser View Controller Methods

/**
 * Methods that open and close the browserViewController.
 */
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Multipeer Connectivity Methods

/**
 * Method that's called whenever a remote peer changes state.
 */
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    // Grab the current state and output it to console to be used for debugging purposes.
    NSString *currentState = [NSString stringWithFormat:@"Status: %@", peerID.displayName];
    if (state == MCSessionStateConnected)
    {
        NSLog(@"This user has connected: %@", currentState);
        isConnected = true; // An user is now currently connected.
        
        // Add users to the connected_list so we can figure out the current user's peerIndex.
        connected_list = [[NSMutableArray alloc] init];
        [connected_list addObject:[[UIDevice currentDevice] name]];
        
        // Add all connected peers to the connectedPeers list.
        for (MCPeerID *peer in session.connectedPeers) {
            [connected_list addObject:[peer displayName]];
        }

        // Sort the array in alphabetical order so we can properly select which player we are.
        [connected_list sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        // Initialize peer index to 0 in order to grab the proper location of where the peer is located
        // and use that value to set who is player one and two.
        myPeerIndex = 0;
        int counter = 0; // Used to grab the index each time through the loop.
        
        // Go through each user in the connected_list in order for each peer to find their associated peer index.
        for (NSString *user in connected_list) {
            // If your name is equal to the name in the connected list then use that index to grab the peer index.
            if ( [user isEqualToString:[[UIDevice currentDevice] name]]) {
                myPeerIndex = counter;
                break;
            }
            counter++;
        }
    }
    else if (state == MCSessionStateNotConnected)
    {
        isConnected = false; // Since the session is no longer connected then update the label.
        NSLog(@"This user has disconnected: %@", currentState);
    }
}

/**
 * Method that's called whenever data is received from a remote peer.
 */
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Variables that will be used to properly grab data that the other device has sent.
    NSLog(@"Receiving Data");
    NSMutableArray *wordListIndices;
    NSArray *sentWordList;
    
    // The dictionary contains the saved image the other user has drawn.
    NSDictionary *receivedDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *dataKey = receivedDictionary[@"dataKey"];
    
    // If the datakey is equal to GenerateWordList then wordListIndices is initalized to the dataValue.
    if ( ([dataKey isEqualToString:@"GenerateWordList"]) ) {
        wordListIndices = [NSKeyedUnarchiver unarchiveObjectWithData:receivedDictionary[@"dataValue"]];
    }
    
    // If the datakey is equal to SendWordList then sentWordList is initalized to the dataValue.
    if ( ([dataKey isEqualToString:@"SendWordList"]) ) {
        sentWordList = [NSKeyedUnarchiver unarchiveObjectWithData:receivedDictionary[@"dataValue"]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Grab the other random indexes from the other player.
        if ([dataKey isEqualToString:@"GenerateWordList"]) {
            randomIndexList = wordListIndices;
        }
        // Grab the wordlist from the other player.
        else if ([dataKey isEqualToString:@"SendWordList"]) {
            gameWordList = sentWordList;
        }
        // Perform a segue to start the game for the other player.
        else if ([dataKey isEqualToString:@"StartGame"]) {
            [self performSegueWithIdentifier:@"mainScreenToGameSegue" sender:self];
        }
    });
}

/**
 * Methods that must be inherited but are not actually used.
 */
// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

# pragma mark - Button Methods

/**
 * Method that's called when the connected button is pressed.
 */
- (IBAction)connectButtonPressed:(UIButton *)sender {
    // [self.session disconnect]; ********
    // Present the browser view controller to the user.
    MCBrowserViewController* browserViewController = [[MCBrowserViewController alloc] initWithServiceType:SERVICETYPE session:self.session];
    browserViewController.delegate = self; // Set delegate to self in order to present the view controller.
    [self presentViewController:browserViewController animated:YES completion:nil];
}

/**
 * Method that's called when the play button is pressed.
 */
- (IBAction)playButtonPressed:(UIButton *)sender {
    // If the user is either player 1 or 2 then start the game for everyone.
    if (myPeerIndex == 0 || myPeerIndex == 1) {
        // This array of peers will send the data to all connected peers.
        NSArray *peerIDs = self.session.connectedPeers;
        
        // Initialize random index list
        randomIndexList = [[NSMutableArray alloc] init];
        
        // Grab the word bank used for the game.
        NSInteger randomWordBankIndex = arc4random() % [wordBankList count];
        gameWordList = wordBankList[randomWordBankIndex];
        
        int counter = 0;
        // Generate a random number of gameWordList elements that'll be used for the 5 buttons in the game.
        while (counter < numberOfButtons) {
            NSInteger randomIndex = arc4random() % [gameWordList count];
            NSNumber* randomIndexConvert = [NSNumber numberWithInteger:randomIndex];
            
            // If it's not an unique random index, then don't add it to the list.
            if ([randomIndexList containsObject:[randomIndexConvert stringValue]]) {
                continue;
            }
            counter++;
            [randomIndexList addObject:[randomIndexConvert stringValue]];
        }
        
        // Pass the word list to the other user.
        NSString *sendWordKey = @"SendWordList";
        NSData *sendWordValue =  [NSKeyedArchiver archivedDataWithRootObject:gameWordList];
        NSDictionary *sendWordDictionary = @{@"dataKey":sendWordKey, @"dataValue":sendWordValue};
        NSData *sendWordListData = [NSKeyedArchiver archivedDataWithRootObject:sendWordDictionary];
        
        // Send the indices that generate the word list.
        NSString *generateWordKey = @"GenerateWordList";
        NSData *randomIndexListValue =  [NSKeyedArchiver archivedDataWithRootObject:randomIndexList];
        NSDictionary *randomIndexDictionary = @{@"dataKey":generateWordKey, @"dataValue":randomIndexListValue};
        NSData *randomIndexListData = [NSKeyedArchiver archivedDataWithRootObject:randomIndexDictionary];
        
        // Send the notice to start the game to the other user.
        NSString *roundUpdateKey = @"StartGame";
        NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
        NSData *roundUpdateData = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
        
        // Send data to the other user.
        [self.session sendData:sendWordListData
                       toPeers:peerIDs
                      withMode:MCSessionSendDataUnreliable error:nil];
        
        [self.session sendData:randomIndexListData
                       toPeers:peerIDs
                      withMode:MCSessionSendDataUnreliable error:nil];
        
        [self.session sendData:roundUpdateData
                              toPeers:peerIDs
                             withMode:MCSessionSendDataUnreliable error:nil];
    }
    [self performSegueWithIdentifier:@"mainScreenToGameSegue" sender:self];
}

/**
 * Method that's called when the DISCONNECT button is pressed.
 */
- (IBAction)disconnectButtonPressed:(id)sender {
    [self.session disconnect]; // Disconnect all current users connected to the session.
}

/**
 * Method that's called when the PRACTICE button is pressed.
 */
- (IBAction)practiceButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"mainScreenToPracticeSegue" sender:self]; // Perform a segue to the practice screen.
}

# pragma mark - Helper methods

/*
 * This helper method creates the word bank and all the elements in it.
 */
-(void)createWordBank {
    // Initialize all the words in all word bank categories.
    wbAnimals = [NSArray arrayWithObjects:@"Cat", @"Dog", @"Horse", @"Spider", @"Pig", @"Giraffe", @"Lion", @"Shark", @"Shrimp", @"Toucan", @"Pelican", @"Moose", @"Possum", @"Chicken", @"Whale", @"Monkey", @"Gorilla", @"Lemur", @"Fox", @"Deer", nil];
    
    wbTransport = [NSArray arrayWithObjects:@"Muscle Car", @"Truck", @"Bus", @"Train", @"Plane", @"Skateboard", @"Rollerboards", @"Jet Pack", @"Bicycle", @"Moped", @"Helicopter", @"Snowboard", @"Hover Car", @"Hand Glider", @"Walking", @"Running", nil];
    
    wbWeather = [NSArray arrayWithObjects:@"Sunny", @"Rainy", @"Hail", @"Snowy", @"Foggy", @"Cloudy", @"Flood", @"Full Moon", @"Clear Sky", @"Heat Wave", @"Tsunami", @"Meteors", @"Avalanche", @"Land Slide", nil];
    
    wbEmotions = [NSArray arrayWithObjects:@"Happy", @"Sad", @"Anger", @"Embarrassed", @"Confused", @"Surprised", @"Dead", @"Evil", @"Undead", @"Angel", @"Alien", @"Werewolf", @"Clown", @"Envious", @"Tired", @"Cool Dude", @"Nerd", nil];
    
    wbFood = [NSArray arrayWithObjects:@"Sausage", @"Banana", @"Hot Dog", @"Beans", @"Cucumber", @"Carrot", @"Pickle", @"Squash", @"Soup", @"Apple", @"Pear", @"Watermelon", @"Grapes", @"Orange", @"Pumpkin", @"Olives", @"Blueberries", @"Strawberry", @"Cheese", @"Taco", @"Potatoes", nil];
    
    wbSuperheroes = [NSArray arrayWithObjects:@"Batman", @"Superman", @"Red Lantern", @"The Hulk", @"Thor", @"Supergirl", @"Spider-man", @"Iron Man", @"Loki", @"The Joker", @"Robin", @"Daredevil", @"Luke Cage", @"Batgirl", @"Black Canary", @"Poison Ivy", @"Legion", @"Storm", @"Wolverine", @"Deadpool", @"The Flash", @"Iron Fist", nil];
    
    wbVideoGames = [NSArray arrayWithObjects:@"Mega Man", @"Mario", @"Sonic", @"Zelda" @"Link", @"Luigi", @"Wario", @"Yoshi", @"Pac Man", @"Bowser", @"Kirby", @"Bomberman", @"Spyro", @"Peach", @"Samus", @"Dovahkiin", @"Lara Croft", @"Sackboy", @"Big Daddy", nil];
    
    wbLogos = [NSArray arrayWithObjects:@"Nike", @"McDonalds", @"Wendys", @"Foot Locker", @"Toblerone", @"Apple", @"Windows", @"Twitter", @"Skype", @"LG", @"Pepsi", @"Steam", @"Android", @"Python", @"DeadMau5", @"Playboy", @"Game Spy", @"Starbucks", @"Playstation", nil];
    
    // The list of all the word bank categories used to select a random category.
    wordBankList = [NSArray arrayWithObjects:wbAnimals, wbTransport, wbWeather, wbEmotions, wbFood, wbSuperheroes, wbVideoGames, wbLogos, nil];
}


# pragma mark - Segue Method

/**
 * This method handles passing data between view controllers.
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Handle passing data between the VC main screen to the drawing area that users will play in.
    if ([segue.identifier isEqualToString:@"mainScreenToGameSegue"]) {
        // Set the view controller where the data will be passed to.
        SecondScreen *secondScreenVC = segue.destinationViewController;
        
        // Pass Multipeer variables to next view controller.
        secondScreenVC.drawingSession = self.session;
        secondScreenVC.drawingAdvertisor = self.advertisor;
        // secondScreenVC.drawingPeerID = self.myPeerID;
        
        // Pass game information variables to next view controller.
        secondScreenVC.myPeerIndex = myPeerIndex; // Send
        secondScreenVC.connected_list = self.connected_list;
        
        // Pass the word bank variables to the next view controller.
        secondScreenVC.gameWordList = gameWordList;
        secondScreenVC.wordBankIndicesList = randomIndexList;
        
        // Set the roundCounter to the first round.
        secondScreenVC.roundCounter = 0;
        [backgroundMusicPlayer stop]; // Stop the currently playing background music.
    }
    // Handle passing data between the VC main screen to the practice drawing area.
    else if ([segue.identifier isEqualToString:@"mainScreenToPracticeSegue"]) {
        PracticeAreaViewController *practiceAreaVC = segue.destinationViewController;
        [self.session disconnect]; // Disconnect if going to practice area.
        [backgroundMusicPlayer stop];
        [practiceAreaVC.backgroundMusicPlayer stop];
    }
}

@end

//
//  SecondScreen.m - The drawing area in which the two players will play.
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import "SecondScreen.h"
#import "ResultsScreenViewController.h"

int buttonNumber = 5;

@interface SecondScreen ()

@end

@implementation SecondScreen

// Variables related to the drawing process.
@synthesize pointLastTouched;
@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize wasMouseMoved;
// Word Bank Button Variables
@synthesize timerLabel;
@synthesize wordBankButton1;
@synthesize wordBankButton2;
@synthesize wordBankButton3;
@synthesize wordBankButton4;
@synthesize wordBankButton5;
@synthesize submitImage;
@synthesize myPeerIndex;
@synthesize roundCounter;
@synthesize imageToSend;
// Game Loop variables
@synthesize points;
@synthesize chosenWord;
@synthesize pictureGuess;
@synthesize pictureAnswer;
@synthesize secondPlayerGuess;
@synthesize gameWordList;
@synthesize wordBankIndicesList;
@synthesize timer;
@synthesize timerDuration;
@synthesize timerDecrementAmount;
// AV audio variables
@synthesize drawingSoundsMusicPlayer;
@synthesize resetSoundMusicPlayer;

- (void)viewDidLoad {
    // Set default colour to black.
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    
    // Changing session to delegate to self so images and other data can be sent properly.
    self.drawingSession.delegate = self;
    
    // Set how long the timer is and the timer decrement amound..
    timerDuration = 60;
    timerDecrementAmount = 1;
    timer = timerDuration;
    timerLabel.text = [NSString stringWithFormat:@"Time Remaining: %.0f", timer];
    
    // Set the chosenWord to the middle button for player one.
    chosenWord = gameWordList[[wordBankIndicesList[2] integerValue]];
    pictureAnswer = chosenWord; // The answer to the currrent chosen word.
    secondPlayerGuess = @"Nothing"; // The word that player 2 guesses player 1's image is.
    
    // Points are currently zero.
    points = 0;
    
    // Set imageToSend to the blank canvas.
    imageToSend = self.drawSpace.image;
    
    // Update the gamestate based on the current round and the peerIndex
    [self updateGameState:myPeerIndex :0];
    
    // Start a timer for the game currently played.
    NSTimer *gameTimer = [NSTimer scheduledTimerWithTimeInterval: timerDecrementAmount target: self selector:@selector(updateTimer) userInfo: nil repeats:YES];
    
    // Set up the music player for drawing sounds.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"drawingSounds" ofType:@"wav"]];
    drawingSoundsMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set up the drawing sounds music player.
    NSURL *resetUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"resetDrawingSound" ofType:@"mp3"]];
    resetSoundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:resetUrl error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set variables that are used for the audio that's played when drawing.
    resetSoundMusicPlayer.currentTime = 0;
    
    // Set variables that are used for the audio that's played when drawing.
    drawingSoundsMusicPlayer.currentTime = 0;
    [drawingSoundsMusicPlayer setNumberOfLoops:-1];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Timer Method.

/**
 * Timer method that decrements the game timer and the changes the gamestate depending if the timer value is 0.
 */
-(void)updateTimer {
    timer -= timerDecrementAmount;
    timerLabel.text = [NSString stringWithFormat:@"Time Remaining: %.0f", timer]; // Update the time on the timer label.
    
    // If timer is zero then update game state.
    if (timer <= 0) {
        timer = timerDuration;
        [self updateGameStateByTimer:myPeerIndex :roundCounter];
    }
}

# pragma mark - Methods related to drawing.

/**
 * Method called when the drawing begins.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Mouse currently hasn't been moved.
    wasMouseMoved = NO;
    UITouch *touchPosition = [touches anyObject];
    pointLastTouched = [touchPosition locationInView:self.view];
    [drawingSoundsMusicPlayer play]; // Play the drawing sounds.
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Mouse has been move so update the update the touch position.
    wasMouseMoved = YES;
    UITouch *touchPosition = [touches anyObject];
    CGSize screenFrameSize = self.view.frame.size; // Frame size of the drawSpace being drawn on.
    CGPoint pointCurrentlyTouched = [touchPosition locationInView:self.view];
    
    // Grab the graphics context so we can draw on the image.
    UIGraphicsBeginImageContext(screenFrameSize);
    
    // Make a rectangle and draw in it.
    [self.drawSpace.image drawInRect:CGRectMake(0, 0, screenFrameSize.width, screenFrameSize.height)];
    
    // Set drawing related contexts.
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pointLastTouched.x, pointLastTouched.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), pointCurrentlyTouched.x, pointCurrentlyTouched.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0 );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    // Put the drawn image on the drawSpace.
    self.drawSpace.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    pointLastTouched = pointCurrentlyTouched; // Touch is over. Update image.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // If the mouse wasn't moved then update the image.
    if(!wasMouseMoved) {
        CGSize screenFrameSize = self.view.frame.size; // Frame size of the drawSpace being drawn on.
        
        // Grab the graphics context so we can draw on the image.
        UIGraphicsBeginImageContext(screenFrameSize);
        
        // Make a rectangle and draw in it.
        [self.drawSpace.image drawInRect:CGRectMake(0, 0, screenFrameSize.width, screenFrameSize.height)];
        
        // Set drawing related contexts.
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pointLastTouched.x, pointLastTouched.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), pointLastTouched.x, pointLastTouched.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        
        // Put the drawn image on the drawSpace.
        self.drawSpace.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Begin a Drawing context so you can draw what was currently being drawn in the drawSpace.
    UIGraphicsBeginImageContext(self.drawSpace.frame.size);
    [self.drawSpace.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    // Put the drawn image on the drawSpace.
    self.drawSpace.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [drawingSoundsMusicPlayer stop]; // Stop the drawing sounds.
}

# pragma mark - Colour and Eraser Methods

/**
 * Method called when the black color is selected.
 */
- (IBAction)BlackSelected:(id)sender {
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
}

/**
 * Method called when the red color is selected.
 */
- (IBAction)redSelected:(id)sender {
    red = 255.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
}

/**
 * Method called when the blue color is selected.
 */
- (IBAction)BlueSelected:(id)sender {
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 166.0/255.0;
}

/**
 * Method called when the green color is selected.
 */
- (IBAction)GreenSelected:(id)sender {
    // NSLog(@"Green");
    red = 0.0/255.0;
    green = 168.0/255.0;
    blue = 0.0/255.0;
}

/**
 * Method called when the yellow color is selected.
 */
- (IBAction)YellowSelected:(id)sender {
    // NSLog(@"Yellow");
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 0.0/255.0;
}

/**
 * Method called when the eraser is selected.
 */
- (IBAction)EraserSelecte:(id)sender {
    // NSLog(@"Eraser");
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
}

# pragma mark - Button Methods.

/**
 * Method called when the submit button is pressed.
 */
- (IBAction)submitButtonPressed:(UIButton *)sender {
    // This array of peers will send data to all connected peers.
    NSArray *peerIDs = self.drawingSession.connectedPeers;
    imageToSend = self.drawSpace.image;
    NSData *imageToSendData;
    
    // If nothing is drawn on the canvas, don't execute anything else in the method.
    if (imageToSend == nil) {
        NSLog(@"Nothing on the Canvas");
        return;
    }
    
    // Erase half of the screen.
    UIImage *image = imageToSend;
    UIImage *maskedImage = nil;
    
    // if randomNumber is 0 then left side is erased and if it's 1 then right side is erased.
    int randomNumber = arc4random() % 2; // Grab a random number between 0 and 1.
    if (randomNumber == 0) {
        // Erase Left Side
        maskedImage = [self clearArea:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height) inImage:image];
    } else  {
        // Erase Right Side.
        maskedImage = [self clearArea:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height) inImage:image];
    }
    
    // Send an image through Multipeer Connectivity
    // Convert image to a dictionary so that multipeer connectivity can properly send the image.
    NSString *imageToSendKey = @"SentImage";
    
    // Change the image to send depending on the round
    if (roundCounter == 1) {
        imageToSendData = UIImagePNGRepresentation(imageToSend);
    }
    else {
        imageToSendData = UIImagePNGRepresentation(maskedImage);
    }
    
    NSDictionary *imageDictionary = @{@"dataKey":imageToSendKey, @"dataValue":imageToSendData};
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:imageDictionary];
    
    // Send data to user.
    [self.drawingSession sendData:dataToSend
                   toPeers:peerIDs
                  withMode:MCSessionSendDataUnreliable error:nil];
    
    
    // Now go to the next round by increasing the counter and changing the game state.
    roundCounter++;
    [self updateGameState:myPeerIndex :roundCounter];
    
    NSString *roundUpdateKey = @"UpdateRound";
    NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
    dataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
    
    timer = timerDuration;
    // Send data to user.
    [self.drawingSession sendData:dataToSend
                          toPeers:peerIDs
                         withMode:MCSessionSendDataUnreliable error:nil];
}

/**
 * Method called when the reset button is pressed.
 */
- (IBAction)ResetImage:(id)sender {
    [resetSoundMusicPlayer play];
    self.drawSpace.image = nil; // Set image to nil to erase the whole image.
}

/**
 * Method called whenever a button is pressed.
 */
- (IBAction)wordBankButtonPressed:(UIButton *)sender {
    pictureGuess = sender.currentTitle; // The picture guess is the name of the current button pressed.
    NSArray *peerIDs = self.drawingSession.connectedPeers;
    
    // Send the picture guess to the other user.
    NSString *roundUpdateKey = @"UpdatePictureSolution";
    NSData *dummyValue =  [pictureGuess dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
    NSData *pictureAnswerDataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
    
    // Send data to user.
    [self.drawingSession sendData:pictureAnswerDataToSend
                          toPeers:peerIDs
                         withMode:MCSessionSendDataUnreliable error:nil];
}

#pragma mark - Browser View Controller Methods

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
    }
    else if (state == MCSessionStateNotConnected)
    {
        NSLog(@"This user has disconnected: %@", currentState);
    }
}

/**
 * Method that's called whenever data is received from a remote peer.
 */
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Initialize variables
    NSLog(@"Receiving Data");
    NSData *dataValue;
    UIImage *receivedImage;
    NSMutableArray *wordListIndices;
    
    // The dictionary contains the saved data the other user has sent.
    NSDictionary *receivedImageDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *dataKey = receivedImageDictionary[@"dataKey"];
    
    // If a string was sent then convert the sent data to a string.
    NSString *receivedString = [[NSString alloc] initWithData:receivedImageDictionary[@"dataValue"] encoding:NSASCIIStringEncoding];

    // If an image was sent then convert the sent data to a image.
    if ([dataKey isEqualToString:@"SentImage"]) {
        dataValue = receivedImageDictionary[@"dataValue"];
        receivedImage = [UIImage imageWithData:dataValue scale:[UIScreen mainScreen].scale];
    }
    
    // If an array was sent then convert the sent data to an array.
    else if ([dataKey isEqualToString:@"GenerateWordList"]) {
        wordListIndices = [NSKeyedUnarchiver unarchiveObjectWithData:receivedImageDictionary[@"dataValue"]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the image if that dataKey was sent.
        if ([dataKey isEqualToString:@"SentImage"]) {
            self.drawSpace.image = receivedImage;
        }
        
        // Update the round if that dataKey was sent.
        else if ([dataKey isEqualToString:@"UpdateRound"]) {
            if (roundCounter == 2) {
                // pictureAnswer = pictureGuess;
            }
            timer = timerDuration;
            roundCounter++;
            [self updateGameState:myPeerIndex :roundCounter];
        }
        
        // Increase the points if that dataKey was sent.
        else if ([dataKey isEqualToString:@"IncreasePoints"]) {
            points++;
        }
        
        // Change the second player guess if that dataKey was sent.
        else if ([dataKey isEqualToString:@"UpdatePictureSolution"]) {
            secondPlayerGuess = receivedString;
        }
        NSLog(@"receivedData is %@", receivedString);
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

# pragma mark - Helper Methods

/**
 * This method updates the user's screen depending on the round of the game.
 */
-(void)updateGameState:(int)peerIndex :(int)round {
    // Update the game area to reflect the first round of the game. With player one having one
    // word button and player two having no word bank buttons on screen.
    if (round == 0) {
        // If myPeerIndex is 0 then that peer will be player one and start drawing first.
        if (peerIndex == 0) {
            // Set the word bank buttons to the gameWordList
            [wordBankButton1 setTitle:gameWordList[[wordBankIndicesList[0] integerValue]] forState:UIControlStateNormal];
            [wordBankButton2 setTitle:gameWordList[[wordBankIndicesList[1] integerValue]] forState:UIControlStateNormal];
            [wordBankButton3 setTitle:gameWordList[[wordBankIndicesList[2] integerValue]] forState:UIControlStateNormal];
            [wordBankButton4 setTitle:gameWordList[[wordBankIndicesList[3] integerValue]] forState:UIControlStateNormal];
            [wordBankButton5 setTitle:gameWordList[[wordBankIndicesList[4] integerValue]] forState:UIControlStateNormal];
            
            // Set buttons to be hidden and disabled.
            [wordBankButton1 setEnabled:NO];
            [wordBankButton2 setEnabled:NO];
            [wordBankButton4 setEnabled:NO];
            [wordBankButton5 setEnabled:NO];
            
            wordBankButton1.hidden = YES;
            wordBankButton2.hidden = YES;
            wordBankButton4.hidden = YES;
            wordBankButton5.hidden = YES;
            
        }
        // If myPeerIndex is 1 then that peer will be player two and will wait on user one's drawing.
        else if (peerIndex == 1) {
            // Generate a new list of randomized list of indices by shuffling around the current array.
            NSMutableArray *randomizedWordBankIndicesList = [[NSMutableArray alloc] initWithArray:wordBankIndicesList];
            
            // Go through each element in the wordBankIndicesList and shuffle them around.
            for (NSUInteger i = [wordBankIndicesList count]; i > 1; i--) {
                uint32_t j = arc4random() % buttonNumber;
                [randomizedWordBankIndicesList exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
            }
            
            // Set the word bank buttons to the gameWordList
            [wordBankButton1 setTitle:gameWordList[[randomizedWordBankIndicesList[0] integerValue]] forState:UIControlStateNormal];
            [wordBankButton2 setTitle:gameWordList[[randomizedWordBankIndicesList[1] integerValue]] forState:UIControlStateNormal];
            [wordBankButton3 setTitle:gameWordList[[randomizedWordBankIndicesList[2] integerValue]] forState:UIControlStateNormal];
            [wordBankButton4 setTitle:gameWordList[[randomizedWordBankIndicesList[3] integerValue]] forState:UIControlStateNormal];
            [wordBankButton5 setTitle:gameWordList[[randomizedWordBankIndicesList[4] integerValue]] forState:UIControlStateNormal];
            
            // Set buttons to be hidden and disabled.
            [wordBankButton1 setEnabled:NO];
            [wordBankButton2 setEnabled:NO];
            [wordBankButton3 setEnabled:NO];
            [wordBankButton4 setEnabled:NO];
            [wordBankButton5 setEnabled:NO];

            wordBankButton1.hidden = YES;
            wordBankButton2.hidden = YES;
            wordBankButton3.hidden = YES;
            wordBankButton4.hidden = YES;
            wordBankButton5.hidden = YES;
            
            // Disable the submit button
            [submitImage setEnabled:NO];
            submitImage.hidden = YES;
        }
    }
    // Update the game area to reflect the second round of the game. With player one having no words
    // and player two having five word bank buttons on the screen and the submit button.
    else if (round == 1) {
        // Player one will now have no buttons on screen and not be able to submit anything.
        if (peerIndex == 0) {
            // Disable all buttons.
            [wordBankButton1 setEnabled:NO];
            [wordBankButton2 setEnabled:NO];
            [wordBankButton3 setEnabled:NO];
            [wordBankButton4 setEnabled:NO];
            [wordBankButton5 setEnabled:NO];
            
            // Hide all buttons.
            wordBankButton1.hidden = YES;
            wordBankButton2.hidden = YES;
            wordBankButton3.hidden = YES;
            wordBankButton4.hidden = YES;
            wordBankButton5.hidden = YES;
            
            // Disable and hide submit button.
            [submitImage setEnabled:NO];
            submitImage.hidden = YES;
        }
        // Player two will now have all buttons and be able to submit an image.
        else if (peerIndex == 1) {
            // Enable all buttons.
            [wordBankButton1 setEnabled:YES];
            [wordBankButton2 setEnabled:YES];
            [wordBankButton3 setEnabled:YES];
            [wordBankButton4 setEnabled:YES];
            [wordBankButton5 setEnabled:YES];
            
            // Show all buttons.
            wordBankButton1.hidden = NO;
            wordBankButton2.hidden = NO;
            wordBankButton3.hidden = NO;
            wordBankButton4.hidden = NO;
            wordBankButton5.hidden = NO;
            
            // Enable and show submit button.
            [submitImage setEnabled:YES];
            submitImage.hidden = NO;
        }
    }
    
    // Update the game area to reflect the second round of the game. With player two having no words
    // and player one having five word bank buttons on the screen and the submit button.
    else if (round == 2) {
        // Player 1 will now have all buttons to select which word he thought player two drew.
        if (peerIndex == 0) {
            // Enable all buttons.
            [wordBankButton1 setEnabled:YES];
            [wordBankButton2 setEnabled:YES];
            [wordBankButton3 setEnabled:YES];
            [wordBankButton4 setEnabled:YES];
            [wordBankButton5 setEnabled:YES];
            
            // Show all buttons.
            wordBankButton1.hidden = NO;
            wordBankButton2.hidden = NO;
            wordBankButton3.hidden = NO;
            wordBankButton4.hidden = NO;
            wordBankButton5.hidden = NO;
            
            // Enable and show submit button.
            [submitImage setEnabled:YES];
            submitImage.hidden = NO;
        }
        // Player 2 will now have no buttons and will wait on player one to select a button.
        else if (peerIndex == 1) {
            // Disable all buttons.
            [wordBankButton1 setEnabled:NO];
            [wordBankButton2 setEnabled:NO];
            [wordBankButton3 setEnabled:NO];
            [wordBankButton4 setEnabled:NO];
            [wordBankButton5 setEnabled:NO];
            
            // Hide all buttons.
            wordBankButton1.hidden = YES;
            wordBankButton2.hidden = YES;
            wordBankButton3.hidden = YES;
            wordBankButton4.hidden = YES;
            wordBankButton5.hidden = YES;
            
            // Disable and hide submit button.
            [submitImage setEnabled:NO];
            submitImage.hidden = YES;
            
            // Now we'll check if player 2 if guessed the right image.
            if ([pictureAnswer isEqualToString:pictureGuess]) {
                [self updatePoints];
            }
            pictureAnswer = pictureGuess;
        }
    }
    
    // This round will kick both players to the results screen.
    else if (round >= 3) {
        // Checking if player one understood what player 2 drew.
        if (peerIndex == 0) {
            // Now we'll check if player 2 guessed the right image.
            if ([secondPlayerGuess isEqualToString:pictureGuess]) {
                [self updatePoints];
            }
        }
        // Call the segue that moves us to the results screen.
        [self performSegueWithIdentifier:@"goToResultsScreen" sender:self];
    }
}

/**
 * This method updates the user's screen depending on if the timer is ran out.
 */
-(void)updateGameStateByTimer:(int)peerIndex :(int)round {
    // This array of peers will send the data to all connected peers.
    NSArray *peerIDs = self.drawingSession.connectedPeers;
    
    // If round one and player one then send over that player's image.
    if ( (round == 0) & (peerIndex == 0) ) {
        // This array of peers will send the data to all connected peers.
        NSArray *peerIDs = self.drawingSession.connectedPeers;
        imageToSend = self.drawSpace.image;
        NSData *imageToSendData;
        
        // If nothing is drawn on the canvas, don't execute anything else in the method.
        if (imageToSend == nil) {
            NSLog(@"Nothing on the Canvas");
            
            // Now go to the next round by increasing the counter and changing the game state.
            roundCounter++;
            [self updateGameState:myPeerIndex :roundCounter];
            
            // Send update round data to the other user.
            NSString *roundUpdateKey = @"UpdateRound";
            NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
            NSData *updatedDataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
            timer = timerDuration;
            
            // Send data to user.
            [self.drawingSession sendData:updatedDataToSend
                                  toPeers:peerIDs
                                 withMode:MCSessionSendDataUnreliable error:nil];
            
            return;
            
            
        }
        
        // Erase half of the screen.
        UIImage *image = imageToSend;
        UIImage *maskedImage = nil;
        
        // if randomNumber is 0 then left side is erased and if it's 1 then right side is erased.
        int randomNumber = arc4random() % 2; // Grab a random number between 0 and 1.
        if (randomNumber == 0) {
            // Erase Left Side
            maskedImage = [self clearArea:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height) inImage:image];
        } else  {
            // Erase Right Side.
            maskedImage = [self clearArea:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height) inImage:image];
        }
        
        // Sending a image through Multipeer Connectivity
        // Convert image to a dictionary so that multipeer connectivity can properly send the image.
        NSString *imageToSendKey = @"SentImage";
        if (roundCounter == 1) {
            imageToSendData = UIImagePNGRepresentation(imageToSend);
        }
        else {
            imageToSendData = UIImagePNGRepresentation(maskedImage);
        }
        NSDictionary *imageDictionary = @{@"dataKey":imageToSendKey, @"dataValue":imageToSendData};
        NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:imageDictionary];
        
        // Send data to user.
        [self.drawingSession sendData:dataToSend
                              toPeers:peerIDs
                             withMode:MCSessionSendDataUnreliable error:nil];
        
        // Now go to the next round by increasing the counter and changing the game state.
        roundCounter++;
        [self updateGameState:myPeerIndex :roundCounter];
        
        // Send update round data to the other user.
        NSString *roundUpdateKey = @"UpdateRound";
        NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
        NSData *updatedDataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
        timer = timerDuration;
        
        // Send data to user.
        [self.drawingSession sendData:updatedDataToSend
                              toPeers:peerIDs
                             withMode:MCSessionSendDataUnreliable error:nil];
    }
    
    // If round two and player two then send over that player's image.
    else if ( (round == 1) & (peerIndex == 1) ) {
        // This array of peers will send the data to all connected peers.
        NSArray *peerIDs = self.drawingSession.connectedPeers;
        imageToSend = self.drawSpace.image;
        NSData *imageToSendData;
        
        // If nothing is drawn on the canvas, don't execute anything else in the method.
        if (imageToSend == nil) {
            NSLog(@"Nothing on the Canvas");
            
            // Now go to the next round by increasing the counter and changing the game state.
            roundCounter++;
            [self updateGameState:myPeerIndex :roundCounter];
            
            // Send update round data to the other user.
            NSString *roundUpdateKey = @"UpdateRound";
            NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
            NSData *updatedDataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
            timer = timerDuration;
            
            // Send data to user.
            [self.drawingSession sendData:updatedDataToSend
                                  toPeers:peerIDs
                                 withMode:MCSessionSendDataUnreliable error:nil];
            return;
        }
        
        // Erase half of the screen.
        UIImage *image = imageToSend;
        UIImage *maskedImage = nil;
        
        // if randomNumber is 0 then left side is erased and if it's 1 then right side is erased.
        int randomNumber = arc4random() % 2; // Grab a random number between 0 and 1.
        if (randomNumber == 0) {
            // Erase Left Side
            maskedImage = [self clearArea:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height) inImage:image];
        } else  {
            // Erase Right Side.
            maskedImage = [self clearArea:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height) inImage:image];
        }
        
        // Sending a image through Multipeer Connectivity
        // Convert image to a dictionary so that multipeer connectivity can properly send the image.
        NSString *imageToSendKey = @"SentImage";
        if (roundCounter == 1) {
            imageToSendData = UIImagePNGRepresentation(imageToSend);
        }
        else {
            imageToSendData = UIImagePNGRepresentation(maskedImage);
        }
        
        NSDictionary *imageDictionary = @{@"dataKey":imageToSendKey, @"dataValue":imageToSendData};
        NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:imageDictionary];
        
        // Send data to user.
        [self.drawingSession sendData:dataToSend
                              toPeers:peerIDs
                             withMode:MCSessionSendDataUnreliable error:nil];
        
        // Now go to the next round by increasing the counter and changing the game state.
        roundCounter++;
        [self updateGameState:myPeerIndex :roundCounter];
        
        // Send update round data to the other user.
        NSString *roundUpdateKey = @"UpdateRound";
        NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
        NSData *updatedDataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
        timer = timerDuration;
        
        // Send data to user.
        [self.drawingSession sendData:updatedDataToSend
                              toPeers:peerIDs
                             withMode:MCSessionSendDataUnreliable error:nil];

    }
    else if ( (round == 2) & (peerIndex == 0) ) {
        // Now go to the next round by increasing the counter and changing the game state.
        roundCounter++;
        [self updateGameState:myPeerIndex :roundCounter];
        
        // Send update round data to the other user.
        NSString *roundUpdateKey = @"UpdateRound";
        NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
        NSData *updatedDataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
        timer = timerDuration;
        
        // Send data to user.
        [self.drawingSession sendData:updatedDataToSend
                              toPeers:peerIDs
                             withMode:MCSessionSendDataUnreliable error:nil];

    }
    else if (round >= 3) {
        // Call the segue that moves us to the results screen.
        [self performSegueWithIdentifier:@"goToResultsScreen" sender:self];
        
    }
}

/**
 * This method updates a player's points and sends over their points to the other player.
 */
-(void)updatePoints {
    points++; // Update the points for the user on one device.
    
    // Now send the point values to the other user.
    // This array of peers will send the data to all connected peers.
    NSArray *peerIDs = self.drawingSession.connectedPeers;
    
    // Send over a dictionary so the other player's points will increase.
    NSString *roundUpdateKey = @"IncreasePoints";
    NSData *dummyValue =  [@"dummy" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *roundUpdateDictionary = @{@"dataKey":roundUpdateKey, @"dataValue":dummyValue};
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:roundUpdateDictionary];
    
    // Send data to user.
    [self.drawingSession sendData:dataToSend
                          toPeers:peerIDs
                         withMode:MCSessionSendDataUnreliable error:nil];
}

/**
 * This method is used to assist in cutting an image in half.
 */
- (UIImage *)clearArea:(CGRect)clearArea inImage:(UIImage *)imageToClear {
    // If context is null then change the Graphics Context accordingly.
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions([imageToClear size], NO, 0.0);
    else
        UIGraphicsBeginImageContext([imageToClear size]);
    
    // Grab the current image context.
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Grab the image passed it, and clear the image based on the image's size and location.
    [imageToClear drawInRect:CGRectMake(0.0, 0.0, [imageToClear size].width, [imageToClear size].height)];
    CGContextClearRect(c, clearArea);
    
    // Grab the cleared image and return it.
    UIImage *clearedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clearedImage;
}

# pragma mark - Segue Methods

/**
 * This method handles passing data between view controllers.
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Handle passing data between the vc main screen to the results screen.
    if ([segue.identifier isEqualToString:@"goToResultsScreen"]) {
        // Set the view controller where the data will be modified.
        ResultsScreenViewController *resultsScreenVC = segue.destinationViewController;
        resultsScreenVC.totalPoints = points;
    }
}

@end

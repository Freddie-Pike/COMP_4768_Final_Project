//
//  PracticeAreaViewController.m
//  COMP_4768_Project
//
//  Created by Freddie Pike, Josh Forward, Tyler Beckett on 2017-03-23.
//  Copyright © 2017 Freddie Pike, Josh Forward, Tyler Beckett. All rights reserved.
//

#import "PracticeAreaViewController.h"
#import "ResultsScreenViewController.h"
#import "ViewController.h"

@interface PracticeAreaViewController ()

@end

@implementation PracticeAreaViewController

// Synthesize variables
// Variables related to the drawing process.
@synthesize pointLastTouched;
@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize wasMouseMoved;
// Word Bank Button Variables
@synthesize wordBankButton1;
@synthesize wordBankButton2;
@synthesize wordBankButton3;
@synthesize wordBankButton4;
@synthesize wordBankButton5;
@synthesize submitImage;
@synthesize myPeerIndex;
@synthesize roundCounter;
// Game Loop variables
@synthesize points;
@synthesize chosenWord;
@synthesize pictureGuess;
@synthesize pictureAnswer;
@synthesize secondPlayerGuess;
@synthesize randomIndexList;
// Audio Player Variables
@synthesize backgroundMusicPlayer;
@synthesize drawingSoundsMusicPlayer;
@synthesize resetSoundMusicPlayer;


- (void)viewDidLoad {
    // Set default colour to black.
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    
    // Changing delegate
    self.drawingSession.delegate = self;
    
    // Set the game state to the practice mode version.
    [self updateGameState];
    
    // Set up the background music player.
    NSURL *musicUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mainMenuBackgroundMusic" ofType:@"mp3"]];
    backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicUrl error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
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
 * Method called when the return button is pressed.
 */
- (IBAction)submitButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"practiceToMainScreenSegue" sender:self];
}

/**
 * Method called when the reset button is pressed.
 */
- (IBAction)ResetImage:(id)sender {
    [resetSoundMusicPlayer play]; // Play the drawing sounds.
    self.drawSpace.image = nil; // The Set image to nil to erase the whole image.
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
 * Method that's called whenever data is received data from a remote peer.
 */
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // The data that the other device has sent.
    NSString *receivedData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"Receiving Data");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"receivedData is %@", receivedData);
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
 * This will update the game state to a practice mode version.
 */
-(void)updateGameState {
    // Eisable all buttons.
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
    
    // Enable and show submit button.
    [submitImage setEnabled:YES];
    submitImage.hidden = NO;
}

# pragma mark - Segue Methods

/**
 * This method handles all passing data between view controllers.
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Handle passing data between the practice area to vc main screen.
    if ([segue.identifier isEqualToString:@"practiceToMainScreenSegue"]) {
        ViewController *mainVC = segue.destinationViewController;
        [mainVC.backgroundMusicPlayer stop];
        [backgroundMusicPlayer stop];
    }
}

@end

//
//  SpeechRecognition.m
//  Brian Huynh
//
//  Created by Brian Huynh on 4/25/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>

#import "SpeechRecognition.h"

@interface SpeechRecognition ()

- (IBAction)startListenButtonAction;
- (IBAction)stopListenButtonAction;

// Properties related to Speech Recognition module
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedDictionary;
@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;
@property (nonatomic, assign) BOOL doNotStart;

@end

@implementation SpeechRecognition

// - MARK: Functional Issue
// I was unable to implement a feature that would have allow the user to begin speaking right as the app opens.
// The workaround was to have the user open the app, provide permission to the app, close and re-open the app.

- (void)viewDidLoad {
    [super viewDidLoad];
    // App begins recording the user's voice at the start
    self.startButton.hidden = TRUE;
    self.stopButton.hidden = FALSE;
    self.startupFailedDueToLackOfPermissions = TRUE;
    self.doNotStart = TRUE;

    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    // Words and phrases the speech to text module will be able to accept
    NSArray *words = [NSArray arrayWithObjects: @"EDUCATION" ,@"PERSONAL PROJECTS", @"PROFESSIONAL BACKGROUND", @"TECHNICAL SKILLS", @"FAVORITE APPLE EXECUTIVE", nil];
    NSString *name = @"MyLanguageModel";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    if(err == nil) {
        self.pathToFirstDynamicallyGeneratedLanguageModel = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:name];
        self.pathToFirstDynamicallyGeneratedDictionary = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:name];
    }
    
    else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    [self requestMicPermission];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) requestMicPermission {
    [self micPermissionCheckCompleted:self.startupFailedDueToLackOfPermissions];
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    // Speech to Text module has recognized the words mentioned by the user.
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    [self speechDecisions:hypothesis];
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
    self.doNotStart = FALSE;
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

// The function checks if the user has allowed permission to use the microphone
- (void) micPermissionCheckCompleted:(BOOL)result {
    if(result) {
        self.restartAttemptsDueToPermissionRequests++;
        if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions) { // If we get here because there was an attempt to start which failed due to lack of permissions, and now permissions have been requested and they returned true, we restart exactly once with the new permissions.
            NSError *error = nil;
            if([OEPocketsphinxController sharedInstance].isListening){
                error = [[OEPocketsphinxController sharedInstance] stopListening]; // Stop listening if we are listening.
                if(error) NSLog(@"Error while stopping listening in micPermissionCheckCompleted: %@", error);
            }
            if(!error && ![OEPocketsphinxController sharedInstance].isListening) { // If there was no error and we aren't listening, start listening.
                [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition.
                self.startupFailedDueToLackOfPermissions = FALSE;
            }
        }
    }
}

// - MARK: Speech Decision Logic
- (void) speechDecisions: (NSString*)inputSpeech {
    AVSpeechSynthesizer * synthesizer = [[AVSpeechSynthesizer alloc]init];
    
    NSString * response = [[NSString alloc]init];
    
    if([inputSpeech isEqualToString:@"PERSONAL PROJECTS"])
    {
        response = @"One of my favorite personal projects was a barbell calculator app that a friend and I built in Swift";
    }
    else if([inputSpeech isEqualToString:@"PROFESSIONAL BACKGROUND"])
    {
        response = @"In the past summer, I worked at Cisco Systems Inc as an Network Engineer Intern.  I was tasked with developing a tool that measured packet loss, latency and jitter from high speed media stream traffic.";
    }
    else if([inputSpeech isEqualToString:@"TECHNICAL SKILLS"])
    {
        response = @"My technical skills are Python, C++, Java, HTML, Javascript, Objective-C and Swift.";
    }
    else if([inputSpeech isEqualToString:@"FAVORITE APPLE EXECUTIVE"])
    {
        response = @"This is kind of a tough question, but if I have to pick one it has to be Craig Federighi.";
    }
    else if([inputSpeech isEqualToString:@"EDUCATION"])
    {
        response = @"I am currently a Junior attending California State University, Monterey Bay.  My major is Computer Science with a concentration in Software Engineering.";
    }
    
    self.userInput.text = inputSpeech;
    self.screenOutput.text = response;
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:response];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    [synthesizer speakUtterance:utterance];
    
    self.startButton.hidden = FALSE;
    self.stopButton.hidden = TRUE;
    
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
    
}

- (IBAction)startListenButtonAction {

    [[OEPocketsphinxController sharedInstance] stopListening];
    
        [[OEPocketsphinxController sharedInstance] resumeRecognition];
        if(![OEPocketsphinxController sharedInstance].isListening) {
            [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    
        self.startButton.hidden = TRUE;
        self.stopButton.hidden = FALSE;
    }
}
- (IBAction)stopListenButtonAction {
    self.startButton.hidden = FALSE;
    self.stopButton.hidden = TRUE;
    
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
    
}
@end

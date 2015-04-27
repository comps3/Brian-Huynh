//
//  SpeechRecognition.h
//  Brian Huynh
//
//  Created by Brian Huynh on 4/25/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OEEventsObserver.h>

@interface SpeechRecognition : UIViewController <OEEventsObserverDelegate>

// Sets up outputs that display what the user said and the system response
@property (strong, nonatomic) IBOutlet UILabel *userInput;
@property (strong, nonatomic) IBOutlet UITextView *screenOutput;
@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@property(weak, nonatomic) NSString *capturedWords;
// Allows users to start and stop the program listening
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;





@end


//
//  SampleViewController.h
//  Sample
//
//  Created by Kirby Turner on 8/2/10.
//  Copyright White Peak Software Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> 
#import <CoreAudio/CoreAudioTypes.h>
#import "KTDownloadManagerDelegate.h"

@class KTDownloadManager;

@interface SampleViewController : UIViewController <KTDownloadManagerDelegate, AVAudioPlayerDelegate> {
   KTDownloadManager *dm;
   NSInteger downloadCount;
   UIImageView *imageView;
   UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end


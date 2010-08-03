//
//  SampleViewController.m
//  Sample
//
//  Created by Kirby Turner on 8/2/10.
//  Copyright White Peak Software Inc 2010. All rights reserved.
//

#import "SampleViewController.h"

@implementation SampleViewController

@synthesize imageView;
@synthesize activityIndicator;

- (void)dealloc {
   [imageView release], imageView = nil;
   [activityIndicator release], activityIndicator = nil;
   [dm release], dm = nil;
   
   [super dealloc];
}


- (void)viewDidLoad {
   [super viewDidLoad];
   
   downloadCount = 0;
   
   dm = [[MyDownloadManager alloc] init];
   [dm setDelegate:self];
   
   // Download an image. Cache it in memory and on the file system.
   downloadCount += 1;
   NSURL *imageURL = [NSURL URLWithString:@"http://farm4.static.flickr.com/3427/3192205971_0f494a3da2_o.jpg"];
   [dm downloadImageWithURL:imageURL];
   
   // Download an audio file (.mp3). Since the media player has trouble
   // detecting audio file formats from memory buffers, we'll cache the
   // audio to the file system only and use the file URL for playback.
   downloadCount += 1;
   NSURL *audioURL = [NSURL URLWithString:@"http://thecave.com/downloads/control.mp3"];
   [dm downloadAudioFileWithURL:audioURL];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   
   [self setImageView:nil];
   [self setActivityIndicator:nil];
}

- (void)playAudioFileAtURL:(NSURL *)fileURL
{
   NSError *error = nil;
   AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
   
   if (error) {
      NSLog(@"Audio player error: %@", [error localizedDescription]);
      [player release], player = nil;
   } else {
      [player setDelegate:self];
      [player setMeteringEnabled:NO];
      [player setVolume:1.0];
      [player setNumberOfLoops:0];
      [player play];
   }
}

- (void)decDownloadCount 
{
   downloadCount -= 1;
   if (downloadCount < 1) {
      [activityIndicator stopAnimating];
      downloadCount = 0;
   }
}


#pragma mark -
#pragma mark MyDownloadManagerDelegate Methods

- (void)myDownloadManagerImage:(UIImage *)image
{
   [imageView setImage:image];
   [self decDownloadCount];
}

- (void)myDownloadManagerAudioFileURL:(NSURL *)url
{
   [self playAudioFileAtURL:url];
   [self decDownloadCount];
}

- (void)myDownloadManagerDidFailWithError:(NSError *)error
{
   NSLog(@"Error: %@", [error localizedDescription]);
}


#pragma mark -
#pragma mark AVAudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag 
{
   [player release], player = nil;
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error 
{
   [player release], player = nil;
}


@end

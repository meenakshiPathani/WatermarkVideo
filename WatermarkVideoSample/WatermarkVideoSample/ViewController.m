//
//  ViewController.m
//  WatermarkVideoSample
//
//  Created by Meenakshi on 05/09/14.
//  Copyright (c) 2014 Mindfire Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface ViewController ()
{
	AVAssetExportSession* _assetExport;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)importButtonAction:(id)sender
{
	UIImage* image = [UIImage imageNamed:@"iosIcon"];
	
	NSString* videoPath = [[NSBundle mainBundle] pathForResource:@"Movie.m4v" ofType:nil];
	NSURL* videoURL = [NSURL fileURLWithPath:videoPath];
	
	[self createWatermark:image video:videoURL];
}

- (IBAction)playMovieButtonAction:(id)sender
{
	NSString* videoName = @"NewWatermarkedVideo.mov";
	
	NSString* exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
	NSURL* exportUrl = [NSURL fileURLWithPath:exportPath];
	
	MPMoviePlayerViewController* videoPlayerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:exportUrl];
	[self presentMoviePlayerViewControllerAnimated:videoPlayerVC];
}

#pragma mark-

- (void) createWatermark:(UIImage*)image video:(NSURL*)videoURL
{
	if (videoURL == nil)
		return;
	
	AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate showLoadingView: YES];
	
	AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
	AVMutableComposition* mixComposition = [AVMutableComposition composition];
	
	AVMutableCompositionTrack* compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
	
	AVAssetTrack* clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
								   ofTrack:clipVideoTrack
									atTime:kCMTimeZero error:nil];
	
	[compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
	
	//  create the layer with the watermark image
	CALayer* aLayer = [CALayer layer];
	aLayer.contents = (id)image.CGImage;
	aLayer.frame = CGRectMake(50, 100, image.size.width, image.size.height);
	aLayer.opacity = 0.9;
	
	//sorts the layer in proper order
	
	AVAssetTrack* videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	CGSize videoSize = [videoTrack naturalSize];
	CALayer *parentLayer = [CALayer layer];
	CALayer *videoLayer = [CALayer layer];
	parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
	videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
	[parentLayer addSublayer:videoLayer];
	[parentLayer addSublayer:aLayer];
	
	// create text Layer
	CATextLayer* titleLayer = [CATextLayer layer];
	titleLayer.backgroundColor = [UIColor clearColor].CGColor;
	titleLayer.string = @"Dummy text";
	titleLayer.font = CFBridgingRetain(@"Helvetica");
	titleLayer.fontSize = 28;
	titleLayer.shadowOpacity = 0.5;
	titleLayer.alignmentMode = kCAAlignmentCenter;
	titleLayer.frame = CGRectMake(0, 50, videoSize.width, videoSize.height / 6);
	[parentLayer addSublayer:titleLayer];
	
	//create the composition and add the instructions to insert the layer:
	
	AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
	videoComp.renderSize = videoSize;
	videoComp.frameDuration = CMTimeMake(1, 30);
	videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
	
	/// instruction
	AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
	
	instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
	AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
	instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
	videoComp.instructions = [NSArray arrayWithObject: instruction];
	
	// export video
	
	_assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
	_assetExport.videoComposition = videoComp;
	
	NSLog (@"created exporter. supportedFileTypes: %@", _assetExport.supportedFileTypes);
	
	NSString* videoName = @"NewWatermarkedVideo.mov";
	
	NSString* exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
	NSURL* exportUrl = [NSURL fileURLWithPath:exportPath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
		[[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
	
	_assetExport.outputFileType = AVFileTypeQuickTimeMovie;
	_assetExport.outputURL = exportUrl;
	_assetExport.shouldOptimizeForNetworkUse = YES;
	
	[_assetExport exportAsynchronouslyWithCompletionHandler:
	 ^(void ) {
		 
		 [appDelegate showLoadingView:NO];

		 //Final code here
		 
		 switch (_assetExport.status)
		 {
			 case AVAssetExportSessionStatusUnknown:
				 NSLog(@"Unknown");
				 break;
			case AVAssetExportSessionStatusWaiting:
				 NSLog(@"Waiting");
				 break;
			 case AVAssetExportSessionStatusExporting:
				 NSLog(@"Exporting");
				 break;
			 case AVAssetExportSessionStatusCompleted:
				 NSLog(@"Created new water mark image");
				 _playButton.hidden = NO;
				 break;
			 case AVAssetExportSessionStatusFailed:
				 NSLog(@"Failed- %@", _assetExport.error);
				 break;
			 case AVAssetExportSessionStatusCancelled:
				 NSLog(@"Cancelled");
				 break;
			}
	 }
	 ];   
}

@end

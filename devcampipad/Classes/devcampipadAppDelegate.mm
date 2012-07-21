//
//  devcampipadAppDelegate.m
//  devcampipad
//
//  Created by Brad Smith on 4/16/10.
//  Copyright Clixtr 2010. All rights reserved.
//

#define USE_COCOS_2D 0

#import <GameKit/GameKit.h>
#import "devcampipadAppDelegate.h"
#import "TouchController.h"
#import "Player.h"
#import "Bullet.h"
#import "TDiPadMenuViewController.h"
#import "cocos2d.h"
#import "World.h"

@implementation devcampipadAppDelegate

@synthesize window, serverPeerID;
@synthesize client;
@synthesize service;
@synthesize bullets;
@synthesize lastTicked;
@synthesize soundPlayer;
@synthesize touchController;
@synthesize connectedPeers;
@synthesize gamePaused;
- (void)dealloc {
	[menuViewContoller release];
	[[CCDirector sharedDirector] release];
	[bullets release];
	[connectedPeers release];
    [window release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];

#if USE_COCOS_2D	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director

	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeDefault];
	
	// Use RGBA_8888 buffers
	// Default is: RGB_565 buffers
	[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
	
	// Create a depth buffer of 16 bits
	// Enable it if you are going to use 3D transitions or 3d objects
	[[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	[[CCDirector sharedDirector] setDepthTest:YES];
	
	// before creating any layer, set the landscape mode
	//[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/30.0];
	[[CCDirector sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];
	
	//[[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];
	[[CCDirector sharedDirector] runWithScene: [World scene]];
	
	
	[window makeKeyAndVisible];
	return YES;
#else
	
	gamePaused = YES;
    //[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
	CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation( .5 * M_PI );

	menuViewContoller = [[TDiPadMenuViewController alloc] initWithNibName:@"TDiPadMenuViewController" bundle:nil];
	menuViewContoller.view.transform = landscapeTransform;
	menuViewContoller.view.center = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
	[menuViewContoller setButtonsVisible:YES animated:YES];
	
	/*leftControllerViewController = [[TDiPadControllerView alloc] initWithNibName:@"TDiPadControllerView" bundle:nil];
	rightControllerViewController = [[TDiPadControllerView alloc] initWithNibName:@"TDiPadControllerView" bundle:nil];
	
	touchController = [[TouchController alloc] init];
	
	[window addSubview:[touchController view]];
	[window sendSubviewToBack:[touchController view]];*/
	[window addSubview:[menuViewContoller view]];
	
	soundPlayer = [[Sound alloc] init];
	[UIApplication sharedApplication].idleTimerDisabled = YES;
/*	loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading0.png"]];
	loadingView.animationDuration = 1;
	[loadingView setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"loading1.png"], 
																		[UIImage imageNamed:@"loading2.png"],
									 [UIImage imageNamed:@"loading3.png"],
									 [UIImage imageNamed:@"loading4.png"],
									 [UIImage imageNamed:@"loading5.png"],
									 [UIImage imageNamed:@"loading6.png"],
									 [UIImage imageNamed:@"loading7.png"],
									 [UIImage imageNamed:@"loading8.png"],
									 [UIImage imageNamed:@"loading9.png"],
									 [UIImage imageNamed:@"loading10.png"],
									 [UIImage imageNamed:@"loading11.png"],
									 [UIImage imageNamed:@"loading12.png"],
									 [UIImage imageNamed:@"loading13.png"],
									 [UIImage imageNamed:@"loading14.png"],
									 [UIImage imageNamed:@"loading15.png"],
									 [UIImage imageNamed:@"loading16.png"],
									 [UIImage imageNamed:@"loading17.png"],
									                               nil]];
	[loadingView startAnimating];
	
	[window addSubview:loadingView];
	loadingView.center = window.center;
*/		
	
	[NSTimer scheduledTimerWithTimeInterval:FRAMERATE target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
	stopButton.hidden = YES;
	
	[self setBullets:[NSMutableArray arrayWithCapacity:100]];
	
	//connectedBoards = [[NSMutableDictionary alloc] init];
	self.connectedPeers = [[NSMutableArray alloc] init];
	
	peerCountLabel.text = @"0";
	
	
	//for (int i = 0; i<2; i++) {
	//	float x = arc4random() % 1024;
	//	float y = arc4random() % 768;
		
	
	
	service = [[GKSession alloc] initWithSessionID:@"wangchung" displayName:nil sessionMode:GKSessionModeServer];
	service.delegate = self;
	service.available = YES; 
	[service setDataReceiveHandler:self withContext:nil];
	newButton.hidden = YES;
	stopButton.hidden = NO;
	
	[self setLastTicked:[NSDate date]];
	
    [window makeKeyAndVisible];
    
    return YES;
#endif
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}


- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


- (void)applicationWillTerminate:(UIApplication *)application {
#if USE_COCOS_2D	
	[[CCDirector sharedDirector] end];

	if (service) {
		[service disconnectFromAllPeers];
		service.available = NO;
		[service setDataReceiveHandler: nil withContext: nil];
		service.delegate = nil;
		[service release];
	} else if (client) {
		[client disconnectFromAllPeers];
		client.available = NO;
		[client setDataReceiveHandler: nil withContext: nil];
		client.delegate = nil;
		[client release];
	}
#endif
}
	

-(void) setLocalControlsHidden:(BOOL)hidden animated:(BOOL)animated {
	if (!localPlayer1ControlsViewController) {
		localPlayer1ControlsViewController = [[LocalTankViewController alloc] initWithNibName:@"LocalTankViewController" bundle:nil];
		localPlayer1ControlsViewController.view.alpha = 0;
		localPlayer1ControlsViewController.view.transform = CGAffineTransformMakeRotation( .5 * M_PI );
		[window addSubview:localPlayer1ControlsViewController.v];
//		[localPlayer1ControlsViewController release];
	}
	if (!localPlayer2ControlsViewController) {
		localPlayer2ControlsViewController = [[LocalTankViewController alloc] initWithNibName:@"LocalTankViewController" bundle:nil];
		localPlayer2ControlsViewController.view.alpha = 0;
		//[window addSubview:localPlayer2ControlsViewController.view];
	//	[localPlayer2ControlsViewController release];
	}
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.33f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	}
	if (!hidden) {
		localPlayer1ControlsViewController.view.alpha = 1;
		localPlayer2ControlsViewController.view.alpha = 1;
	}
	if (hidden) {
		localPlayer1ControlsViewController.view.alpha = 0;
		localPlayer2ControlsViewController.view.alpha = 0;
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

-(void) timerFired {
	if (gamePaused) {
		return;
	}
	
	BOOL hasPlayersConnected = NO;
	
	Bullet *bullet;
	Player *player;
	
	NSTimeInterval dt = [[NSDate date] timeIntervalSinceDate:lastTicked];
	
	for(player in self.connectedPeers) {
		//player = [connectedPeers valueForKey:aKey];
		if ([[player peerID] isEqualToString:@"dbgPlayer"]) {
			//
			[self player:player didFireBullet:@"1"];
		} else {
			[touchController setLastTouchedPoint:[player center]];
		}
		
		hasPlayersConnected = YES;
		[player update:dt pointOfInterest:[touchController lastTouchedPoint]];
	}
	
	for (int i = 0; i < [bullets count]; i++) {
		bullet = [bullets objectAtIndex:i];
		[bullet update:dt + (FRAMERATE * 4)];
		for(player in self.connectedPeers) {
			//player = [connectedPeers valueForKey:aKey];
			if (player.takingDamage || bullet.exploding) {
			} else {
				if (![[bullet player] isEqual:player]) {
					BOOL collided = CGRectContainsPoint([player frame], [bullet center]);
					if (collided) {
						[bullet explode];
						if ([player takeDamage]) {
							[soundPlayer playHitSound];
							[service sendData:[@"playerDidTakeDamage" dataUsingEncoding:NSUTF8StringEncoding] toPeers:[NSArray arrayWithObject:[player peerID]] withDataMode:GKSendDataUnreliable error:nil];
						}
					}
				}
			}
		}	
	}
	
	for (int i = 0; i < [bullets count]; i++) {
		bullet = [bullets objectAtIndex:i];
		if ([bullet isHidden]) {
			[bullet removeFromSuperview];
			[bullets removeObjectAtIndex:i];
		}
	}
	
	if (hasPlayersConnected) {
		[self removeLoadingView];
		[window addSubview:leftControllerViewController.view];
		[soundPlayer playSoundtrack];
	}
	
	[self setLastTicked:[NSDate date]];
}


- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	[session acceptConnectionFromPeer:peerID error:nil];	
}


- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	switch (state) {
		case GKPeerStateAvailable: {
			break;
		}
		case GKPeerStateUnavailable: {
			break;
		}
		case GKPeerStateConnected: {
			[self requestConnectingClientIdentity:peerID];
			break;
		}
		case GKPeerStateDisconnected: {
			//Player *player = [connectedPeers objectForKey:peerID];
			//if (player) {
			//	[player removeFromSuperview];
			//	[connectedPeers removeObjectForKey:peerID];
			//}
			break;
		}
	}
}


- (void) updateLabels {
	peerCountLabel.text = [NSString stringWithFormat:@"%i",connectedPeers.count];
}


-(void) receiveData:(NSData *)data fromPeer:(NSString *)peerId inSession:(GKSession *)_session context:(id)context {
	Player *player; // = [connectedPeers objectForKey:peerId];
	for (player in self.connectedPeers) {
		if ([[player peerID] isEqualToString:peerId]) {
			break;
		}
	}
	
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"message: %@", message);
	
	NSMutableArray *argv = [NSMutableArray arrayWithArray:[message componentsSeparatedByString:@"|"]];
	NSString *command = [argv objectAtIndex:0];
	[argv removeObjectAtIndex:0];
	NSLog(@"command: |%@|",command);
	
	if ([command isEqualToString:@"confirmiPad"]) {
		[self confirmiPad:peerId];    
	} else if ([command isEqualToString:@"confirmiPhone"]) {
		if ([argv count] == 1) {
			[self confirmiPhone:peerId withTankID:[argv objectAtIndex:0]];
		}
		if ([argv count] == 2) {
			[self confirmiPhone:peerId withTankID:[argv objectAtIndex:0] withPlayerName:[argv objectAtIndex:1]];
		}
		
	} else if ([command isEqualToString:@"spawnPortal"]) {
		[self spawnPortal:[argv componentsJoinedByString:@"|"]];
	} else if ([command isEqualToString:@"spawnPlayer"]) {
		[self spawnPlayer:[argv componentsJoinedByString:@"|"]];
	} else if ([command isEqualToString:@"didClickFire"]) {
		[self player:player didFireBullet:[argv objectAtIndex:0]];
	} else if ([command isEqualToString:@"sliderDidChange"]) {
		[player sliderDidChange:[argv objectAtIndex:0]];
	} else if ([command isEqualToString:@"sendID"]) {
		[self sendID:[argv objectAtIndex:0]];
	} else if ([command isEqualToString:@"forward"]) {
		NSString *forwardPeer = [argv objectAtIndex:0];
		[argv removeObjectAtIndex:0];
		NSData *forwardData = [[argv componentsJoinedByString:@"|"] dataUsingEncoding:NSUTF8StringEncoding];
		[self receiveData:forwardData fromPeer:forwardPeer inSession:_session context:nil];
	} else {
		NSLog(@"Warning: could not dispatch message");
	}

}

-(void)player:(Player *)player didFireBullet:(NSString *)bulletType {
	BulletEmitPattern emitter = [player fireBullet];
	Bullet *bullet;
	
	if (emitter == kNone) {
		//
	} else {
		if (emitter == kSingle) {
			bullet = [[Bullet alloc] initWithImage:[UIImage imageNamed:@"tank_bullet.png"] AndPlayer:player];
			[bullets addObject:bullet];
			[window addSubview:bullet];
			[bullet release];	
		} else if (emitter == kTriple) {
			for (int i = -1; i<2; i++) {
				bullet = [[Bullet alloc] initWithImage:[UIImage imageNamed:@"tank_bullet.png"] AndPlayer:player];
				[bullet setRot:[player rot] + (i * 0.5)];
				[bullets addObject:bullet];
				[window addSubview:bullet];
				[bullet release];				
			}
		}
	}
}


-(void)sendID:(NSString *)backToServerPeer {
	NSData *data = [@"confirmiPad" dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error;
	if (![client sendData:data toPeers:[NSArray arrayWithObject:backToServerPeer] withDataMode:GKSendDataUnreliable error:&error]) {
		NSLog(@"ERROR: %@", [error userInfo]);
	}
}


-(void) confirmiPad:(NSString *) peerId {
}


-(void) removeLoadingView {
	if (loadingView) {
		[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:.66];
		loadingView.alpha = 0;
		[UIView commitAnimations];
		[loadingView removeFromSuperview];
		loadingView = nil;
	}
}


-(void) confirmiPhone:(NSString *)peerID withTankID:(NSString *)tankID {
	[self spawnPlayer:[NSString stringWithFormat:@"%@|%@", peerID, tankID]];
}


-(IBAction) joinButtonPressed:(id)sender {
	[self spawnPlayer:[NSString stringWithFormat:@"dbgPlayer|1"]];
}


- (void) spawnPortal:(NSString *)args {
}


- (void) spawnPlayer:(NSString *)args {
	args = [args stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *argv = [args componentsSeparatedByString:@"|"];
	Player *p = [[Player alloc] initWithID:[argv objectAtIndex:0]];
	[p setTank:[argv objectAtIndex:1]];
	//[connectedPeers setObject:p forKey:[argv objectAtIndex:0]];
	[self.connectedPeers addObject:p];
	[window addSubview:p];
	[p release];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAYER_JOINED"  object:nil];
}

-(void) confirmiPhone:(NSString *)peerID withTankID:(NSString *)tankID withPlayerName:(NSString *)name {
	NSString *legacy = [NSString stringWithFormat:@"%@|%@", peerID, tankID];
	NSString *args = [legacy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *argv = [args componentsSeparatedByString:@"|"];
	Player *p = [[Player alloc] initWithID:[argv objectAtIndex:0]];
	[p setTank:[argv objectAtIndex:1]];
	[p setPlayerName:name];
	//[connectedPeers setObject:p forKey:[argv objectAtIndex:0]];
	[self.connectedPeers addObject:p];
	[window addSubview:p];
	[p release];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAYER_JOINED"  object:nil];
}



-(void) requestConnectingClientIdentity:(NSString *)thePeerId {
	NSString *string = [NSString stringWithFormat:@"sendID|%@", service.peerID];
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error;
	if (![service sendData:data toPeers:[NSArray arrayWithObject:thePeerId] withDataMode:GKSendDataUnreliable error:&error]) {
		NSLog(@"ERROR: %@",error);
	}	
}





@end
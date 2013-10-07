//
//  ViewController.m
//  iPad Project
//
//  Created by Yuki Kuromaru on 9/15/13.
//  Copyright (c) 2013 Yuki Kuromaru. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *ballView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ballXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ballYConstraint;
@property (assign, nonatomic) CGPoint velocity;
@property (assign, nonatomic) CGFloat gravity;
@property (weak, nonatomic) IBOutlet UILabel *accelXLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelYLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelZLabel;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end

@implementation ViewController

#define DAMPENING_FACTOR 0.9;

- (void)tick:(CADisplayLink *)sender
{
    CGPoint vel = self.velocity;
    if (CGRectGetMaxX(self.ballView.frame) >= CGRectGetMaxX(self.view.bounds)) {
        vel.x = -ABS(vel.x);
    } else if (CGRectGetMinX(self.ballView.frame) <= CGRectGetMinX(self.view.bounds)) {
        vel.x = ABS(vel.x);
    }
    if (CGRectGetMaxY(self.ballView.frame) >= CGRectGetMaxY(self.view.bounds)) {
        vel.y = -ABS(vel.y);
    } else if (CGRectGetMinY(self.ballView.frame) <= CGRectGetMinY(self.view.bounds)) {
        vel.y = ABS(vel.y);
    }
    
    if (self.velocity.x != vel.x) {
        vel.x *= DAMPENING_FACTOR;
    }
    if (self.velocity.y != vel.y) {
        vel.y *= DAMPENING_FACTOR;
    }

    self.velocity = vel;
    [self updateVelocityWithAcceleration];
    
    CGPoint pos = CGPointMake(self.ballXConstraint.constant,
                              self.ballYConstraint.constant);
    CGFloat maxPosX = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.ballView.bounds);
    pos.x = MIN(maxPosX, MAX(0, pos.x + self.velocity.x));

    self.ballXConstraint.constant = pos.x;
    
    CGFloat maxPosY = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.ballView.bounds);
    pos.y = MIN(maxPosY, pos.y + self.velocity.y);
    
    self.ballYConstraint.constant = pos.y;
}
-(void)updateVelocityWithAcceleration
{
    CMAccelerometerData *accelerometerData = self.motionManager.accelerometerData;
    self.accelXLabel.text = [NSString stringWithFormat:@"acceleration x: %.2f",accelerometerData.acceleration.x];
    self.accelYLabel.text = [NSString stringWithFormat:@"acceleration y: %.2f",accelerometerData.acceleration.y];
    self.accelZLabel.text = [NSString stringWithFormat:@"acceleration z: %.2f",accelerometerData.acceleration.z];
    
    CGPoint vel = self.velocity;
    vel.x += accelerometerData.acceleration.x * self.gravity;
    vel.y += -accelerometerData.acceleration.y * self.gravity;
    self.velocity = vel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.velocity = CGPointMake(10.0, 10.0);
    self.gravity = 5.0;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self setupMotionManager];
}

- (void)setupMotionManager
{
    self.motionManager = [[CMMotionManager alloc] init];
    
    if ([self.motionManager isAccelerometerAvailable]) {
        self.motionManager.accelerometerUpdateInterval = 1.0/60.0;
        [self.motionManager startAccelerometerUpdates];
    } else {
        NSLog(@"Accelerometer is not active.");
    }
}
@end


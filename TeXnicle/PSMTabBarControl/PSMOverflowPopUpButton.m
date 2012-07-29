//
//  PSMOverflowPopUpButton.m
//  PSMTabBarControl
//
//  Created by John Pannell on 11/4/05.
//  Copyright 2005 Positive Spin Media. All rights reserved.
//

#import "PSMOverflowPopUpButton.h"
#import "PSMTabBarControl.h"

#define TIMER_INTERVAL 1.0 / 15.0
#define ANIMATION_STEP 0.033f

@implementation PSMOverflowPopUpButton

- (id)initWithFrame:(NSRect)frameRect pullsDown:(BOOL)flag
{
  self = [super initWithFrame:frameRect pullsDown:YES];
    if (self) {
        [self setBezelStyle:NSRegularSquareBezelStyle];
        [self setBordered:NO];
        [self setTitle:@""];
        [self setPreferredEdge:NSMaxXEdge];
        _PSMTabBarOverflowPopUpImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"overflowImage"]];
		_PSMTabBarOverflowDownPopUpImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"overflowImagePressed"]];
		_animatingAlternateImage = NO;
    }
    return self;
}


- (void)drawRect:(NSRect)rect
{
    if(_PSMTabBarOverflowPopUpImage == nil){
        [super drawRect:rect];
        return;
    }
	
    NSImage *image = (_down) ? _PSMTabBarOverflowDownPopUpImage : _PSMTabBarOverflowPopUpImage;
	NSSize imageSize = [image size];
	NSRect bounds = [self bounds];
	
	NSPoint drawPoint = NSMakePoint(NSMidX(bounds) - (imageSize.width * 0.5f), NSMidY(bounds) - (imageSize.height * 0.5f));
	
  [image drawInRect:NSMakeRect(drawPoint.x, drawPoint.y, imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	
	if (_animatingAlternateImage) {
		NSImage *alternateImage = [self alternateImage];
		NSSize altImageSize = [alternateImage size];
		drawPoint = NSMakePoint(NSMidX(bounds) - (altImageSize.width * 0.5f), NSMidY(bounds) - (altImageSize.height * 0.5f));
		
    [alternateImage drawInRect:NSMakeRect(drawPoint.x, drawPoint.y, altImageSize.width, altImageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
}

- (void)mouseDown:(NSEvent *)event
{
	_down = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NSMenuDidEndTrackingNotification object:[self menu]];
	[self setNeedsDisplay:YES];
	[super mouseDown:event];
}

- (void)setHidden:(BOOL)value
{
	if ([self isHidden] != value) {
		if (value) {
			// Stop any animating alternate image if we hide
      if (_animationTimer) {
        [_animationTimer invalidate];
        _animationTimer = nil;
      }
		} else if (_animatingAlternateImage) {
			// Restart any animating alternate image if we unhide
			_animationValue = ANIMATION_STEP;
			_animationTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(animateStep:) userInfo:nil repeats:YES];
			[[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSEventTrackingRunLoopMode];
		}
	}
	
	[super setHidden:value];
}

- (void)notificationReceived:(NSNotification *)notification
{
	_down = NO;
	[self setNeedsDisplay:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setAnimatingAlternateImage:(BOOL)flag
{
	if (_animatingAlternateImage != flag) {
		_animatingAlternateImage = flag;
		
		if (![self isHidden]) {
			if (flag) {
				_animationValue = ANIMATION_STEP;
				_animationTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(animateStep:) userInfo:nil repeats:YES];
				[[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSEventTrackingRunLoopMode];

			} else {
        if (_animationTimer) {
          [_animationTimer invalidate];
          _animationTimer = nil;
        }
			}

			[self setNeedsDisplay:YES];
		}
	}
}

- (BOOL)animatingAlternateImage;
{
	return _animatingAlternateImage;
}

- (void)animateStep:(NSTimer *)timer
{
	_animationValue += ANIMATION_STEP;
	
	if (_animationValue >= 1) {
		_animationValue = ANIMATION_STEP;
	}
	
	[self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    if ([aCoder allowsKeyedCoding]) {
        [aCoder encodeObject:_PSMTabBarOverflowPopUpImage forKey:@"PSMTabBarOverflowPopUpImage"];
        [aCoder encodeObject:_PSMTabBarOverflowDownPopUpImage forKey:@"PSMTabBarOverflowDownPopUpImage"];
		[aCoder encodeBool:_animatingAlternateImage forKey:@"PSMTabBarOverflowAnimatingAlternateImage"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ( (self = [super initWithCoder:aDecoder]) ) {
        if ([aDecoder allowsKeyedCoding]) {
            _PSMTabBarOverflowPopUpImage = [aDecoder decodeObjectForKey:@"PSMTabBarOverflowPopUpImage"];
            _PSMTabBarOverflowDownPopUpImage = [aDecoder decodeObjectForKey:@"PSMTabBarOverflowDownPopUpImage"];
			[self setAnimatingAlternateImage:[aDecoder decodeBoolForKey:@"PSMTabBarOverflowAnimatingAlternateImage"]];
        }
    }
    return self;
}

@end

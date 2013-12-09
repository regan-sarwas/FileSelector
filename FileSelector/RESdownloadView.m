//
//  RESdownloadView.m
//  DrawingTest
//
//  Created by Regan Sarwas on 11/26/13.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import "RESdownloadView.h"

@implementation RESdownloadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _percentComplete = 0.75;
    }
    return self;
}

- (void)setPercentComplete:(float)percentComplete
{
    if (fabs(percentComplete - _percentComplete) < 0.02)
        return;
    if (percentComplete < 0.0) {
        _percentComplete = 0.0;
    } else if (1.0 < percentComplete) {
        _percentComplete = 1.0;
    } else {
        _percentComplete = percentComplete;
    }
    [self setNeedsDisplay];
}

- (void)setDownloading:(BOOL)downloading
{
    if (downloading != _downloading) {
        _downloading = downloading;
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect)rect
{
    if (self.downloading) {
        //[self drawRect1:rect]; //scaled forany size view
        [self drawRect2:rect]; //optimized for 30x30
    }
}

- (void)drawRect1:(CGRect)rect
{
    // Get the current graphics context
    // (ie. where the drawing should appear)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Set color
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0); //rgba (0..1)
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0); //rgba (0..1)

    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat min = width < height ? width : height;
    CGContextTranslateCTM(context, width/2.0, height/2.0);
    CGContextScaleCTM(context, min/2.0, -min/2.0);
    //We now have a 2x2 view from LL = -1,-1, UR = 1,1
    
    //Inner Square
    CGContextMoveToPoint(context, -0.3,-0.3);
    CGContextAddLineToPoint(context, 0.3, -0.3);
    CGContextAddLineToPoint(context, 0.3, 0.3);
    CGContextAddLineToPoint(context, -0.3, 0.3);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    //Small outer circle
    CGContextSetLineWidth(context, .05);
    CGContextBeginPath(context);
    CGContextAddArc(context, 0, 0, 0.9, 0, 2*M_PI, YES); //x,y,r,start angle,end,CW
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    
    //Small outer circle
    CGContextSetLineWidth(context, 0.24);
    CGContextBeginPath(context);
    CGContextAddArc(context, 0, 0, .78, M_PI_2, M_PI_2 - (2*M_PI)*self.percentComplete, YES); //x,y,r,start angle,end,CW
    //CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    
}

- (void)drawRect2:(CGRect)rect
{
    // Get the current graphics context
    // (ie. where the drawing should appear)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Set color
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0); //rgba (0..1)
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0); //rgba (0..1)
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGContextTranslateCTM(context, width/2.0, height/2.0);
    
    //Inner Square
    CGContextMoveToPoint(context, -4,-4);
    CGContextAddLineToPoint(context, 4, -4);
    CGContextAddLineToPoint(context, 4, 4);
    CGContextAddLineToPoint(context, -4, 4);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    //Small outer circle
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);
    CGContextAddArc(context, 0, 0, 14, 0, 2*M_PI, YES); //x,y,r,start angle,end,CW
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    
    //Small outer circle
    CGContextSetLineWidth(context, 3);
    CGContextBeginPath(context);
    CGContextAddArc(context, 0, 0, 12, -M_PI_2, -M_PI_2 + (2*M_PI)*self.percentComplete, NO); //x,y,r,start angle,end,CW
    CGContextDrawPath(context, kCGPathStroke);
    
}


@end

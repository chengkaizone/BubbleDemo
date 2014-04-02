//
//  CustomTouchView.m
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import "BubbleView.h"
#import "TextBubbleView.h"

#pragma mark - BubbleView

@interface BubbleView () <BubblePointerViewProtocol, TextBubbleViewProtocol>

@property (nonatomic, strong) BubblePointerView *bubblePointerView;
@property (nonatomic) CGPoint targetPoint;
@property (nonatomic) CGPoint textBubbleViewCenterPoint;

@end

@implementation BubbleView

#pragma mark - TextBubbleViewProtocol

- (void)textBubbleViewDidmoved:(TextBubbleView *)textBubbleView
{
    self.textBubbleViewCenterPoint = CGPointMake(CGRectGetMidX(textBubbleView.frame), CGRectGetMidY(textBubbleView.frame));
    [self setNeedsDisplay];
}

#pragma mark - BubblePointerViewProtocol

- (void)bubblePointerViewDidMoved:(BubblePointerView *)bubblePointerView
{
    self.targetPoint = CGPointMake(CGRectGetMidX(bubblePointerView.frame), CGRectGetMidY(bubblePointerView.frame));
    [self setNeedsDisplay];
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // TODO:init时添加subview 有时会失效
//        // BubblePointerView
//        BubblePointerView *bubblePointerView = [[BubblePointerView alloc] init];
//        bubblePointerView.bounds = CGRectMake(0, 0, 50, 50);
//        bubblePointerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)+100);
//        bubblePointerView.delegate = self;
//        [self addSubview:bubblePointerView];
//        self.bubblePointerView = bubblePointerView;
//        
//        // TextBubbleView
//        TextBubbleView *textBubbleView = [[TextBubbleView alloc] init];
//        textBubbleView.bounds = CGRectMake(0, 0, 80, 50);
//        textBubbleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//        textBubbleView.backgroundColor = [UIColor clearColor];
//        self.targetPoint = self.bubblePointerView.center;
//        [self addSubview:textBubbleView];
//        self.textBubbleView = textBubbleView;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    // BubblePointerView
    BubblePointerView *bubblePointerView = [[BubblePointerView alloc] init];
    bubblePointerView.bounds = CGRectMake(0, 0, 50, 50);
    bubblePointerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)+100);
    bubblePointerView.backgroundColor = [UIColor clearColor];
    bubblePointerView.delegate = self;
    [self addSubview:bubblePointerView];
    self.bubblePointerView = bubblePointerView;
    
    // TextBubbleView
    TextBubbleView *textBubbleView = [[TextBubbleView alloc] init];
    textBubbleView.bounds = CGRectMake(0, 0, 85, 60);
    textBubbleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    textBubbleView.backgroundColor = [UIColor clearColor];
    textBubbleView.maxWidth = 100;
    textBubbleView.delegate = self;
    [self addSubview:textBubbleView];
    self.textBubbleView = textBubbleView;

    self.textBubbleViewCenterPoint = self.textBubbleView.center;
    self.targetPoint = self.bubblePointerView.center;
}

#pragma mark - override

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *tmpView = [super hitTest:point withEvent:event];
    if (tmpView == self) {
        return nil;
    }
    return tmpView;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float x_scale = self.textBubbleView.x_scale;
    float y_scale = self.textBubbleView.y_scale;
    float textBubbleViewFrameX = self.textBubbleView.frame.origin.x;
    float textBubbleViewFrameY = self.textBubbleView.frame.origin.y;
//    float textBubbleViewFrameWidth = self.textBubbleView.frame.size.width;
//    float textBubbleViewFrameHeight = self.textBubbleView.frame.size.height;
    float x1 = self.targetPoint.x;
    float y1 = self.targetPoint.y;
    float x2 = self.textBubbleViewCenterPoint.x;
    float y2 = self.textBubbleViewCenterPoint.y;
    float k, b;
    if ((x2-x1)==0) {
        k=0;
        b=x1;
    } else {
        k = (y2-y1)/(x2-x1);
        b = y1-(y2-y1)*x1/(x2-x1);
    }
    float dist = sqrtf(powf((x1-x2), 2) + powf((y1-y2), 2));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,0,0,0,1.0); // 画笔线的颜色
    CGContextSetLineWidth(context, 1.0); // 线的宽度
    UIColor *aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor); // 填充颜色
    
    // border background
    switch (self.textBubbleView.bubbleType) {
        case BubbleTypeEllipse:
        {
            CGContextAddEllipseInRect(context, self.textBubbleView.frame); // 椭圆
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
            case BubbleTypeShout:
        {
            NSArray *shoutData = [TextBubbleView shout_data];
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, [shoutData[0][0] floatValue]*x_scale+textBubbleViewFrameX, [shoutData[0][1] floatValue]*y_scale+textBubbleViewFrameY); // 移动
            for (NSArray *points in shoutData) {
                for (int i = 0; i < 3; i+=2) {
                    CGContextAddLineToPoint(context, [points[i] floatValue]*x_scale+textBubbleViewFrameX, [points[i+1] floatValue]*y_scale+textBubbleViewFrameY);
                }
            }
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
        default:
            break;
    }
    // triangle and cycle
    switch (self.textBubbleView.bubbleType) {
        case BubbleTypeEllipse:
        case BubbleTypeShout:
        {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, x1, y1);
            CGContextAddLineToPoint(context, x2+15, y2);
            CGContextAddLineToPoint(context, x2-15, y2);
            CGContextAddLineToPoint(context, x1, y1);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
            break;
        case BubbleTypeThought:
        {
            float local12 = MAX(3, floorf(dist/28));
            float local13 = dist/local12;
            float local14 = 7/local12;
            float local16 = 0;
            while (local16 < local12) {
                float x, y;
                if (x2<x1) {
                    x = (dist - (local16 * local13)) *cos(atan(k))+x2;
                    y = k*x+b;
                } else if (x2==x1) {
                    x = x2;
                    y = x2>0?local13*local16:-local13*local16;
                    y = y1-y;
                } else {
                    x = -(dist - (local16 * local13)) *cos(atan(k))+x2;
                    y = k*x+b;
                }
                
                CGContextAddArc(context, x, y, (3 + (local16 * local14)), 0, 2*M_PI, 0);
                CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
                local16++;
            }
        }
        default:
            break;
    }
    
//    // 小一个尺寸的前景bubble 目的是挡住三角和圆圈交界处
//    CGContextSetRGBStrokeColor(context,1,1,1,1.0); // 画笔线的颜色
//    float x_scale = self.textBubbleView.x_scale;
//    float y_scale = self.textBubbleView.y_scale;
//    float textBubbleViewFrameX = self.textBubbleView.frame.origin.x;
//    float textBubbleViewFrameY = self.textBubbleView.frame.origin.y;
//    float textBubbleViewFrameWidth = self.textBubbleView.frame.size.width;
//    float textBubbleViewFrameHeight = self.textBubbleView.frame.size.height;
//    switch (self.textBubbleView.bubbleType) {
//        case BubbleTypeEllipse:{
//            CGFloat rectPadding = self.textBubbleView.rectPadding;
//            CGContextAddEllipseInRect(context, CGRectMake(textBubbleViewFrameX+rectPadding+1, textBubbleViewFrameY+rectPadding+1, textBubbleViewFrameWidth-(rectPadding+1)*2, textBubbleViewFrameHeight-(rectPadding+1)*2)); // 椭圆
//            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
//        }
//            break;
//        case BubbleTypeShout:{
//            NSArray *shoutData = [TextBubbleView shout_data];
//            CGContextBeginPath(context);
//            CGContextMoveToPoint(context, ([shoutData[0][0] floatValue]+textBubbleViewFrameX-1)*x_scale, ([shoutData[0][1] floatValue]+textBubbleViewFrameY-1)*y_scale); // 移动
//            for (NSArray *points in shoutData) {
//                for (int i = 0; i < 3; i+=2) {
//                    CGContextAddLineToPoint(context, ([points[i] floatValue]+textBubbleViewFrameX-1)*x_scale, ([points[i+1] floatValue]+textBubbleViewFrameY-1)*y_scale);
//                }
//            }
//            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
//        }
//            break;
//        case BubbleTypeThought:{
//            NSArray *thoughtData = [TextBubbleView thought_data];
//            CGContextBeginPath(context);
//            CGContextMoveToPoint(context, ([thoughtData[0][0] floatValue]-textBubbleViewFrameX-1)*x_scale, ([thoughtData[0][1] floatValue]-textBubbleViewFrameY-1)*y_scale); // 移动
//            for (NSArray *points in thoughtData) {
//                CGContextAddCurveToPoint(context,
//                                         ([points[0] floatValue]+textBubbleViewFrameX)*x_scale,
//                                         ([points[1] floatValue]+textBubbleViewFrameY)*y_scale,
//                                         ([points[2] floatValue]+textBubbleViewFrameX)*x_scale,
//                                         ([points[3] floatValue]+textBubbleViewFrameY)*y_scale,
//                                         ([points[4] floatValue]+textBubbleViewFrameX)*x_scale,
//                                         ([points[5] floatValue]+textBubbleViewFrameY)*y_scale);
//            }
//            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
//        }
//            break;
//        default:
//            break;
//    }
    
}

@end

#pragma mark - BubblePointerView

@interface BubblePointerView ()

@property (nonatomic) float oldX, oldY;

@end

@implementation BubblePointerView

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,0,0,0,1.0); // 画笔线的颜色
    CGContextSetLineWidth(context, 1.0); // 线的宽度
    UIColor *aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor); // 填充颜色
    CGContextAddArc(context, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 15, 0, 2 * M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    self.oldX = touchLocation.x;
    self.oldY = touchLocation.y;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    float deltaX = [[touches anyObject]locationInView:self].x - self.oldX;
    float deltaY = [[touches anyObject]locationInView:self].y - self.oldY;
    self.transform = CGAffineTransformTranslate(self.transform, deltaX, deltaY);
    if ([self.delegate respondsToSelector:@selector(bubblePointerViewDidMoved:)]) {
        [self.delegate bubblePointerViewDidMoved:self];
    }
}

@end

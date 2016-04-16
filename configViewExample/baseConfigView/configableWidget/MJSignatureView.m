//
//  MJSignatureView.m
//  MJNSFA
//
//  Created by weida on 16/2/25.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJSignatureView.h"
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import "UIView+TTCategory.h"


#define             STROKE_WIDTH_MIN 0.004 // Stroke width determined by touch velocity
#define             STROKE_WIDTH_MAX 0.030
#define       STROKE_WIDTH_SMOOTHING 0.5   // Low pass filter alpha

#define           VELOCITY_CLAMP_MIN 20
#define           VELOCITY_CLAMP_MAX 5000

#define QUADRATIC_DISTANCE_TOLERANCE 3.0   // Minimum distance to make a curve

#define             MAXIMUM_VERTECES 100000


#define kTextColor              ([UIColor colorWithRed:0.118 green:0.584 blue:0.729 alpha:1])
#define kSizeSignImage          (CGSizeMake(100, 75))
#define kTagSignView            (111)
#define kAnnimateTime           (0.5)


@interface WSSignatureView : GLKView

@property (assign, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) BOOL hasSignature;
@property (strong, nonatomic) UIImage *signatureImage;

- (void)erase;

@end





static GLKVector3 StrokeColor = { 0, 0, 0 };
static float clearColor[4] = { 1, 1, 1, 0 };

// Vertex structure containing 3D point and color
struct PPSSignaturePoint
{
    GLKVector3		vertex;
    GLKVector3		color;
};
typedef struct PPSSignaturePoint PPSSignaturePoint;


// Maximum verteces in signature
static const int maxLength = MAXIMUM_VERTECES;


// Append vertex to array buffer
static inline void addVertex(uint *length, PPSSignaturePoint v) {
    if ((*length) >= maxLength) {
        return;
    }
    
    GLvoid *data = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(data + sizeof(PPSSignaturePoint) * (*length), &v, sizeof(PPSSignaturePoint));
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    (*length)++;
}

static inline CGPoint QuadraticPointInCurve(CGPoint start, CGPoint end, CGPoint controlPoint, float percent) {
    double a = pow((1.0 - percent), 2.0);
    double b = 2.0 * percent * (1.0 - percent);
    double c = pow(percent, 2.0);
    
    return (CGPoint) {
        a * start.x + b * controlPoint.x + c * end.x,
        a * start.y + b * controlPoint.y + c * end.y
    };
}

static float generateRandom(float from, float to) { return random() % 10000 / 10000.0 * (to - from) + from; }
static float clamp(float min, float max, float value) { return fmaxf(min, fminf(max, value)); }


// Find perpendicular vector from two other vectors to compute triangle strip around line
static GLKVector3 perpendicular(PPSSignaturePoint p1, PPSSignaturePoint p2) {
    GLKVector3 ret;
    ret.x = p2.vertex.y - p1.vertex.y;
    ret.y = -1 * (p2.vertex.x - p1.vertex.x);
    ret.z = 0;
    return ret;
}

static PPSSignaturePoint ViewPointToGL(CGPoint viewPoint, CGRect bounds, GLKVector3 color) {
    
    return (PPSSignaturePoint) {
        {
            (viewPoint.x / bounds.size.width * 2.0 - 1),
            ((viewPoint.y / bounds.size.height) * 2.0 - 1) * -1,
            0
        },
        color
    };
}


@interface WSSignatureView () {
    // OpenGL state
    EAGLContext *context;
    GLKBaseEffect *effect;
    
    GLuint vertexArray;
    GLuint vertexBuffer;
    GLuint dotsArray;
    GLuint dotsBuffer;
    
    
    // Array of verteces, with current length
    PPSSignaturePoint SignatureVertexData[maxLength];
    uint length;
    
    PPSSignaturePoint SignatureDotsData[maxLength];
    uint dotsLength;
    
    
    // Width of line at current and previous vertex
    float penThickness;
    float previousThickness;
    
    
    // Previous points for quadratic bezier computations
    CGPoint previousPoint;
    CGPoint previousMidPoint;
    PPSSignaturePoint previousVertex;
    PPSSignaturePoint currentVelocity;
}

@end


@implementation WSSignatureView


- (void)commonInit {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (context) {
        time(NULL);
        
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = NO;
        
        self.context = context;
        self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        self.enableSetNeedsDisplay = YES;
        
        // Turn on antialiasing
        self.drawableMultisample = GLKViewDrawableMultisample4X;
        
        [self setupGL];
        
        // Capture touches
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
        pan.cancelsTouchesInView = YES;
        [self addGestureRecognizer:pan];
        
        // For dotting your i's
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:tap];
        
        // Erase with long press
        UILongPressGestureRecognizer *longer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longer.cancelsTouchesInView = YES;
        [self addGestureRecognizer:longer];
        
    } else [NSException raise:@"NSOpenGLES2ContextException" format:@"Failed to create OpenGL ES2 context"];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) [self commonInit];
    return self;
}


- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)ctx
{
    if (self = [super initWithFrame:frame context:ctx]) [self commonInit];
    return self;
}


- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    context = nil;
}


- (void)drawRect:(CGRect)rect
{
    glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [effect prepareToDraw];
    
    // Drawing of signature lines
    if (length > 2) {
        glBindVertexArrayOES(vertexArray);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, length);
    }
    
    if (dotsLength > 0) {
        glBindVertexArrayOES(dotsArray);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, dotsLength);
    }
}


- (void)erase {
    length = 0;
    dotsLength = 0;
    self.hasSignature = NO;
    
    [self setNeedsDisplay];
}



- (UIImage *)signatureImage
{
    if (!self.hasSignature)
        return nil;
    
    //    self.hidden = YES;
    //
    //    self.strokeColor = [UIColor whiteColor];
    //    [self setNeedsDisplay];
    UIImage *screenshot = [self snapshot];
    //    self.strokeColor = nil;
    //
    //    self.hidden = NO;
    return screenshot;
}


#pragma mark - Gesture Recognizers


- (void)tap:(UITapGestureRecognizer *)t {
    CGPoint l = [t locationInView:self];
    
    if (t.state == UIGestureRecognizerStateRecognized) {
        glBindBuffer(GL_ARRAY_BUFFER, dotsBuffer);
        
        PPSSignaturePoint touchPoint = ViewPointToGL(l, self.bounds, (GLKVector3){1, 1, 1});
        addVertex(&dotsLength, touchPoint);
        
        PPSSignaturePoint centerPoint = touchPoint;
        centerPoint.color = StrokeColor;
        addVertex(&dotsLength, centerPoint);
        
        static int segments = 20;
        GLKVector2 radius = (GLKVector2){
            clamp(0.00001, 0.02, penThickness * generateRandom(0.5, 1.5)),
            clamp(0.00001, 0.02, penThickness * generateRandom(0.5, 1.5))
        };
        GLKVector2 velocityRadius = radius;
        float angle = 0;
        
        for (int i = 0; i <= segments; i++) {
            
            PPSSignaturePoint p = centerPoint;
            p.vertex.x += velocityRadius.x * cosf(angle);
            p.vertex.y += velocityRadius.y * sinf(angle);
            
            addVertex(&dotsLength, p);
            addVertex(&dotsLength, centerPoint);
            
            angle += M_PI * 2.0 / segments;
        }
        
        addVertex(&dotsLength, touchPoint);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    
    [self setNeedsDisplay];
}


- (void)longPress:(UILongPressGestureRecognizer *)lp {
    [self erase];
}

- (void)pan:(UIPanGestureRecognizer *)p {
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    CGPoint v = [p velocityInView:self];
    CGPoint l = [p locationInView:self];
    
    currentVelocity = ViewPointToGL(v, self.bounds, (GLKVector3){0,0,0});
    float distance = 0.;
    if (previousPoint.x > 0) {
        distance = sqrtf((l.x - previousPoint.x) * (l.x - previousPoint.x) + (l.y - previousPoint.y) * (l.y - previousPoint.y));
    }
    
    float velocityMagnitude = sqrtf(v.x*v.x + v.y*v.y);
    float clampedVelocityMagnitude = clamp(VELOCITY_CLAMP_MIN, VELOCITY_CLAMP_MAX, velocityMagnitude);
    float normalizedVelocity = (clampedVelocityMagnitude - VELOCITY_CLAMP_MIN) / (VELOCITY_CLAMP_MAX - VELOCITY_CLAMP_MIN);
    
    float lowPassFilterAlpha = STROKE_WIDTH_SMOOTHING;
    float newThickness = (STROKE_WIDTH_MAX - STROKE_WIDTH_MIN) * (1 - normalizedVelocity) + STROKE_WIDTH_MIN;
    penThickness = penThickness * lowPassFilterAlpha + newThickness * (1 - lowPassFilterAlpha);
    
    if ([p state] == UIGestureRecognizerStateBegan) {
        
        previousPoint = l;
        previousMidPoint = l;
        
        PPSSignaturePoint startPoint = ViewPointToGL(l, self.bounds, (GLKVector3){1, 1, 1});
        previousVertex = startPoint;
        previousThickness = penThickness;
        
        addVertex(&length, startPoint);
        addVertex(&length, previousVertex);
        
        self.hasSignature = YES;
        
    } else if ([p state] == UIGestureRecognizerStateChanged) {
        
        CGPoint mid = CGPointMake((l.x + previousPoint.x) / 2.0, (l.y + previousPoint.y) / 2.0);
        
        if (distance > QUADRATIC_DISTANCE_TOLERANCE) {
            // Plot quadratic bezier instead of line
            unsigned int i;
            
            int segments = (int) distance / 1.5;
            
            float startPenThickness = previousThickness;
            float endPenThickness = penThickness;
            previousThickness = penThickness;
            
            for (i = 0; i < segments; i++)
            {
                penThickness = startPenThickness + ((endPenThickness - startPenThickness) / segments) * i;
                
                CGPoint quadPoint = QuadraticPointInCurve(previousMidPoint, mid, previousPoint, (float)i / (float)(segments));
                
                PPSSignaturePoint v = ViewPointToGL(quadPoint, self.bounds, StrokeColor);
                [self addTriangleStripPointsForPrevious:previousVertex next:v];
                
                previousVertex = v;
            }
        } else if (distance > 1.0) {
            
            PPSSignaturePoint v = ViewPointToGL(l, self.bounds, StrokeColor);
            [self addTriangleStripPointsForPrevious:previousVertex next:v];
            
            previousVertex = v;
            previousThickness = penThickness;
        }
        
        previousPoint = l;
        previousMidPoint = mid;
        
    } else if (p.state == UIGestureRecognizerStateEnded | p.state == UIGestureRecognizerStateCancelled) {
        
        PPSSignaturePoint v = ViewPointToGL(l, self.bounds, (GLKVector3){1, 1, 1});
        addVertex(&length, v);
        
        previousVertex = v;
        addVertex(&length, previousVertex);
    }
    
    [self setNeedsDisplay];
}


- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self updateStrokeColor];
}


#pragma mark - Private

- (void)updateStrokeColor {
    CGFloat red, green, blue, alpha, white;
    if (effect && self.strokeColor && [self.strokeColor getRed:&red green:&green blue:&blue alpha:&alpha]) {
        effect.constantColor = GLKVector4Make(red, green, blue, alpha);
    } else if (effect && self.strokeColor && [self.strokeColor getWhite:&white alpha:&alpha]) {
        effect.constantColor = GLKVector4Make(white, white, white, alpha);
    } else effect.constantColor = GLKVector4Make(0,0,0,1);
}


- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    CGFloat red, green, blue, alpha, white;
    if ([backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha]) {
        clearColor[0] = red;
        clearColor[1] = green;
        clearColor[2] = blue;
    } else if ([backgroundColor getWhite:&white alpha:&alpha]) {
        clearColor[0] = white;
        clearColor[1] = white;
        clearColor[2] = white;
    }
}

- (void)bindShaderAttributes {
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(PPSSignaturePoint), 0);
    //    glEnableVertexAttribArray(GLKVertexAttribColor);
    //    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE,  6 * sizeof(GLfloat), (char *)12);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:context];
    
    effect = [[GLKBaseEffect alloc] init];
    
    [self updateStrokeColor];
    
    
    glDisable(GL_DEPTH_TEST);
    
    // Signature Lines
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SignatureVertexData), SignatureVertexData, GL_DYNAMIC_DRAW);
    [self bindShaderAttributes];
    
    
    // Signature Dots
    glGenVertexArraysOES(1, &dotsArray);
    glBindVertexArrayOES(dotsArray);
    
    glGenBuffers(1, &dotsBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, dotsBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SignatureDotsData), SignatureDotsData, GL_DYNAMIC_DRAW);
    [self bindShaderAttributes];
    
    
    glBindVertexArrayOES(0);
    
    
    // Perspective
    GLKMatrix4 ortho = GLKMatrix4MakeOrtho(-1, 1, -1, 1, 0.1f, 2.0f);
    effect.transform.projectionMatrix = ortho;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.0f);
    effect.transform.modelviewMatrix = modelViewMatrix;
    
    length = 0;
    penThickness = 0.003;
    previousPoint = CGPointMake(-100, -100);
}



- (void)addTriangleStripPointsForPrevious:(PPSSignaturePoint)previous next:(PPSSignaturePoint)next {
    float toTravel = penThickness / 2.0;
    
    for (int i = 0; i < 2; i++) {
        GLKVector3 p = perpendicular(previous, next);
        GLKVector3 p1 = next.vertex;
        GLKVector3 ref = GLKVector3Add(p1, p);
        
        float distance = GLKVector3Distance(p1, ref);
        float difX = p1.x - ref.x;
        float difY = p1.y - ref.y;
        float ratio = -1.0 * (toTravel / distance);
        
        difX = difX * ratio;
        difY = difY * ratio;
        
        PPSSignaturePoint stripPoint = {
            { p1.x + difX, p1.y + difY, 0.0 },
            StrokeColor
        };
        addVertex(&length, stripPoint);
        
        toTravel *= -1;
    }
}


- (void)tearDownGL
{
    [EAGLContext setCurrentContext:context];
    
    glDeleteVertexArraysOES(1, &vertexArray);
    glDeleteBuffers(1, &vertexBuffer);
    
    glDeleteVertexArraysOES(1, &dotsArray);
    glDeleteBuffers(1, &dotsBuffer);
    
    effect = nil;
}

@end



@interface MJSignatureView ()
{
    /**
     *  @brief 用户签名后，形成的略缩图
     */
    UIImageView *_signImageView;
    
    /**
     *  @brief 用户签名的视图
     */
    UIView      *_signBoardView;
    
    UIView      *_maskView;
    
    CATransform3D _transfrom;
}
@end


@implementation MJSignatureView

-(CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, kSizeSignImage.height+20+[self.configParam[kWidgetParam_MinHeight]integerValue]);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_signBoardView)
    {//非第一次
        
        if (_signBoardView.hidden)
        {
            _signBoardView.hidden = NO;
            _maskView.hidden = NO;
            
            [UIView animateWithDuration:kAnnimateTime animations:^
             {
                 _maskView.alpha = 0.5;
                 _signBoardView.layer.transform = CATransform3DIdentity;
             } completion:^(BOOL finished) {
                 [self valueWillChanged];
             }];
        }else
        {
            [self Dismiss];
        }
    }else
    {//第一次显示
        
        [self valueWillChanged];
        
        UIWindow * window = [[[UIApplication sharedApplication] windows] firstObject];
        UIView * rootView = window.rootViewController.view;
        
        _maskView = [UIView newAutoLayoutView];
        _maskView.userInteractionEnabled = YES;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Dismiss)]];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0;
        [rootView addSubview:_maskView];
        [_maskView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        CGRect sourceRect = [_signImageView convertRect:_signImageView.bounds toView:rootView];
        CGFloat width  = rootView.width*0.65;
        CGFloat height = width*(_signImageView.height/_signImageView.width);
        CGRect frame = CGRectMake((rootView.width-width)/2, (rootView.height-height)/2, width, height);
        _signBoardView = [[UIView alloc]initWithFrame:frame];
        _signBoardView.backgroundColor = [UIColor whiteColor];
        _transfrom = CATransform3DConcat(CATransform3DMakeScale(sourceRect.size.width/width,sourceRect.size.height/height, 1), CATransform3DMakeTranslation(+_signImageView.left-_signBoardView.left-_signImageView.width,-_signImageView.centerY+_signBoardView.centerY, 0));
         _signBoardView.layer.transform = _transfrom;
        _signBoardView.layer.borderColor = [UIColor grayColor].CGColor;
        _signBoardView.layer.borderWidth = 0.6;
        _signBoardView.userInteractionEnabled = YES;
        [rootView addSubview:_signBoardView];
        
        /**
         *  @brief 增加删除按钮
         */
        UIButton *deleteBtn = [UIButton newAutoLayoutView];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:kTextColor forState:UIControlStateNormal];
        [_signBoardView addSubview:deleteBtn];
        [deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15];
        [deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:25];
        
        /**
         *  @brief 增加保存按钮
         */
        UIButton *saveBtn = [UIButton newAutoLayoutView];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:kTextColor forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [_signBoardView addSubview:saveBtn];
        [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15];
        [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:25];
        
        WSSignatureView *signatureView = [[WSSignatureView alloc]initForAutoLayout];
        signatureView.tag = kTagSignView;
         [deleteBtn addTarget:signatureView action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
        signatureView.signatureImage = _signImageView.image;
        [_signBoardView addSubview:signatureView];
        [signatureView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_signBoardView bringSubviewToFront:deleteBtn];
        [_signBoardView bringSubviewToFront:saveBtn];
        
        [UIView animateWithDuration:kAnnimateTime animations:^
        {
            _maskView.alpha = 0.5;
            _signBoardView.layer.transform = CATransform3DIdentity;
            deleteBtn.hidden = NO;
            saveBtn.hidden = NO;
        } completion:^(BOOL finished) {
            
        }];

    }
}

-(void)save
{
    WSSignatureView *signatureView = [_signBoardView viewWithTag:kTagSignView];
    _signImageView.image =  signatureView.signatureImage;
    _signImageView.hidden = YES;
   
    [self Dismiss];
    
    [self valueDidChanged];
}

/**
 *  @brief 点击隐藏视图
 *
 */
-(void)Dismiss
{
    _signBoardView.hidden = NO;
    _maskView.hidden = NO;
    
    [UIView animateWithDuration:kAnnimateTime animations:^
     {
         _maskView.alpha = 0;
         _signBoardView.layer.transform = _transfrom;
     } completion:^(BOOL finished)
    {
        _signBoardView.hidden = YES;
        _maskView.hidden = YES;
         _signImageView.hidden = NO;
     }];
}



-(BOOL)setupSubViews
{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    UILabel *lable = [UILabel newAutoLayoutView];
    lable.backgroundColor = [UIColor clearColor];
    lable.text = @"签名";
    lable.textColor = kTextColor;
    [self addSubview:lable];
    
    [lable autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [lable autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    
    _signImageView = [UIImageView newAutoLayoutView];
    _signImageView.contentMode = UIViewContentModeScaleToFill;
    _signImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_signImageView];
    [_signImageView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:lable withOffset:40];
    [_signImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:lable];
    [_signImageView autoSetDimensionsToSize:kSizeSignImage];
    
    return YES;
}

-(void)dealloc
{
    [_maskView removeFromSuperview];
    _maskView = nil;
    
    [_signBoardView removeFromSuperview];
    _signBoardView = nil;
}

-(id)value
{
    return _signImageView.image;
}

@end

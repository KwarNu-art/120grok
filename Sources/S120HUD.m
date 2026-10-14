#import "S120HUD.h"
#import "S120Engine.h"

/// Small glass / liquid-style FPS pill
@interface S120GlassPill : UIView
@property (nonatomic, strong) UILabel *label;
@end

@implementation S120GlassPill
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor colorWithRed:0.92 green:0.95 blue:1.0 alpha:0.22];
        self.layer.cornerRadius = frame.size.height * 0.5;
        self.layer.masksToBounds = YES;
        if (@available(iOS 13.0, *)) {
            self.layer.cornerCurve = kCACornerCurveContinuous;
        }
        // Liquid glass edge
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor colorWithRed:0.85 green:0.92 blue:1.0 alpha:0.55].CGColor;

        // Soft inner highlight (fake liquid glass)
        UIView *shine = [[UIView alloc] initWithFrame:CGRectMake(1, 1, frame.size.width - 2, frame.size.height * 0.42)];
        shine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.18];
        shine.layer.cornerRadius = frame.size.height * 0.35;
        shine.userInteractionEnabled = NO;
        [self addSubview:shine];

        _label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 8, 0)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        _label.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightSemibold];
        _label.text = @"— fps";
        [self addSubview:_label];
    }
    return self;
}
@end

@interface S120HUD ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) S120GlassPill *pill;
@property (nonatomic, strong) CADisplayLink *uiLink;
@end

@implementation S120HUD

+ (instancetype)shared {
    static S120HUD *s;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [S120HUD new]; });
    return s;
}

- (void)install {
    if (self.window) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.window) return;

        CGRect screen = UIScreen.mainScreen.bounds;
        CGFloat w = 72.0, h = 26.0;
        CGFloat x = screen.size.width - w - 14.0;
        CGFloat safeBottom = 0;
        if (@available(iOS 11.0, *)) {
            safeBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        }
        CGFloat y = screen.size.height - h - 12.0 - safeBottom;

        UIWindow *win = [[UIWindow alloc] initWithFrame:screen];
        win.windowLevel = UIWindowLevelStatusBar + 80;
        win.backgroundColor = UIColor.clearColor;
        win.userInteractionEnabled = YES;
        win.hidden = NO;

        UIView *root = [[UIView alloc] initWithFrame:screen];
        root.backgroundColor = UIColor.clearColor;
        // Pass-through empty areas
        root.userInteractionEnabled = YES;
        win.rootViewController = [UIViewController new];
        win.rootViewController.view = root;

        // Override hitTest via category-like block: only pill receives touches
        S120GlassPill *pill = [[S120GlassPill alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [root addSubview:pill];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [pill addGestureRecognizer:pan];

        self.window = win;
        self.pill = pill;

        self.uiLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
        if (@available(iOS 10.0, *)) {
            self.uiLink.preferredFramesPerSecond = 30; // HUD itself stays light
        }
        [self.uiLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    });
}

- (void)onPan:(UIPanGestureRecognizer *)g {
    UIView *v = g.view;
    CGPoint t = [g translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [g setTranslation:CGPointZero inView:v.superview];
    CGRect b = v.superview.bounds;
    CGFloat hw = v.bounds.size.width * 0.5, hh = v.bounds.size.height * 0.5;
    v.center = CGPointMake(MIN(MAX(v.center.x, hw), b.size.width - hw),
                           MIN(MAX(v.center.y, hh), b.size.height - hh));
}

- (void)tick {
    S120Engine *e = S120Engine.shared;
    NSInteger maxHz = e.hardwareMaxHz;
    self.pill.label.text = [NSString stringWithFormat:@"%.0f fps", e.liveFPS];
    // Tint: green if near panel max, soft blue otherwise
    if (e.liveFPS >= maxHz * 0.9) {
        self.pill.label.textColor = [UIColor colorWithRed:0.55 green:1.0 blue:0.75 alpha:1.0];
    } else {
        self.pill.label.textColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    }
}

@end

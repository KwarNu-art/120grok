#import "S120Engine.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation S120Engine {
    NSTimer *_refreshTimer;
    CADisplayLink *_probe;
    NSInteger _targetHz;
    NSInteger _hardwareMaxHz;
    double _liveFPS;
    CFTimeInterval _lastTime;
    NSUInteger _frames;
}

+ (instancetype)shared {
    static S120Engine *s;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [S120Engine new]; });
    return s;
}

- (instancetype)init {
    if ((self = [super init])) {
        _hardwareMaxHz = 60;
        if (@available(iOS 10.3, *)) {
            _hardwareMaxHz = (NSInteger)UIScreen.mainScreen.maximumFramesPerSecond;
        }
        // Never claim higher than the panel can do
        _targetHz = MIN(120, MAX(30, _hardwareMaxHz));
        _lastTime = CACurrentMediaTime();
    }
    return self;
}

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self applyNow];
        // Auto-refresh settings in background every 5 seconds
        [self->_refreshTimer invalidate];
        self->_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                              target:self
                                                            selector:@selector(applyNow)
                                                            userInfo:nil
                                                             repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self->_refreshTimer forMode:NSRunLoopCommonModes];

        if (!self->_probe) {
            self->_probe = [CADisplayLink displayLinkWithTarget:self selector:@selector(onProbe:)];
            if (@available(iOS 15.0, *)) {
                self->_probe.preferredFrameRateRange = CAFrameRateRangeMake((float)self->_targetHz,
                                                                           (float)self->_targetHz,
                                                                           (float)self->_targetHz);
            } else if (@available(iOS 10.0, *)) {
                self->_probe.preferredFramesPerSecond = self->_targetHz;
            }
            [self->_probe addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        }
    });
}

- (void)applyNow {
    NSInteger maxHz = 60;
    if (@available(iOS 10.3, *)) {
        maxHz = (NSInteger)UIScreen.mainScreen.maximumFramesPerSecond;
    }
    _hardwareMaxHz = maxHz;
    _targetHz = MIN(120, MAX(30, maxHz));

    // Re-assert display link preference (apps may reset it)
    if (_probe) {
        if (@available(iOS 15.0, *)) {
            _probe.preferredFrameRateRange = CAFrameRateRangeMake((float)_targetHz,
                                                                  (float)_targetHz,
                                                                  (float)_targetHz);
        } else if (@available(iOS 10.0, *)) {
            _probe.preferredFramesPerSecond = _targetHz;
        }
    }
}

- (void)onProbe:(CADisplayLink *)link {
    _frames++;
    CFTimeInterval now = CACurrentMediaTime();
    CFTimeInterval dt = now - _lastTime;
    if (dt >= 0.5) {
        _liveFPS = _frames / dt;
        _frames = 0;
        _lastTime = now;
    }
}

- (NSInteger)targetHz { return _targetHz; }
- (NSInteger)hardwareMaxHz { return _hardwareMaxHz; }
- (double)liveFPS { return _liveFPS; }

@end

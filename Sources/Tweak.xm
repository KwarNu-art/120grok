/*
 * Super120Hz — two-in-one
 *  1) Prefer maximum refresh (up to 120 Hz on ProMotion hardware)
 *  2) Small glass FPS pill + background re-apply every 5s
 *
 * Hardware truth:
 *  - iPhone 7 / 7 Plus / most non-Pro panels = 60 Hz max. Cannot do 120.
 *  - ProMotion (13 Pro+, 14 Pro+, 15 Pro+, 16 Pro+, …) can reach 120.
 *  - iOS cannot invent pixels the display panel does not support.
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "S120Engine.h"
#import "S120HUD.h"

static NSInteger S120Cap(void) {
    NSInteger maxHz = 60;
    if (@available(iOS 10.3, *)) {
        maxHz = (NSInteger)UIScreen.mainScreen.maximumFramesPerSecond;
    }
    return MIN(120, MAX(30, maxHz));
}

%hook CADisplayLink

- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    NSInteger cap = S120Cap();
    if (@available(iOS 15.0, *)) {
        self.preferredFrameRateRange = CAFrameRateRangeMake((float)cap, (float)cap, (float)cap);
    } else if (@available(iOS 10.0, *)) {
        self.preferredFramesPerSecond = cap;
    }
    %orig;
}

- (void)setPreferredFramesPerSecond:(NSInteger)fps {
    NSInteger cap = S120Cap();
    // Pull low requests up toward panel max (best-effort; games may still vsync lower)
    if (fps > 0 && fps < cap) fps = cap;
    if (fps > cap) fps = cap;
    %orig(fps);
}

%end

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    [[S120Engine shared] start];
    [[S120HUD shared] install];
}

%end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [[S120Engine shared] start];
        [[S120HUD shared] install];
    });
}

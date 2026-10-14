#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface S120Engine : NSObject
+ (instancetype)shared;
- (void)start;
- (void)applyNow;
@property (nonatomic, assign, readonly) NSInteger targetHz;   // 120 if hardware allows, else max
@property (nonatomic, assign, readonly) NSInteger hardwareMaxHz;
@property (nonatomic, assign, readonly) double liveFPS;
@end

NS_ASSUME_NONNULL_END

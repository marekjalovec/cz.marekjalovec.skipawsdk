#import "AWSDKBridge+Sapho.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@implementation AWSDKBridge (Sapho)

+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        Class class = [AWSDKBridge class];
        if (!class) {
            NSLog(@"Swizzle failed, couldn't find AWSDKBridge");
            return;
        }

        SEL originalSelector = NSSelectorFromString(@"startAirwatchSDK");
        SEL swizzledSelector = @selector(swizzled_startAirwatchSDK);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);

        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });

}

- (void) swizzled_startAirwatchSDK {
    bool hasAirWatch = (
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"airwatch://"]] ||
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"AWSSOBroker2://"]]
    );

    if (!hasAirWatch) {
        NSLog(@"AirWatch SDK init skipped, Agent not found.");

        return;
    }

    [self swizzled_startAirwatchSDK];
}

@end

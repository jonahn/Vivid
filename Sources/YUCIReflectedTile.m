//
//  YUCIReflectTile.m
//  Pods
//
//  Created by YuAo on 2/16/16.
//
//

#import "YUCIReflectedTile.h"
#import "YUCIFilterConstructor.h"

@implementation YUCIReflectedTile

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIReflectedTile class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryTileEffect],
                                               kCIAttributeFilterDisplayName: @"Reflected Tile"}];
            }
        }
    });
}

+ (CIWarpKernel *)filterKernel {
    static CIWarpKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIReflectedTile class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIWarpKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputMode {
    if (!_inputMode) {
        _inputMode = @(YUCIReflectedTileModeReflectWithoutBorder);
    }
    return _inputMode;
}

- (CIImage *)outputImage {
    CGRect inputExtent = self.inputImage.extent;
    return [[YUCIReflectedTile filterKernel] applyWithExtent:CGRectInfinite
                                                 roiCallback:^CGRect(int index, CGRect destRect) {
                                                     if (CGRectContainsRect(inputExtent, destRect)) {
                                                         return destRect;
                                                     } else if(CGRectContainsRect(destRect, inputExtent)) {
                                                         return inputExtent;
                                                     } else {
                                                         //needs rework.
                                                         return inputExtent;
                                                     }
                                                 }
                                                  inputImage:self.inputImage
                                                   arguments:@[self.inputMode,[CIVector vectorWithCGRect:self.inputImage.extent]]];
}

@end

#import "FlamingoAnnotationPlugin.h"
#if __has_include(<flamingo_annotation/flamingo_annotation-Swift.h>)
#import <flamingo_annotation/flamingo_annotation-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flamingo_annotation-Swift.h"
#endif

@implementation FlamingoAnnotationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlamingoAnnotationPlugin registerWithRegistrar:registrar];
}
@end

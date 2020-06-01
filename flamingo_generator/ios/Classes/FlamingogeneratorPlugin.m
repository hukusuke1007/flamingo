#import "FlamingoGeneratorPlugin.h"
#if __has_include(<flamingo_generator/flamingo_generator-Swift.h>)
#import <flamingo_generator/flamingo_generator-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flamingo_generator-Swift.h"
#endif

@implementation FlamingoGeneratorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlamingoGeneratorPlugin registerWithRegistrar:registrar];
}
@end

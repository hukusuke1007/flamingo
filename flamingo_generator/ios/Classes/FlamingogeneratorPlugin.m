#import "FlamingogeneratorPlugin.h"
#if __has_include(<flamingogenerator/flamingogenerator-Swift.h>)
#import <flamingogenerator/flamingogenerator-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flamingogenerator-Swift.h"
#endif

@implementation FlamingogeneratorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlamingogeneratorPlugin registerWithRegistrar:registrar];
}
@end

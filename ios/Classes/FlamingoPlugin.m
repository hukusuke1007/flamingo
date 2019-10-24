#import "FlamingoPlugin.h"
#import <flamingo/flamingo-Swift.h>

@implementation FlamingoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlamingoPlugin registerWithRegistrar:registrar];
}
@end

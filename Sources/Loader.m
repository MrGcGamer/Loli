#import "Headers/Loader.h"
#import "Headers/Base.h"
#define settingsId @"com.mrgcgamer.loliprefs"
NSUserDefaults *prefs;

static void __attribute__((constructor)) ctor (int argc, char **argv, char **envp) {
  prefs = [[NSUserDefaults alloc] initWithSuiteName:settingsId];

  InitLayout();
  InitColoring();
}
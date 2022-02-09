
#include <CoreFoundation/CoreFoundation.h>

extern void NSLog(CFStringRef format, ...);

void write_to_nslog(const char *string)
{
    static CFStringRef format = CFSTR("%s");
    NSLog(format, string);
}


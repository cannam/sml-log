
#ifdef __APPLE__

#include <CoreFoundation/CoreFoundation.h>

extern void NSLog(CFStringRef format, ...);

void write_to_syslog(const char *string)
{
    static CFStringRef format = CFSTR("%s");
    NSLog(format, string);
}

#else

#include <syslog.h>

void write_to_syslog(const char *string)
{
    syslog(LOG_NOTICE, "%s", string);
}

#endif

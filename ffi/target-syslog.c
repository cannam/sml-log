
#if defined(__APPLE__)

#include <CoreFoundation/CoreFoundation.h>

extern void NSLog(CFStringRef format, ...);

void write_to_syslog(const char *string)
{
    static CFStringRef format = CFSTR("%s");
    NSLog(format, string);
}

#elif defined(_WIN32)

#include <windows.h>
#include <debugapi.h>

void write_to_syslog(const char *string)
{
    OutputDebugString(string);
}

#else

#include <syslog.h>

void write_to_syslog(const char *string)
{
    syslog(LOG_NOTICE, "%s", string);
}

#endif

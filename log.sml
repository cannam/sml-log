
structure Log :> LOG = struct

    open StringInterpolate

    datatype level = ERROR | WARN | INFO | DEBUG

    val level : level option ref = ref NONE
    val startTime : Time.time option ref = ref NONE

    fun elapsedTime () =
        case !startTime of
            SOME t => (Time.- (Time.now (), t))
          | NONE => (startTime := SOME (Time.now ()); Time.zeroTime)
                                           
    fun currentLevel () =
        case !level of
            SOME level => level
          | NONE =>
            let val defaultLevel =
                    case OS.Process.getEnv "LOGLEVEL" of
                        SOME "error" => ERROR
                      | SOME "warn" => WARN
                      | SOME "info" => INFO
                      | SOME "debug" => DEBUG
                      | SOME other =>
                        (TextIO.output
                             (TextIO.stdErr,
                              "Logger: NOTE: Unknown log level in LOGLEVEL " ^
                              "environment variable: supported values are " ^
                              "error, warn, info, or debug\n");
                         WARN)
                      | NONE => WARN
            in
                level := SOME defaultLevel;
                defaultLevel
            end

    fun resetElapsedTime () = startTime := SOME (Time.now ())
    fun setLogLevel l = level := SOME l

    datatype element = ELAPSED_TIME | DATE_TIME | PID | LEVEL | MESSAGE
    type format = { elements: element list, separator: string }

    val format = ref {
        elements = [ ELAPSED_TIME, LEVEL, MESSAGE ],
        separator = ": "
    }
    fun setLogFormat f = format := f
                    
    type arg = string list
    type thunk = unit -> arg

    fun elapsedString () =
        Time.fmt 6 (elapsedTime ())

    fun dateString () =
        Date.fmt "%Y-%m-%d %H:%M:%S" (Date.fromTimeLocal (Time.now ()))

    fun pidString () =
        "#" ^ (SysWord.fmt StringCvt.DEC (Posix.Process.pidToWord
                                              (Posix.ProcEnv.getpid ())))
                 
    fun levelString ERROR = "ERROR"
      | levelString WARN = "WARNING"
      | levelString INFO = "INFO"
      | levelString DEBUG = "DEBUG"
                      
    val noLog = [""]

    fun print string =
        if string <> "" then TextIO.output (TextIO.stdErr, string ^ "\n")
        else ()

    fun logWith printer level [] = ()
      | logWith printer level (string::args) =
        printer
            let val { elements, separator } = !format
            in
                String.concatWith separator
                                  (map (fn ELAPSED_TIME => elapsedString ()
                                       | DATE_TIME => dateString ()
                                       | PID => pidString ()
                                       | LEVEL => levelString level
                                       | MESSAGE => interpolate string args)
                                       elements)
            end

    val log = logWith print

    val logFail =
        let fun printFail msg = (print msg ; raise Fail msg; ())
        in
            logWith printFail
        end
            
    fun debug f =
        let val level = currentLevel ()
        in
            if level = DEBUG then
                log DEBUG (f ())
            else ()
        end
              
    fun info f =
        let val level = currentLevel ()
        in
            if level = INFO orelse level = DEBUG then
                log INFO (f ())
            else ()
        end
                 
    fun warn f =
        let val level = currentLevel ()
        in
            if level = WARN orelse level = INFO orelse level = DEBUG then
                log WARN (f ())
            else ()
        end
                 
    fun error f =
        log ERROR (f ())
                 
    fun fatal f =
        logFail ERROR (f ())
              
    fun debug_d a =
        let val level = currentLevel ()
        in
            if level = DEBUG then
                log DEBUG a
            else ()
        end
              
    fun info_d a =
        let val level = currentLevel ()
        in
            if level = INFO orelse level = DEBUG then
                log INFO a
            else ()
        end
                 
    fun warn_d a =
        let val level = currentLevel ()
        in
            if level = WARN orelse level = INFO orelse level = DEBUG then
                log WARN a
            else ()
        end
                 
    fun error_d a =
        log ERROR a
                 
    fun fatal_d a =
        logFail ERROR a

end

structure LogDebug :> LOG = Log

structure LogInfo :> LOG = struct
    open Log
    val debug = ignore
    val debug_d = ignore
end

structure LogWarn :> LOG = struct
    open LogInfo
    val info = ignore
    val info_d = ignore
end

structure LogError :> LOG = struct
    open LogWarn
    val warn = ignore
    val warn_d = ignore
end

                               

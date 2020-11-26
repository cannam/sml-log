
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
    fun getLogLevel () = currentLevel ()

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

    val logFail =
        let fun printFail msg = (print msg ; raise Fail msg; ())
        in
            logWith printFail
        end

    fun shouldLog level =
        case (level, currentLevel ()) of
            (DEBUG, DEBUG) => true
          | (INFO, DEBUG) => true
          | (INFO, INFO) => true
          | (WARN, DEBUG) => true
          | (WARN, INFO) => true
          | (WARN, WARN) => true
          | (ERROR, _) => true
          | _ => false

    fun log level f =
        if shouldLog level
        then logWith print level (f ())
        else ()
            
    val debug = log DEBUG
    val info = log INFO
    val warn = log WARN
    val error = log ERROR
                 
    fun fatal f =
        logFail ERROR (f ())

    fun log_d level arg =
        if shouldLog level
        then logWith print level arg
        else ()
            
    val debug_d = log_d DEBUG
    val info_d = log_d INFO
    val warn_d = log_d WARN
    val error_d = log_d ERROR

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

                               

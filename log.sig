
(** Format and print log information according to a set log level.

    The log functions generally act on a list of strings, with the
    first in the list being a format string and remaining strings
    being values to interpolate. Short conversion functions from
    various other types to strings are also provided so the result can
    be relatively brief.
<p>
    There are two sorts of log function: standard (thunked) or
    immediate. The standard log functions take an anonymous function,
    or thunk, as argument. The thunk is only called if the log level
    is high enough for the message to be printed.  For example,
<pre>
           info (fn () => ["Loading data from %...", S filename])
</pre>

    The direct variants, with _d suffix, take arguments directly. For
    example:
<pre>
           info_d ["Loading data from %...", S filename]
</pre>
    This may be slower in cases where the log level is not high enough
    to actually print the resulting message.

    Various functions to adjust the global log level and formatting
    are also provided.

    See also STRING_INTERPOLATE for details of the string
    interpolation and conversion mechanisms.
*)
signature LOG = sig

    (** Log level. Logs at a certain level of severity will be printed
        only if the log level is set at the same severity or
        lower.
     *)    
    datatype level =
             (** Error that is likely fatal *)
             ERROR |
             (** Warning *)
             WARN |
             (** Low-volume information, e.g. setup or occasional summaries *)
             INFO |
             (** High-volume information for debugging only *)
             DEBUG

    (** Set the global log level. *)
    val setLogLevel : level -> unit

    (** Query the global log level. *)
    val getLogLevel : unit -> level

    (** Elements that may appear in a log line.
     *)
    datatype element =
             (** Time since program start or last call to resetElapsedTime *)
             ELAPSED_TIME |
             (** Current date and time *)
             DATE_TIME |
             (** Process ID *)
             PID |
             (** Log level of the message being printed *)
             LEVEL |
             (** The message itself *)
             MESSAGE

    (** Log line format, as a series of elements to be separated by
        the given separator string.
     *)
    type format = { elements: element list, separator: string }

    (** Set the global log format. *)
    val setLogFormat : format -> unit

    (** Set the elapsed time to zero. *)
    val resetElapsedTime : unit -> unit

    (** A list of strings, where the first is the format string and
        the rest are arguments to be interpolated. The format string
        must contain a % character for each of the remaining strings,
        which will be interpolated to replace the % characters in
        turn.
    *)
    type arg = string list

    (** A function that returns the format string and arguments to
        be logged. *)
    type thunk = unit -> arg

    (** An empty log argument. *)
    val noLog : arg

    (** Print a log message from the given thunk, if the current log
        level is DEBUG. *)
    val debug : thunk -> unit

    (** Print a log message from the given thunk, if the current log
        level is at least as severe as INFO. *)
    val info : thunk -> unit

    (** Print a log message from the given thunk, if the current log
        level is at least as severe as WARN. *)
    val warn : thunk -> unit

    (** Print a log message from the given thunk. *)
    val error : thunk -> unit

    (** Print a log message from the given thunk and also raise a Fail
        exception with the same message. *)
    val fatal : thunk -> unit

    (** Print a log message from the supplied thunk, if the current
        log level is at least as severe as the given one. *)
    val log : level -> thunk -> unit

    (** Print a log message from the given format string and
        arguments, if the current log level is DEBUG. *)
    val debug_d : arg -> unit

    (** Print a log message from the given format string and
        arguments, if the current log level is at least as severe as
        INFO. *)
    val info_d : arg -> unit

    (** Print a log message from the given format string and
        arguments, if the current log level is at least as severe as
        WARN. *)
    val warn_d : arg -> unit

    (** Print a log message from the given format string and
        arguments. *)
    val error_d : arg -> unit

    (** Print a log message from the given format string and arguments
        and also raise a Fail exception with the same message. *)
    val fatal_d : arg -> unit

    (** Print a log message from the given format string and
        arguments, if the current log level is at least as severe as the
        given one. *)
    val log_d : level -> arg -> unit

    (* Data-to-string conversion shorthands: *)
    val I : int -> string
    val FI : FixedInt.int -> string
    val R : real -> string
    val N : real -> string
    val Z : real * real -> string
    val C : char -> string
    val B : bool -> string
    val S : string -> string
    val SL : string list -> string
    val RV : RealVector.vector -> string
    val RA : RealArray.array -> string
    val NV : RealVector.vector -> string
    val NA : RealArray.array -> string
    val T : Time.time -> string
    val O : string option -> string
    val X : exn -> string
                               
end

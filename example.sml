
fun example1 () =
    let open Log
    in
        info (fn () => ["Checking for blips..."]);
        warn (fn () => ["Spurious warning: %1 blips detected in %2 sector!!",
                        I 4, S "Zarquil"]);
        info (fn () => ["Done"])
    end

fun example2 () =
    let open Log
    in
        info_d ["Checking for blips..."];
        warn_d ["Spurious warning: %1 blips detected in %2 sector!!",
                I 4, S "Zarquil"];
        info_d ["Done"]
    end

structure Log = LogWarn (* should never print info output *)

fun example3 () =
    let open Log
    in
        info (fn () => ["Checking for blips..."]);
        warn (fn () => ["Spurious warning: %1 blips detected in %2 sector!!",
                        I 4, S "Zarquil"]);
        info (fn () => ["Done"])
    end

fun usage () =
    let open TextIO in
	output (stdErr,
	    "Usage:\n" ^
            "    example [-v]\n" ^
            "where -v raises the log level from WARNING to INFO\n");
        raise Fail "Incorrect arguments specified"
    end

fun handle_args args =
    case args of
        "-v"::rest => (Log.setLogLevel Log.INFO ; handle_args rest)
      | [] => (example1 () ; example2 () ; example3 ())
      | _ => usage ()

fun main () =
    handle_args (CommandLine.arguments ())
    handle Fail msg => TextIO.output (TextIO.stdErr, "Exception: " ^ msg ^ "\n")

    

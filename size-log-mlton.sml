
structure SizeLog : SIZE_LOG = struct

   structure Logger = CategoryLogFn (struct
                                      val category = "size"
                                      end)

   val shouldReport : bool option ref = ref NONE

   fun checkShouldReport () : bool =
       case ! shouldReport of
           SOME r => r
         | NONE =>
           let val r = case OS.Process.getEnv "LOGSIZE" of
                           SOME "true" => true
                         | _ => false
           in
               shouldReport := SOME r;
               r
           end
                                            
   fun report location id tag x =
       if checkShouldReport ()
       then Logger.info (fn () => case id of
                                      NONE =>
                                      ["%1: size of %2 = %3",
                                       location, tag,
                                       IntInf.toString (MLton.size x)]
                                    | SOME id =>
                                      ["%1[%2]: size of %3 = %4",
                                       location, Logger.I id, tag,
                                       IntInf.toString (MLton.size x)]
                        )
       else ()

end


structure LogTargetStderr : LOG_TARGET = struct

     type writer = string -> unit
                            
     type new_args = unit
                         
     fun new () =
         fn s =>
            if s <> ""
            then TextIO.output (TextIO.stdErr, s ^ "\n")
            else ()

     fun isAvailable () = true
			      
end

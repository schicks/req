open Core
open Cohttp_lwt_unix
open Lwt

let run_request ({ headers; body; meth; uri } : Req.Parse.request) =
  Lwt_main.run
    ( Client.call ~headers ~body meth uri >>= fun (_, body) ->
      Cohttp_lwt.Body.to_string body )

let () =
  Command_unix.run
    (Command.basic ~summary:"Make an HTTP request"
       (let%map_open.Command filename =
          anon ("filename" %: Filename_unix.arg_type)
        in
        fun () ->
          Result.(
            Req.Parse.parse_file filename >>| run_request |> function
            | Ok result | Error result -> print_endline result)))

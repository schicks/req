open Core
open Cohttp_lwt_unix
open Lwt

let run_request ({ headers; body; meth; uri } : Req.Parse.request) =
  Lwt_main.run
    ( Client.call ~headers ~body:(Cohttp_lwt.Body.of_string body) meth uri
    >>= fun (_, body) -> Cohttp_lwt.Body.to_string body )

let () =
  Command_unix.run
    (Command.basic ~summary:"Make an HTTP request"
       (let%map_open.Command filename =
          anon ("filename" %: Filename_unix.arg_type)
        in
        fun () ->
          match Req.Parse.parse_file filename with
          | Ok request -> run_request request |> print_endline
          | Error parse_error ->
              Printf.eprintf "Failed to parse request: '%s'\n" parse_error;
              exit 1))

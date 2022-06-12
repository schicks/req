open Core
open Cohttp_lwt_unix
open Lwt

let is_error r =
  Response.status r |> Cohttp.Code.code_of_status |> Cohttp.Code.is_error

let error_if fail (response, body) =
  if fail && is_error response then (
    Printf.eprintf "Request failed with status %s"
      (Response.status response |> Cohttp.Code.string_of_status);
    exit 22)
  else return (response, body)

let present_response include_headers (response, body) =
  let open Lwt.Let_syntax in
  let%bind response_body = Cohttp_lwt.Body.to_string body in
  let response_headers =
    if include_headers then
      (Response.status response |> Cohttp.Code.string_of_status)
      ^ "\n"
      ^ (Response.headers response |> Cohttp.Header.to_string)
    else ""
  in
  return (response_headers ^ response_body)

let run_request include_headers fail
    ({ headers; body; meth; uri } : Req.Parse.request) =
  Lwt_main.run
    (Client.call ~headers ~body:(Cohttp_lwt.Body.of_string body) meth uri
    >>= error_if fail
    >>= present_response include_headers)

let () =
  Command_unix.run
    (Command.basic ~summary:"Make an HTTP request"
       (let%map_open.Command filename =
          anon ("filename" %: Filename_unix.arg_type)
        and include_headers =
          flag "-include" no_arg
            ~doc:" Include protocol response headers in the output"
        and fail =
          flag "-fail" no_arg ~doc:" Exit 22 if the response code is bad"
        in
        fun () ->
          match Req.Parse.parse_file filename with
          | Ok request ->
              run_request include_headers fail request |> print_endline
          | Error parse_error ->
              Printf.eprintf "Failed to parse request: '%s'\n" parse_error;
              exit 1))

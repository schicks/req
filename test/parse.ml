let build_test_case parser output_testable (input, output) =
  let open Alcotest in
  let check_parse = check (result output_testable string) in
  test_case input `Quick (fun () ->
      check_parse "Parses correctly" (Ok output)
        (Angstrom.parse_string ~consume:All parser input))


let req_body = {|{
  "some key": null, 
  "other key": []
}|}
let complete_req_example = {|GET www.google.com HTTP/1.1
Authorization: Bearer some-token

|} ^ req_body

let () =
  let open Alcotest in
  run "Parsers"
    [
      ( "meth",
        [
          ("GET", `GET);
          ("POST", `POST);
          ("HEAD", `HEAD);
          ("DELETE", `DELETE);
          ("PATCH", `PATCH);
          ("PUT", `PUT);
          ("OPTIONS", `OPTIONS);
          ("TRACE", `TRACE);
          ("CONNECT", `CONNECT);
          ("OTHER", `Other "OTHER");
        ]
        |> List.map (build_test_case Req.Parse.meth Testables.Meth.testable) );
      ( "uri",
        [ ("www.google.com", Uri.of_string "www.google.com") ]
        |> List.map (build_test_case Req.Parse.uri Testables.Url.testable) );
      ( "lexed uri",
        [ ("www.google.com ", Uri.of_string "www.google.com") ]
        |> List.map (build_test_case Req.Parse.(lex uri) Testables.Url.testable)
      );
      ( "version",
        [ ("HTTP/1.1", (1, 1)) ]
        |> List.map
             (build_test_case Req.Parse.version Testables.Version.testable) );
      ( "request line",
        [
          ( "GET www.google.com HTTP/1.1",
            (`GET, Uri.of_string "www.google.com", (1, 1)) );
        ]
        |> List.map
             (build_test_case Req.Parse.request_line
                Testables.RequestLine.testable) );
      ( "headers",
        [
          ( "Authorization: some-token\n",
            Cohttp.Header.init_with "Authorization" "some-token" );
        ]
        |> List.map
             (build_test_case Req.Parse.headers Testables.Headers.testable) );
      ( "request",
        [
          ( "GET www.google.com HTTP/1.1\n\n",
            Req.Parse.
              {
                meth = `GET;
                uri = Uri.of_string "www.google.com";
                headers = Cohttp.Header.init ();
                body = "";
              } );
          ( "GET www.google.com HTTP/1.1\nAuthorization: Bearer some-token\n",
            Req.Parse.
              {
                meth = `GET;
                uri = Uri.of_string "www.google.com";
                headers =
                  Cohttp.Header.init_with "Authorization" "Bearer some-token";
                body = "";
              } );
          ( complete_req_example,
            Req.Parse.
              {
                meth = `GET;
                uri = Uri.of_string "www.google.com";
                headers =
                  Cohttp.Header.init_with "Authorization" "Bearer some-token";
                body = req_body;
              } );
        ]
        |> List.map
             (build_test_case Req.Parse.request Testables.Request.testable) );
    ]

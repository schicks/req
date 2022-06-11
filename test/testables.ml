let prints f ppf i = Fmt.pf ppf "%s" (f i)

module Meth = struct
  let sprint (variant : Cohttp.Code.meth) =
    match variant with
    | `GET -> "GET"
    | `POST -> "POST"
    | `HEAD -> "HEAD"
    | `DELETE -> "DELETE"
    | `PATCH -> "PATCH"
    | `PUT -> "PUT"
    | `OPTIONS -> "OPTIONS"
    | `TRACE -> "TRACE"
    | `CONNECT -> "CONNECT"
    | `Other s -> s

  let equal a b = Cohttp.Code.compare_method a b == 0
  let testable = Alcotest.testable (prints sprint) equal
end

module Url = struct
  let sprint = Uri.to_string
  let equal = Uri.equal
  let testable = Alcotest.testable (prints sprint) equal
end

module Version = struct
  let sprint (major, minor) = Printf.sprintf "HTTP/%d.%d" major minor
  let testable = Alcotest.testable (prints sprint) ( = )
end

module Unit = struct
  let sprint () = ""
  let testable = Alcotest.testable (prints sprint) ( = )
end

module RequestLine = struct
  let sprint (meth, uri, version) =
    Printf.sprintf "%s %s %s" (Meth.sprint meth) (Url.sprint uri)
      (Version.sprint version)

  let testable = Alcotest.testable (prints sprint) ( = )
end

module Headers = struct
  let sprint = Cohttp.Header.to_string
  let equal a b = Cohttp.Header.compare a b = 0
  let testable = Alcotest.testable (prints sprint) equal
end

module Request = struct
  let sprint Req.Parse.{ meth; uri; headers; body } =
    Printf.sprintf "%s %s \n %s \n %s" (Meth.sprint meth) (Url.sprint uri)
      (Headers.sprint headers) body

  let equal Req.Parse.{ meth = meth_a; uri = uri_a; headers = headers_a; _ }
      Req.Parse.{ meth = meth_b; uri = uri_b; headers = headers_b; _ } =
    meth_a = meth_b && Uri.equal uri_a uri_b
    && Headers.equal headers_a headers_b

  let testable = Alcotest.testable (prints sprint) ( = )
end
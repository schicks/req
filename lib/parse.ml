open Angstrom
(*Largely lifted from https://raw.githubusercontent.com/inhabitedtype/angstrom/master/examples/rFC2616.ml*)


type request = {
  headers: Cohttp.Header.t; 
  body: Cohttp_lwt.Body.t;
  meth: Cohttp.Code.meth;
  uri: Uri.t;
}

module P = struct
  let is_space =
    function | ' ' | '\t' -> true | _ -> false

  let is_eol =
    function | '\r' | '\n' -> true | _ -> false

  let is_digit =
    function '0' .. '9' -> true | _ -> false


  let is_token =
    (* The commented-out ' ' and '\t' are not necessary because of the range at
      * the top of the match. *)
    function
      | '\000' .. '\031' | '\127'
      | ')' | '(' | '<' | '>' | '@' | ',' | ';' | ':' | '\\' | '"'
      | '/' | '[' | ']' | '?' | '=' | '{' | '}' (* | ' ' | '\t' *) -> false
      | _ -> true

      let meth = function
      | "GET" -> `GET
      | "POST" -> `POST
      | "HEAD" -> `HEAD
      | "DELETE" -> `DELETE
      | "PATCH" -> `PATCH
      | "PUT" -> `PUT
      | "OPTIONS" -> `OPTIONS
      | "TRACE" -> `TRACE
      | "CONNECT" -> `CONNECT
      | s -> `Other s
end

let token = take_while1 P.is_token
let digits = take_while1 P.is_digit >>| int_of_string
let spaces = skip_while P.is_space

let lex p = p <* spaces

let version =
  string "HTTP/" *>
  lift2 (fun major minor -> (major, minor))
    (digits <* char '.')
    digits

let uri =
  take_till P.is_space >>| Uri.of_string

let meth: Cohttp.Code.meth t = token >>| P.meth

let request_line =
  lift3 (fun meth uri version -> (meth, uri, version))
    (lex meth)
    (lex uri)
    version
  <* end_of_line

let header =
  let colon = char ':' <* spaces in
  lift2 (fun key value -> (key, value))
    token
    (colon *> take_till P.is_eol)

let headers = many (header <* end_of_line) <* end_of_line >>| Cohttp.Header.of_list

let request =
  lift3 (fun (meth, uri, _) headers body -> {headers; meth; uri; body})
    request_line
    headers
    (take_till (fun _ -> true) >>| Cohttp_lwt.Body.of_string)

let parse s = parse_string ~consume:All request s

let parse_file filename = Core.In_channel.read_all filename |> parse

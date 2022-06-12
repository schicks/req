open Angstrom
(*Largely lifted from https://raw.githubusercontent.com/inhabitedtype/angstrom/master/examples/rFC2616.ml*)

type request = {
  headers : Cohttp.Header.t;
  body : string;
  meth : Cohttp.Code.meth;
  uri : Uri.t;
}

module P = struct
  let is_space = function ' ' | '\t' -> true | _ -> false
  let is_colon = function ':' -> true | _ -> false
  let is_eol = function '\r' | '\n' -> true | _ -> false
  let is_digit = function '0' .. '9' -> true | _ -> false

  let is_token = function
    | '\000' .. '\031'
    | '\127' | ')' | '(' | '<' | '>' | '@' | ',' | ';' | '\\' | '"' | '/' | '['
    | ']' | '?' | '=' | '{' | '}' | ' ' ->
        false
    | _ -> true

  let is_header_key = function
    | '/' | 'a' .. 'z' | 'A' .. 'Z' -> true
    | _ -> false

  let is_uri_token = function '/' | ':' -> true | a -> is_token a
end

let token = take_while1 P.is_token
let uri_token = take_while1 P.is_uri_token
let digits = take_while1 P.is_digit >>| int_of_string
let spaces = skip_while P.is_space

let meth : Cohttp.Code.meth t =
  token >>| Cohttp.Code.method_of_string <?> "method"

let uri = uri_token >>| Uri.of_string <?> "uri"

let version =
  string "HTTP/"
  *> lift2 (fun major minor -> (major, minor)) (digits <* char '.') digits
  <?> "version"

let lex p = p <* (end_of_input <|> end_of_line <|> spaces)
let ( -| ) = Core.Fn.compose

let request_line =
  lift3
    (fun meth uri version -> (meth, uri, version))
    (lex meth) (lex uri) version
  <?> "request line"

let header =
  let colon = lex (char ':') in
  lift2
    (fun key value -> (key, value))
    (take_while1 P.is_header_key)
    (colon *> take_while1 (not -| P.is_eol))
  <?> "header"

let headers = lex (many (lex header)) >>| Cohttp.Header.of_list <?> "headers"
let body = take_while (fun _ -> true) <?> "body"

let request =
  lift3
    (fun (meth, uri, _) headers body -> { headers; meth; uri; body })
    (lex request_line)
    (headers <|> return (Cohttp.Header.init ()))
    (body <|> return "")

let parse s = parse_string ~consume:Prefix request s
let parse_file filename = Core.In_channel.read_all filename |> parse

type request = {
  headers : Cohttp.Header.t;
  body : Cohttp_lwt.Body.t;
  meth : Cohttp.Code.meth;
  uri : Uri.t;
}

val parse : string -> (request, string) result

val parse_file: string -> (request, string) result
create fixture file
  $ cat >simple.http <<EOF
  > GET http://www.httpbin.org/bearer HTTP/1.1
  > EOF

Check request
  $ cat simple.http
  GET http://www.httpbin.org/bearer HTTP/1.1
  $ req simple.http -f
  Request failed with status 401 Unauthorized
  [22]

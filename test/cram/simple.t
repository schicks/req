create fixture file
  $ cat >simple.http <<EOF
  > GET http://www.httpbin.org/get HTTP/1.1
  > EOF

Check request
  $ cat simple.http
  GET http://www.httpbin.org/get HTTP/1.1
  $ req simple.http | jq .url
  "http://www.httpbin.org/get"

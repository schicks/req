create fixture file
  $ echo -n "GET http://www.httpbin.org/get HTTP/1.1" > simple.http

Check request
  $ cat simple.http
  GET http://www.httpbin.org/get HTTP/1.1
  $ req simple.http | jq .url
  "http://www.httpbin.org/get"

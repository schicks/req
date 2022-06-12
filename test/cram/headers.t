create fixture file
  $ cat >headers.http <<EOF
  > GET http://www.httpbin.org/bearer HTTP/1.1
  > Authorization: Bearer some-token
  > 
  > EOF

Check request
  $ cat headers.http
  GET http://www.httpbin.org/bearer HTTP/1.1
  Authorization: Bearer some-token
  
  $ req headers.http -f
  {
    "authenticated": true, 
    "token": "some-token"
  }
  

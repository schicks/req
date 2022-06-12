create fixture file
  $ cat >body.http <<EOF
  > POST http://www.httpbin.org/anything HTTP/1.1
  > Content-Type: application/json
  > 
  > {
  >   "key": "mapped to value",
  >   "other_key": ["mapped", "to", "array", 1, null]
  > }
  > EOF

Check request
  $ cat body.http
  POST http://www.httpbin.org/anything HTTP/1.1
  Content-Type: application/json
  
  {
    "key": "mapped to value",
    "other_key": ["mapped", "to", "array", 1, null]
  }
  $ req body.http -f | jq .data
  "Content-Type: application/json\n\n{\n  \"key\": \"mapped to value\",\n  \"other_key\": [\"mapped\", \"to\", \"array\", 1, null]\n}\n"

# Req

I like saving requests to files so that I can version them and iterate on them. I don't like having to download and install Postman just to make HTTP requests. `req` makes HTTP requests from files following the [HTTP standard](https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html) so I can pipe the results right into other tools.

## Installation
TODO
## Usage
TODO
## Contributing
### Setting up a local environment
- `opam switch create . 4.13.1`
- `opam install . --deps-only --with-test`
- `opam install ocaml-lsp-server` (For VS Code)
### Running tests
`dune test`
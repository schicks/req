(lang dune 3.2)

(name req)

(generate_opam_files true)

(source
 (github schicks/req))

(authors "Sam Schick")

(maintainers "Sam Schick")

(license MIT)

; (documentation https://url/to/documentation)
(cram enable)

(package
 (name req)
 (version 1.0.0)
 (synopsis "A curl like tool that can run requests from files")
 (description
  "I like saving requests to files so that I can version them and iterate on them. I don't like having to download and install Postman just to make HTTP requests. `req` makes HTTP requests from files following the [HTTP standard](https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html) so I can pipe the results right into other tools.")
 (depends
  ocaml
  dune
  core
  (ocaml-lsp-server :with-dev)
  core_bench
  angstrom
  cohttp
  cohttp-lwt-unix
  (alcotest :with-test))
 (tags
  (cli curl http)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project

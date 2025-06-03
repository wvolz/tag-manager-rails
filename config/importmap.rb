# Pin npm packages by running ./bin/importmap

pin "application"
pin "popper", to: "popper.js", preload: true
pin "bootstrap", to: "bootstrap.min.js", preload: true # @5.2.3
pin "local-time" # @3.0.3

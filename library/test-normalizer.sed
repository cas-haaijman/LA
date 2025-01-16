# locations in Fail, replace foo/bar/baz.v with ./tests/baz.v
s|^File.*/([^/]*)\.v(.*)|File "./tests/\1.v\2|
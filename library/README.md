# LnA Library

This library is created for the Radboud University Computing Science course 'Logic and Applications'. The [`LnA.v`](https://github.com/logic-and-applications/rocq-lna/blob/main/library/LnA.v) file is based on coq files called `BenB.v`, `BenB2.v`, which were created for a an older version of coq and no longer compile. The additional Kripke-files still work and did not need to be changed.

## Making Changes for Maintainers

For maintainers of this project it is important to know a few things:

1. The two methods of installing the LnA package.
2. How the library is tested.

### `opam` as Installation Method

The `library` subdirectory of this repository is set up to be compilable using [`opam`], the OCaml package manager. Here are some explanations of what each relevant file does in this process:

- `LnA.opam` is the package definition file for an opam package. It contains some metadata, some dependencies and the commands to run to install the package.
  - The line https://github.com/logic-and-applications/rocq-lna/blob/23fdc7de135023b67ca69cd0f9b02c3f86da8963/library/LnA.opam#L19
    indicates that the latest version of Rocq/Coq is compatible and will be installed by default. If there are other opam packages installed with a different version of Rocq, opam will keep or install that version, or fail the installation of `LnA` if the Rocq version is below 8.19.
  - Additionally, `vscoq-language-server` is currently a dependency. Technically, this package is only required to run VsCoq and is not strictly a dependency. If the use case of this library changes to no longer only use VsCoq, this dependency should perhaps be removed and added separately in both the installation instructions and the `release_builder` workflow.
  - It is configured to run `make` and `make install` when installing the library.
- `Makefile` is configured to run `coq_makefile` with the correct options when simply running `make` with no target. It also provides a `make clean` target, which removes all the created files from running `make`.
- `_CoqProject` is passed to the `coq_makefile` program, which compiles the files listed in `_CoqProject` to coq `.vo`, `.vok`, etc files. These files are the ones needed when importing a Rocq library.

### The Windows Installer as Installation Method

The windows installer is set up to be as similar as possible to the `opam` setup, which is done by using `opam` when creating the installer in the [`release_builder.yml`](../.github/workflows/release_builder.yml) workflow. Differences may arise between the installer and installing through `opam` because of the way the dependencies are configured. The installer only checks the most recent version of Rocq when creating the installer through Github Actions, not when running the installer on a Windows machine. It might be wise to either create a new version of the installer by [creating a new release](https://github.com/logic-and-applications/rocq-lna/blob/main/installer/README.md#creating-a-release) whenever a new version of Rocq is added to the opam repository, or to fix the Rocq version in the dependencies.

### Testing

When committing any changes to the `library` subdirectory, the [`test_library.yml`](../.github/workflows/tests_library.yml) is run each time to see if any semantics still behave as expected. This is done by running

```shell
make -f Makefile.local.test
```

from the `library` subdirectory. This runs a Makefile based on the [`Makefile.coq.local`](https://gitlab.mpi-sws.org/iris/iris/-/blob/master/Makefile.coq.local) file from [Iris](https://gitlab.mpi-sws.org/iris/iris/). It is used to automatically run coqc on the test `.v` files in the ./tests directory. It then makes user-specific file paths on failures generic using `test-normalizer.sed` and compares the output to the corresponding `.ref` file.

When making changes to the LnA library, run the test makefile locally and check if all the changes reported by this test run are behaving as expected. Fix any bugs that may occur. Once everything functions as expected, you can update the `.ref` files to the new expected output by running

```shell
make -f Makefile.local.test MAKE_REF=1
```

<!-- links -->

[`opam`]: https://opam.ocaml.org/

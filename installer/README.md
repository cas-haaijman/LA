## How to change the Rocq/Coq versions

The [`release_builder.yml`] workflow contains a job called `build-windows-installer`. Under this job look for `strategy > matrix`. Here we define an environment variable. The environment variable `coq-platform-pick` refers to the name of a [`package_pick`] file in [Coq Platform]. These files are collections of versions of coq and their matching libraries. For example, to change the version of Rocq/Coq to 8.20, look for the [`package_pick`] file containing 8.20. The end of that file name from the version number should then be set as this environment variable. In the case of coq version 8.20, this becomes `8.20~2025.01`.

Additionally, replace the `depends` property in [LnA.opam](/library/LnA.opam) with the new Rocq version, so just `"8.20"` for the example. Ensure locally that the version of `vscoq-language-server` works well with this new version of Coq/Rocq by manually running the tests as described in [the dedicated paragraph](https://github.com/logic-and-applications/rocq-lna/tree/main/library#testing). If it does not, ensure that our own extension still works with the version of `vscoq-language-server` that is supported and update both this opam file and possibly the extension.

### Creating a release

Once everything is ready, you can either run the workflow manually or preferably create a tagged commit containing a version number. Do this by running the following script with the new release version number (e.g., `v1.0.0` instead of `<version tag>`).

```shell
git tag <version tag>
git push origin <version tag>
```

This tag must be of the form `v*.*.*` or the workflow will not trigger. Once this workflow is complete, it will have created three artifacts, which will be visible in the `Actions` tab on github. It will also have created a new [Release](https://github.com/logic-and-applications/rocq-lna/releases), containing these artifacts.

## Explanation of building the windows installer

The [`release_builder.yml`] workflow contains a job called `build-windows-installer`.

```
   EH: 'On this environment it and we then install all our Coq libraries' is clearly not a
   good sentence, but what did you want to say? 'Within this cygwin environment we then install
   all our Coq libraries'?
```

In short, this job uses [Coq Platform] to install [cygwin](https://cygwin.com/) to emulate a unix-like environment. Within this cygwin environment we then install Rocq, Coqide and all our additional libraries and their dependencies. After everything is installed, it creates a windows installer from this environment.

More specifically, the steps of this job do the following:

1. **Set git to use LF**:

   Ensures all files retrieved by future checkouts in this job use unix-style newline characters (`\n`, instead of `\r\n`). This is required for running custom scripts in the cygwin shell.

2. **Git checkout install scripts**:

   Retrieves this git repository and stores it under the `/main` subdirectory.

3. **Git checkout coq platform**:

   Retrieves the entire [Coq Platform] repository and stores it under the `/platform` repository

4. **Set switch name in coq platform**:

   Modifies the [`coq_platform_switch_name.sh`](https://github.com/coq/platform/blob/main/package_picks/coq_platform_switch_name.sh) file to change the coq switch name from a generic coq platform switch to our switch name `LnA`.

   We have to modify the file this way, as it will be used by coq platform scripts later by `platform/coq_platform_make_windows.bat`.

5. **Set default install directory**:

   Modifies the `platform/windows/Coq.nsi` to change the default installation directory seen in the final installer to `C:\cygwin_LnA\home\runneradmin\.opam\\\LnA`. This matches the installation directory created by running `platform/coq_platform_make_windows.bat`.

   Specifically, `runneradmin` is the user name of the github actions environment, `cygwin_LnA` is the cygwin directory we will give to coq platform and `LnA` is the switch name.

   The `platform/windows/Coq.nsi` file is used by the `platform/windows/create_installer_windows.sh` script.

6. **Run coq platform make windows**:

   runs the `platform/coq_platform_make_windows.bat` script to first install cygwin, and then a few libraries. The arguments given do the following:

   - `-destcyg=C:\cygwin_LnA`: Sets the directory cygwin will be installed in.
   - `-arch=64`: The architecture to build for. It is hardcoded to be 64, as it is the only architecture that is still supported by the most recent versions of coq platform.
   - `-extent=i`: The set of coq libraries to install. `-i` installs `coq`, `coqide` and their dependencies. There is a more minimal flag, `x`, but at the time of writing this crashes the script. Additionally, the icon from coqide is used by the `windows/create_installer_windows.sh` script. It is possible to modify this script to not use this. If you remove both the lines copying `source/coqide/ide/coqide/coq.ico` from `windows/create_installer_windows.sh` and also all references to coqide in `Coq.nsi`, it should simply start to use the default icon for [nsis] installers. This should be done to the files in the cygwin directory after installation, however. Look at the [`patch_installer.sh`] script to see a similar example.
   - `-pick`: The [`package_pick`] file to load. Essentially this picks the version of Rocq/Coq to install.
   - `-set-switch=y`: answers 'y' to all questions asked during the process
   - `-compcert=n`: Tells coq platform not to build compcert.
   - `-parallel=p`: Allow parallelization during installation.
   - `-jobs=2`: Amount of jobs for parallelization.
   - `-vst=n`: Tells coq platform not to build Verified Software Toolchain

7. **Patch installer**:

   Patches the `windows/create_installer_windows.sh` file in the cygwin directory by copying `installer/patch_installer.sh` to that directory and running it. The `create_installer _windows` script assumes `-compcert=y` was set during the previous step and this fixes it. If, in the future, other patches need to be made, this is probably the place to add those patches.

8. **Install LnA**:

   Installs our library and all its dependencies on the cygwin directory such that they are added to the installer in the next step. The `depends` field in the [`LnA.opam`](/library/LnA.opam) file configures what the dependencies are that are installed along with it. This process already installed Rocq/Coq, so that is skipped here. However, `vscoq-language-server`, is installed now because of the dependency in this step.

9. **Create installer**:

   Creates the installer by running `windows/create_installer_windows.sh` in the cygwin directory. Once this is done it is copied to `/installer/`, which is a location more easily accessible for next steps.

10. **Sign the installer**:

    This step is currently commented out, but is an example of how to sign the installer once we obtain a certificate. This certificate must, of course, not be pushed to this repository. The `secrets` environment variables can instead be set by the repository owner under `Settings > Security > Secrets and variables > Actions`.

11. **Upload Artifact**:

    Uploads the installer under the name `LnA-Windows-installer` to github as an artifact. Once this step is complete it will show up in github under the `Actions` tab by navigating to this workflow and scrolling down to `Artifacts` at the bottom of the page. While normally jobs are isolated environments, this step also enables use of the created installer file in later jobs. We do this in the `release` job, for example. The `release` job is only allowed to start after this job is finished, because this `upload` job is one of the jobs in the `needs` list seen in the `release` job.

<!-- Links -->

[Coq Platform]: https://github.com/coq/platform
[nsis]: https://nsis.sourceforge.io/Main_Page
[`patch_installer.sh`]: /installer/patch_installer.sh
[`package_pick`]: https://github.com/coq/platform/tree/main/package_picks
[`release_builder.yml`]: /.github/workflows//release_builder.yml

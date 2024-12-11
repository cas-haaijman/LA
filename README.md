# Roqc-lna README

This repository is created for the Radboud University Computing Science course 'Logic and Applications' to create a rocq environment where the tactics match as closely as possible to logical rules taught in this course.

## Installation guide

This guide is written to use [Visual Studio Code] (VS Code) as an editor. If you prefer not to send any telemetry, [VSCodium] should work, just replace all instances of `code` in this guide with `codium`.

1. First make sure you have a working installation of [Visual Studio Code].
2. Check if the editor can be accessed with the shell of your choice by running `code -v`
   - If you have a working installation of VS Code, but `code -v` does not work, you might have to add the installation directory to your PATH environment variable.
3. Install `vscoq-language-server` and our `LnA` package.

   - Windows users can download our custom installer from our [latest release] page.
     DO NOT CHANGE THE INSTALLATION LOCATION. For more information on using this installer, got to the [dedicated section](#using-the-installer-for-windows-users) for using the installer on this page.

   - Linux and Apple users can manually install the prerequisite packages through `opam`.

     1. Apple users only: install `gpatch` using `brew install gpatch`
     2. Install `opam` from the shell of your choice, for example for Apple users:

        ```shell
        brew install opam
        ```

        Ubuntu users

        ```shell
        apt install opam
        ```

        etc.

     3. Install vscoq-language-server version 2.2.1 through opam by running
        ```shell
        opam pin add -y vscoq-language-server.2.2.1 https://github.com/coq-community/vscoq/releases/download/v2.2.1/vscoq-language-server-2.2.1.tar.gz
        ```
     4. Download and install our custom LnA libarary through opam by running
        ```shell
        opam pin add -y LnA.1.0 ttps://github.com/logic-and-applications/rocq-lna/releases/download/v1.0/LnA.1.0.tar.gz
        ```

4. Install the 2.2.1 version of the [`vscoq`] extension

   - Optionally, this can be done through shell by running

   `code --install-extension maximedenes.vscoq@2.2.1`

   - For windows users, opening VS Code with this extension active for the first time will probably throw up the following error message, ignore it.
     ![Error message throw after installing vscoq, ignore it](images/vscoq-installation-error.png)
     Click it away by pressing `Cancel` and proceed to the next step, where we will solve it.

5. Add the path to the installed location of `vscoqtop` by adding it to the User Settings.
   - Windows users who used the installer can do this by adding the following to the User Settings JSON (press ctrl+shift+P in VS Code and type "User Settings (JSON)", then hit Enter)
     ```json
     {
       "vscoq.path": "C:\\cygwin_LnA\\home\\runneradmin\\.opam\\LnA\\bin\\vscoqtop"
     }
     ```
   - Apple and Linux users can locate the location of vscoqtop by running
     ```shell
     which vscoqtop
     ```
     which they can add to their user settings in the same way
6. Download and install our custom VS Code extension: `LnA-VS-code`.

   1. Go to the [latest release]
   2. Download the `LnA-VS-Code.vsix` file
   3. navigate to the location of the dowloaded file in a shell and run

   ```shell
   code --install-extension LnA-VS-Code.vsix
   ```

If everything worked, you should now be able to open one of our exercises and step through the file using `Alt+DownArrow`, or to the cursor using `Alt+RightArrow`. A second window should open to the right, and it should look similar to the following image:

![An example of a correctly running vscoq installation](/images/running-vscoq.png)

### Using the Installer for Windows Users

Windows users can download our custom installer from our [latest release] page. DO NOT CHANGE THE INSTALLATION DIRECTORY!

1. We have not signed the installer, so windows will give a warning that the application about to be installed is not recognized:
   ![Initial unsigned installer warning](images/initial-unsigned-installer-warning.png)
   Ignore this warning by clicking `More info` and `Run anyway`
   ![Bypassing unsigned installer warning](images/bypassing-unsigned-installer-warning.png)
2. Allow the installer to make changes on your device by clicking `Yes` to enter the installation wizard. Then click past the start and agree to Rocq's user license agreement.
3. Next you may choose which components to install. Of these, only `coqide` is not required for the course. If you do not want `coqide`, uncheck it and click `Next`.

   `coqide` is a dedicated ide created for rocq. You may choose to use this during the course, but it does not provide some of the custom the functionality of our VS Code extension or ProofWeb. To be sure your exercise is allowed for this course, you can copy the file to ProofWeb and check there.
   ![Choosing which components to install](images/choose-components-installer.png)

4. DO NOT CHANGE THE INSTALLATION DIRECTORY! Changing the installation directory can have various strange side effects and will likely not work. Simply click `Install` at this step.
   ![DO NOT CHANGE THE INSTALLATION DIRECTORY!](images/do-not-change-the-installation-directory.png)
5. Continue with step 4 from the [Installation Guide](#installation-guide).

<!-- Links -->!

[Visual Studio Code]: https://code.visualstudio.com/download
[VSCodium]: https://github.com/VSCodium/vscodium/releases
[`vscoq`]: https://marketplace.visualstudio.com/items?itemName=maximedenes.vscoq
[latest release]: https://github.com/logic-and-applications/rocq-lna/releases/latest

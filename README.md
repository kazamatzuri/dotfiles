The applications in setup-mac-os.sh:install_appstore_apps have to be on your appstore account, otherwise the download will fail. 

Unfortunately this is not a truly unattended install at this point, as it asks for permissions a couple of times, as well as it making you log into your apple account. 


* On a fresh macOS:
	* Setup for a software development environment entirely with a one-liner 🔥
    ```
    curl --silent https://raw.githubusercontent.com/kazamatzuri/dotfiles/master/setup-mac-os.sh | bash
    ```
* Execute `bootstrap` function freely which in turn executes the bootstrapping script.

# Skyfalls' Manual Duplex Utility
<sub>Literally can't name things properly</sub>
<hr>
A CUPS backend/virtual printer that provides manual duplex (double-sided printing) functionality.

## Installation
```shell
sudo make install
```

## Dependencies
`poppler-utils`, `zenity` and `perl`.

Most distros have these packages installed out-of-the-box.

## Usage
Add a printer in CUPS with the URI `smdu://<Target Printer Name>`, Use the `Generic PDF Printer` driver.
The "Target Printer" should be your real printing queue. 

Or you can use the `configure.pl` script.

Print a multi-page document to test the functionality. If nothing happens, check `/var/log/cups/error_log`.

You can change the "Flip Paper" message by using a URI query parameter like `?flipMessage=Just+flip+then+over+and+you%27ll+be+fine.`. The message should be urlencoded.

## Security
The backend script will be run with root permissions, so it's important patch security holes. All shell commands in the script should already be using the `system()` or `open()` function in order to prevent shell injection. More information in the blog post.

## Blog Post
For more information, I have a [blog post](https://blog.skyfalls.xyz/p/manual-duplex-on-linux.html) about this project.


#!/usr/bin/python3
# unfortunately, this needs a local installation of Jupyter to work
from notebook.auth import passwd
import sys
print(passwd(algorithm="SHA1"))

# buildScript
Just a script for compiling ROMs.
This script uses *gdrive* (check https://github.com/marshmello61/gdrive) currently for uploading.
Uses *fabianonline's telegram* script (check https://github.com/fabianonline/telegram.sh).

## Flags needed
Run ```. buildScript/build.sh -h``` for help

* **Important flag**
* **-d** or **--device** <device name> :    for device name
   Usage: ```. buildScript/build.sh -d <device name>```
   
* **Other flags**
* **-c** or **--clean**        :            for clean build
* **-l** or **--log**          :            to view error log if failed
* **-t** or **--tg**           :            to send telegram messages **set TOKEN and CHAT in telegram script**
* **-u** or **--upload**       :            for uploading build ** *uses gdrive* **
* **-h** or **--help**         :            for help

* **Special flags** (*ONLY* do if you build following rom, or else set paramter in build.sh)
* **--derp**                   :            do this if you build DerpFest
* **--evo**                    :            do this if you build Evolution-X

* Example: ```. buildScript/build.sh -d sanders -c -l -t --derp```

## Needed parameters
Open variables.conf and set the needed parameters for your rom.
* **Note**: If you set DEVICE paramater then *do not* use **-d** or **--device** flag.

* **Note**: If you have not set the TOKEN and CHAT in telegram script,
    *do not* use **-t** or **--tg** flag

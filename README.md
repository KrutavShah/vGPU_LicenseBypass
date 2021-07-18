# vGPU_LicenseBypass
A simple script that works around Nvidia vGPU licensing with a scheduled task.

## Instructions:
* Download the script from the "Releases" tab on this GitHub repository.
* Double click on the script to run it. It will ask for Administrator access, so make sure to press "Yes" to allow.

## What this script does:
* Creates 4 registry values.
  * The first 2 are to change the unlicensed allowed time from 20 to 1440 minutes (1 day).
  * The second 2 are to disable license acquisition notifications from the Nvidia driver.
* Create a scheduled task to restart the Nvidia driver every day at 3 A.M.

## Supported driver versions:
The registry keys that are added by this tool only work in GRID 450 drivers and greater. It has been tested with drivers from 45x.xx to 46x.xx. Note that this script may not work with newer versions of the Nvidia GRID drivers if they choose to patch this workaround in future versions.

The original Powershell component in this script was written by Andrew H. at https://gist.github.com/neg2led and has been modified to suit this script better. \
(C) 2021 Krutav Shah

Note that this script does not modify Nvidia's proprietary binaries in any way whatsoever. Nvidia vGPU & GRID technology is property of NVIDIA Corporation.

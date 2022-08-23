# vGPU_LicenseBypass
A simple script that works around Nvidia vGPU licensing with a scheduled task.

## Instructions:
* Download the zip from the "Releases" tab in this GitHub repository.
* Double click on install.bat to run it. It will ask for Administrator access, so make sure to press "Yes" to allow.

## What this script does:
* Creates 4 registry values.
  * The first 2 are to change the unlicensed allowed time from 20 to 1440 minutes (1 day).
  * The second 2 are to disable license acquisition notifications from the Nvidia driver.
* Create a scheduled task to restart the Nvidia driver every day at 3 A.M.

## Supported driver versions:
The registry keys that are added by this tool only work up to Nividia's vGPU version 14.1 and has been reported to not work on later versions.

The new version of this program has been written by Andrew H. at https://gist.github.com/neg2led.

Note that this script does not modify Nvidia's proprietary binaries in any way whatsoever. Nvidia vGPU & GRID technology is property of NVIDIA Corporation.

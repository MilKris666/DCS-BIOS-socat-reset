# 🛠 Problem: DCS-BIOS loses connection to Arduino Mega on mission restart

## 🧩 Description  
When starting a new mission in DCS World, the USB-connected **Arduino Mega** loses its connection to **DCS-BIOS**. LEDs and displays freeze, and inputs from buttons or encoders stop working — even though the connection was stable before.

## 🧠 Cause  
This issue occurs **when a new mission is loaded**. During this process, DCS internally stops and restarts some systems, which causes the **serial connection to be interrupted**. When using `socat.exe` (or similar tools), this leads to a communication failure with the Arduino. The Arduino essentially locks up, waiting for data that never arrives.

## ✅ Solution: Automatically reset `socat` on mission start  
A PowerShell script monitors the `dcs.log` file in real time and reacts to the start of a new mission. It looks for the following log entries:

- `"Dispatcher (Main): Stop"` → terminates `socat.exe`  
- `"Dispatcher (Main): Start"` **and** `"WORLD (Main): ModelTimeQuantizer: ANTIFREEZE ENABLED"` → restarts the `multiple-com-ports.cmd` script (if `socat` is not already running)

This cleanly reinitializes `socat` **before the Arduino expects new data**, eliminating the need for manual intervention.

> ⚠️ **IMPORTANT:**  
> In order for the Arduino to reconnect properly with DCS-BIOS, the mission must be **fully started and unpaused** *before* the `multiple-com-ports.cmd` script re-establishes the `socat` connection. Otherwise, the Arduino may crash.  
>  
> This script waits for the log entry:  
> `"loadMission Done: Control passed to the player"`  
> and then launches `multiple-com-ports.cmd` **10 seconds later**.  
> This ensures the player is in the cockpit and the mission has started.  
>  
> 👉 **Be sure to unpause the mission right after loading it!**

---

## 📜 Benefits  
- ✅ No need to physically reconnect the Arduino  
- ✅ No more crashes or lockups after switching missions  
- ✅ Script runs in the background with minimal CPU usage

---

## ▶️ How to use the script

1. Open PowerShell (run as Administrator recommended) and enter:

    ```powershell
    Set-ExecutionPolicy Unrestricted
    ```

2. Adjust the paths in the script to match your DCS installation:

    ```powershell
    $logFile = "$env:USERPROFILE\Saved Games\DCS\Logs\dcs.log" 
    $connectCmd = "$env:USERPROFILE\Saved Games\DCS\Scripts\Programs\multiple-com-ports.cmd.lnk"
    ```

3. Create a **shortcut** to your `multiple-com-ports.cmd` file and set its properties to **"Run minimized"**.  
   This ensures the script stays in the background and doesn’t pop up on screen.

---

Feel free to contribute improvements or feedback!

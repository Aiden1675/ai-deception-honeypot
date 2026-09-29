#!/usr/bin/env python3
import subprocess
import time
import os

print("[-] Honey-Credential Monitor Active...")

def check_logs():
    try:
         cmd = "sudo ausearch -k honey_file -ts recent"
         output = subprocess.check_output(cmd, shell=True).decode()

         if "honey_file" in output:
             print("[!!!] ALERT: Honey-file accessed!")
             os.system("echo 'INTRUDER DETECTED' | wall")

    except:
        pass

while True:
    check_logs()
    time.sleep(2)

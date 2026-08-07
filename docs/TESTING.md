# Hardware test procedure

A compatibility test should be done with saved work and adequate battery charge.

1. Install the project.
2. Run `sudo omen-shutdown --doctor` and save the output.
3. Record the battery percentage.
4. Disconnect AC power if safe to do so.
5. Run `sudo omen-shutdown`.
6. Verify that the machine reboots into the UEFI application and powers off.
7. Leave it off for at least 30-60 minutes.
8. Check for residual heat.
9. Boot without the charger and compare the battery percentage.

A successful test should report both the bootloader backend and firmware/laptop model.

Do not claim broad model compatibility from one machine. Firmware implementations vary even within a laptop product family.

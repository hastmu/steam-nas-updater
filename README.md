# steam-nas-updater
Update your steamlibrary at the NAS and no longer over the client.

# Problem statement
If you have multiply clients using your steamlibrary via samba/cifs export on a NAS the update of some games can become quite a trouble as it takes sometimes ages to get completed, especally when only some bytes are patched of a large file.

# Solution
Using steamcmd and the scripts in this repo will scan your NAS steamapps and update them if needed, so IO is taking place at the NAS and not over the network via the clients.

# Status
Currently: PoC 

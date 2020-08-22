# Bucket Head

Bucket Head is a bash script to automate your Rust LGSM server, doing wipes and updates so you can forget about your server management.

Officially created for [Peepo Island](http://peepoisland.eu/) Rust server.

## Features

- Automated wipes
- Scheduling map wipe
- Scheduling blueprint wipe
- Removing plugin data files on wipe
- Automated updates
- Automated Umod(Oxide) update
- Automated Umod(Oxide) group restore after update
- Random map seed generation

## Requirements

Your Rust server should be managed through LGSM

```bash
https://linuxgsm.com/lgsm/rustserver/
```

## Installation

Duplicate configuration files inside the config folder without suffix `.sample` each configuration file contains a description for each config line.  

Add `bhead.sh` to the cronjob list using `bash` executable
```bash
*/5 * * * * /bin/bash /path/to/the/bucket-head/bhead.sh
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
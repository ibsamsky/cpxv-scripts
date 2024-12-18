# Notes

- [Notes](#notes)
  - [Resources](#resources)
  - [Commands / snippets](#commands--snippets)
  
## Resources

- [MITRE ATT&CK](https://attack.mitre.org/)
- [OpenSCAP](https://static.open-scap.org/)
  - Ubuntu [22][ubuntu22], [20][ubuntu20]
- [DoD STIG content](https://public.cyber.mil/stigs/)

[ubuntu22]: https://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-index.html
[ubuntu20]: https://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-index.html

## Commands / snippets

- Find commands
  - `find -O3 -L / -user root \( -perm -4000 -o -perm -2000 \)` - all root-owned setuid and setgid files
  - `find -O3 -L / -type f -perm -o=w` - all world-writable files
- `sudo usermod -Le1 root`, `sudo passwd -l root` - lock and expire the root account

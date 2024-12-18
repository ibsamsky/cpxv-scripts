# Linux

- [Linux](#linux)
  - [Done](#done)
  - [Partial](#partial)
  - [Todo](#todo)

## Done

- [x] Remove hacking tools and potentially unwanted software
- [x] Configure repos/sources
- [x] Update and install software
  - [x] Configure `apt` automatic updates
- [x] User and group management
  - [x] Check for and remove duplicate UID 0 users
  - [x] Change all user passwords
- [x] Remove media files
- [x] Configure firewall using `ufw`

## Partial

- [ ] Configure cron and atd
  - [x] Configure cron.allow and at.allow to only allow root
  - [x] Configure file permissions for cron.d and at.d
  - [ ] Reset cron and atd jobs to default state
- [ ] OS support
  - [x] Ubuntu 20.04
  - [x] Ubuntu 22.04
  - [ ] Fedora (partial)
- [ ] Scan for security vulnerabilities
  - [x] Run `lynis` scan
  - [ ] Set up and run `oscap` (partial)
  - [ ] ...

## Todo

- [ ] Scan for and remove malware
  - [ ] `clamav` scan
  - [ ] `rkhunter` scan
  - [ ] ...
- [ ] Configure services
  - [ ] SSH (sshd)
  - [ ] FTP (vsftpd, etc.)
  - [ ] Samba
  - [ ] GDM and LightDM (!)

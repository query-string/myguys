# Spyguys

## Slack integration
- [ ] Slack-it (Web UI):
    - [x] Send personal photo
    - [x] Basic markup for personal photos
    - [x] Mention username (if defined)
    - [x] Mention status (if defined)
    - [x] Implement some UI feedback if photo has been posted
    - [x] Personal photo
    - [ ] Group photo
    - [ ] Show Slack button only if Slack integration enabled
- [ ] Bot channel:
    - [ ] Personal photo (@higuys: show me/us @alex)
        - [x] Get asking username
        - [x] Post requested user photo
        - [x] Extact logic from rake to class
        - [x] me/us command parser
        - [ ] Handle cases when no one of mentioned users in hg at the moment
    - [ ] Group photo (@higuys: show me/us @channel)
- [ ] Bot PM: (show me @alex)
    - [ ] Personal photo (show me/us @alex)
    - [ ] Group photo (show me/us @channel)
- [ ] Slash commands:
    - [ ] Personal photo (/higuys show me/us @alex)
    - [ ] Group photo (/higuys show me/us @channel)
- [ ] Reminders:
    - [ ] Ping channel if nobody is active more than X hours
    - [ ] Ping channel if only X people are active
- [ ] Favorite photo
- [ ] Write specs

## Common tweaks
- [ ] Pusher listens for status changes too
- [ ] Changeable header colors
- [ ] Personal domain for wall

## Archive

- [ ] Bot commands:
    - [ ] Ask somebody's photo from Slack (@higuys: show me @alex)
    - [ ] Ask group photo (@higuys: show me @channel)
    - [ ] Ask about help
    - [ ] Bot request must work inside PM too
- [ ] Slash commands:

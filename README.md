# interference

A page that glitches when another phone comes near, after [Jakub Antalik's](https://x.com/Jakubantalik/status/2120922067113558172). The phone's magnetometer feels the magnets in the phone beside it.

A browser can't read the magnetometer, so this small iOS app shows the page ([interference.bassim.run](https://interference.bassim.run)) and feeds it the readings, sixty a second: `magnet(x, y, z, turn)`, the field in µT on the phone's axes and how fast the phone turns. The page works out which edge the other phone is at from what it learned when you held it at each edge.

`scripts/phone` builds it with [xtool](https://github.com/xtool-org/xtool), signs it on a Mac and puts it on [hangar](https://github.com/AVGVSTVS96/hangar).

MIT

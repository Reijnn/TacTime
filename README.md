# TacTime

A Garmin Connect IQ widget that shows the military Date-Time Group (DTG) and your MGRS grid position at a glance.

```
301412AOCT26
31U FT 4533 7324
```

- **DTG** in local time (with its NATO zone letter, e.g. `A` for UTC+1) or Zulu (UTC), chosen in the settings. Time zones that are not a whole hour, or beyond ±12, use `J`.
- **MGRS** at 8 digits (10 m). The full screen turns GPS on while it is open and shows a live fix in the accent color. The glance shows the last known position, in gray (or with a `~` on black-and-white screens) when it is not a live fix.

## Settings

| Setting | Options |
|---|---|
| Time | Local, Zulu |
| Color | White, Green, Amber, Red, Blue |

## Building

Requires the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and a developer key.

```sh
monkeyc -f monkey.jungle -d enduro3 -o bin/TacTime.prg -y <developer_key>      # one device
monkeyc --unit-test -f monkey.jungle -d enduro3 -o bin/test.prg -y <developer_key> && monkeydo bin/test.prg enduro3 -t
monkeyc -e -r -f monkey.jungle -o bin/TacTime.iq -y <developer_key>           # store package
```

## License

MIT, see [LICENSE](LICENSE).

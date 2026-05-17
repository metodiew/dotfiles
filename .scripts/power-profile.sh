#!/bin/bash
profile=$(zenity --list \
  --title="Select Power Profile" \
  --column="Profile" performance balanced power-saver)

[ -n "$profile" ] && powerprofilesctl set "$profile"


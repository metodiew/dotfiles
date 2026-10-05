# rescuetime-export

Pulls the full RescueTime history out of the Analytic Data API into CSV files
for offline analysis. Written because the web UI export is limited and the
monthly reports hide the detail that matters.

## Setup

```
cp .config/rescuetime/env.example ~/.config/rescuetime/env
chmod 600 ~/.config/rescuetime/env
$EDITOR ~/.config/rescuetime/env
```

Key comes from https://www.rescuetime.com/anapi/manage. Leave the
"Allow queries from" field empty: a filled-in IP mask silently rejects
requests from every other machine, including the server running the cron.

## Usage

```
rescuetime-export                          # 2026-01-01 .. today
rescuetime-export 2026-01-01 2026-10-05    # explicit range
FORCE=1 rescuetime-export                  # re-download parts that exist
OUT=/tmp/rt rescuetime-export              # one-off output directory
```

Parts are cached under `$RT_OUT/parts/`. A second run only fetches what is
missing, so extending the range is cheap.

## Output

| File | Contents |
| --- | --- |
| `rt-overview-daily.csv` | daily totals per top-level category |
| `rt-productivity-hourly.csv` | hourly totals per productivity score, -2 to +2 |
| `rt-activities.csv` | ranked applications and sites |
| `rt-documents.csv` | window titles, hourly. The useful one |
| `rt-documents-60s.csv` | same, rows under 60s per hour dropped |

Use the filtered copy for analysis and upload. The full documents file runs
to tens of megabytes; the dropped rows are sub-minute window switches, which
matter only when measuring fragmentation specifically.

## API notes

Earned the hard way, worth not rediscovering:

**Site-level detail lives in `restrict_kind=document`, not `activity`.** The
activity dimension collapses everything in a browser into a single
`google-chrome` row. On a heavy browser user that is a third of all tracked
time, recorded as one opaque block with productivity score 0. The document
dimension carries the real window titles and splits that block into Asana,
mail, Facebook, and the rest.

**The browser extension is not the answer.** RescueTime stopped maintaining
it for Chrome and says so in their own docs. The desktop agent covers Chrome.
If site detail looks missing, the report is wrong, not the collector.

**Month-long document queries return HTTP 504.** Server-side timeout, not a
local one. The script chunks document weekly and everything else monthly.

**Long ranges on other dimensions return an empty body instead of an error.**
Zero rows with HTTP 200. The script treats a header-only response as EMPTY
and deletes the file rather than merging it.

**Minute resolution needs a paid plan.** Hour is enough for time-of-day
analysis. Minute matters only when joining against a manual timer like
Clockify entry by entry.

## Known gaps

Android data goes silent when One UI puts the app into deep sleep. Exclude
RescueTime from battery optimisation and check the mobile totals occasionally;
a run of zero-hour days is the symptom.

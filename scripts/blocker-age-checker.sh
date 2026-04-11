#!/bin/bash
# Increments age of blockers in pp-os/STATUS.md or alerts if stagnant

STATUS_FILE="pp-os/STATUS.md"
TMP_FILE="pp-os/STATUS.md.tmp"

# Check for Day X or X days in blockers
# This is a simple regex search to highlight stagnant items.
# Logic: Find lines under ## BLOCKED or 🔴 ROD ACTION REQUIRED
# If they contain a date like (Apr 8), calculate days since.

today=$(date +%s)

while IFS= read -r line; do
  if [[ $line =~ \(([A-Z][a-z]{2})\ ([0-9]+)\) ]]; then
    month="${BASH_REMATCH[1]}"
    day="${BASH_REMATCH[2]}"
    # Convert to timestamp (assuming current year 2026)
    blocker_date=$(date -j -f "%b %d %Y" "$month $day 2026" +%s 2>/dev/null)
    if [[ $? -eq 0 ]]; then
      diff=$(( (today - blocker_date) / 86400 ))
      if [[ $diff -gt 0 ]]; then
        # Replace or append age
        # Example: (Apr 8) -> (Apr 8, 2 days)
        new_line=$(echo "$line" | sed -E "s/\([A-Z][a-z]{2} [0-9]+\)/\(${month} ${day}, ${diff} days\)/")
        echo "$new_line" >> "$TMP_FILE"
      else
        echo "$line" >> "$TMP_FILE"
      fi
    else
      echo "$line" >> "$TMP_FILE"
    fi
  else
    echo "$line" >> "$TMP_FILE"
  fi
done < "$STATUS_FILE"

mv "$TMP_FILE" "$STATUS_FILE"

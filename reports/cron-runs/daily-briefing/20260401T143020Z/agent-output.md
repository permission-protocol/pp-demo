Daily briefing:

System health is `attention`. The main issue is `daily-log-hygiene-metrics` timing out for 3 consecutive runs. Secondary risk is cron instability from rate limits and unsupported channel configs, but thread state is valid (`46` threads), disk is healthy, and the workspace itself is active.

Active focus remains unchanged: final sprint week for Permission Protocol deploy-gate, with 3 days left to hit `5 external installs + 1 complete loop`. The most important in-flight work is `idea-085` (approval count audit), because it gates `idea-087` (the week 4 decision brief) and informs whether the sprint is actually moving the core KPI: `approval -> pipeline installed`.

Immediate actions:
- Fix the timed-out `daily-log-hygiene-metrics` cron first so daily ops visibility is reliable again.
- Complete `idea-085` today by querying PostHog / PP DB and checking Stripe.
- Use that result to write the week 4 decision brief and decide whether to push harder on external installs or pivot the channel.

Highest-leverage next step: finish `idea-085` today so the Apr 4 decision can be made from real usage data instead of intuition.

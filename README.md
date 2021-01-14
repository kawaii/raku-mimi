# raku-mimi
Custom Discord helper bot for the official MyBB Discord server.

# Configuration

Example configuration file;
```json
{
  "discord-token": "REDACTED",
  "discord-team-roles" : {
     "Community": 799296007103840296,
     "Design": 799296559204401172,
     "Development": 799295886945157220,
     "Devops": 799296927590121522,
     "Management": 799296820018544670,
     "Security": 799296115044384818,
     "Support": 799296287576686612,
     "Web": 799296425501655040
  },
  "site-base-url": "https://mybb.com",
  "community-base-url": "https://community.mybb.com",
  "doc-base-url": "https://docs.mybb.com",
  "team-yaml-url": "https://raw.githubusercontent.com/mybb/mybb.com/gh-pages/_data/team_members.yml",
  "team-yaml-expiry": 300
}
```

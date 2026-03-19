```json
// Example/default ACLs for unrestricted connections.
{
 // Declare static groups of users. Use autogroups for all users or users with a specific role.
 // "groups": {
 // "group:example": ["alice@example.com", "bob@example.com"],
 // },

 // Define the tags which can be applied to devices and by which users.
 "tagOwners": {
 "tag:spark": ["autogroup:member"],
 },

 // Define grants that govern access for users, groups, autogroups, tags,
 // Tailscale IP addresses, and subnet ranges.
 "grants": [
 // Allow all connections.
 // Comment this section out if you want to define specific restrictions.
 {
 "src": ["*"],
 "dst": ["*"],
 "ip": ["*"],
 },
 ],

 // Define users and devices that can use Tailscale SSH.
 "ssh": [
 // Allow all users to SSH into their own devices in check mode.
 {
 "action": "check",
 "src": ["autogroup:member"],
 "dst": ["autogroup:self"],
 "users": ["autogroup:nonroot", "root"],
 },
 // Grant access to the tagged Spark machine for all members AND Charles
 {
 "action": "accept",
 "src": ["autogroup:member", "cgoldber82@gmail.com"],
 "dst": ["tag:spark"],
 "users": ["rpc139", "autogroup:nonroot", "root"]
 }
 ]
}
```
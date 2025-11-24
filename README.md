# mad-secretsanta

A multiplayer Secret Santa resource for FiveM. Players can create groups, add nearby players, and get randomly assigned gift recipients with optional randomised gift suggestions.

Go to a Secret Santa location and open the menu to create a new group. Add nearby players to your group by proximity. Manage your group by removing members or disbanding entirely. When you're ready, finalise the group to assign everyone their Secret Santa. Optionally enable a gift list feature that randomly assigns gift suggestions to each participant. Everyone's notified of their recipient (and gift if enabled), and can check their assignment at the location again if needed.

Configure group size limits, enable/disable the gift list feature, customise gift suggestions, allow command-based menu access, and control whether players can join multiple Secret Santa groups simultaneously.

## Dependencies

- [ox_lib](https://github.com/communityox/ox_lib) (Required)
- [oxmysql](https://github.com/communityox/oxmysql) (Required)
- One of: ox_core, qb-core, qbx_core, or es_extended
- One of: ox_target or qb-target
- Optional: qb-menu (for QB servers), qb-input (for QB input dialogs)

### Debug

Debug prints utilise [ox_lib prints](https://coxdocs.dev/ox_lib/Modules/Print/Shared). To enable debug mode, type in your console `set ox:printlevel "debug"`

### Bridge Systems

The resource uses a modular bridge system for compatibility:

- **Framework Bridge**: ox_core, qb-core, qbx_core, es_extended, custom
- **Notification Bridge**: ox_lib, qb-core, mad-thoughts, custom
- **Target Bridge**: ox_target, qb-target
- **Menu Bridge**: ox_lib, qb-menu & qb-input

All bridges auto-detect and load the appropriate implementation based on what's running on your server.

### Support

Join our [Discord](https://discord.gg/dTNWpmPGyc) community for support.

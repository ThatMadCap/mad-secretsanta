# 🎅 mad-secretsanta 

A multiplayer Secret Santa resource for FiveM. Players can create groups, add nearby players, and get randomly assigned gift recipients with optional randomised gift suggestions.

Go to a Secret Santa location and open the menu to create a new group. Add nearby players to your group by proximity. Manage your group by removing members or disbanding entirely. When you're ready, finalise the group to assign everyone their Secret Santa. Optionally enable a gift list feature that randomly assigns gift suggestions to each participant. Everyone's notified of their recipient (and gift if enabled), and can check their assignment at the location again if needed.

Configure group size limits, enable/disable the gift list feature, customise gift suggestions, allow command-based menu access, and control whether players can join multiple Secret Santa groups simultaneously.

## Preview

<div align="center">
  <img src="https://github.com/user-attachments/assets/5dd6df87-bde0-47d9-959d-80cd3cccb85d" alt="Main Menu" width="400"/>
  <img src="https://github.com/user-attachments/assets/6a2e2418-cbe6-4be9-ac59-28f4164adc93" alt="Group Details" width="400"/>
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/e93e3398-e23f-46c7-8c21-e30e02458bf8" alt="Group Management" width="400"/>
  <img src="https://github.com/user-attachments/assets/e41f802d-52b7-4649-9440-8c67533b1926" alt="Assignment Notification" width="400"/>
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/a5fdcf5f-51a0-4f97-aecc-3ceb0734d546" alt="Ready Confirmation" width="600"/>
</div>

## Dependencies

- [ox_lib](https://github.com/communityox/ox_lib) (Required)
- [oxmysql](https://github.com/communityox/oxmysql) (Required)
- One of: ox_core, qb-core, qbx_core, or es_extended
- One of: ox_target or qb-target
- Optional: qb-menu (for QB servers), qb-input (for QB input dialogs)

### Debug

Debug prints utilise [ox_lib prints](https://coxdocs.dev/ox_lib/Modules/Print/Shared). To enable debug mode, type in your console `set ox:printlevel "debug"`

### Locale

Set your language in your `server.cfg`, example: `setr ox:locale en`, where "en" is replaced with your chosen language based on the locale file you wish to use. Refer to [ISO 639](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) language codes.

English is included by default, copy and replace for your own localisation.

### Bridge Systems

The resource uses a modular bridge system for compatibility:

- **Framework Bridge**: ox_core, qb-core, qbx_core, es_extended, custom
- **Notification Bridge**: ox_lib, qb-core, mad-thoughts, custom
- **Target Bridge**: ox_target, qb-target
- **Menu Bridge**: ox_lib, qb-menu & qb-input

All bridges auto-detect and load the appropriate implementation based on what's running on your server.

### Support

Join our [Discord](https://discord.gg/dTNWpmPGyc) community for support.

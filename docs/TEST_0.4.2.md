# PROJECT TERM 0.4.2 quick test

Use the complete 0.4.2 ZIP, exit/restart the game, and keep only PROJECT TERM - Future War (ProjectTermModPackB42) enabled for your test save.

1. Confirm `v0.4.2` in console.txt and no ammo registry exception. Haze strength should stay familiar; F8 and the right-click atmosphere toggle should both work.
2. Right-click **Give Arc Pulse Rifle kit**. Equip, aim, fire, reload, drop and pick up the rifle. Check its size and whether the grip lines up with the hands. Take a screenshot while aiming if alignment is off. All new model faces are preserved; no further geometry reduction was applied.
3. Right-click **Enable extra test controls**, then right-click again. Play machine ambience: it should make an eight-second distant turbine cue. If unavailable, the warning now identifies the missing sound file instead of throwing an exception.
4. Place skull/chassis, then clean them up. Only one pair is permitted; moved items should be returned to the recorded tile or main inventory for cleanup.
5. Save/reload, check the controls again, and provide the fresh console. Existing world map errors are tracked separately from Project Term errors.

The Arc Pulse grip is calibrated from the source model and vanilla model axes but still needs this actual in-game check. The Iron Viper and Ironstorm exports are repaired assets, not new playable weapons yet.

If files may have been missed during copying, run tools/verify_install.py with the ZIP's matching .manifest.json; every packaged file should match. Do not install a source-only Git download as the playable build.

# Project Term Mod Pack

A Project Zomboid Build 42 future-war conversion prototype focused on a ruined post-nuclear world occupied by machines.

## Current status

The repository now has a valid Build 42 skeleton and the first prepared 3D asset set.

Implemented/staged:
- Build 42 `42/` + required `common/` structure
- B42 `mod.info`
- 12 prepared Meshy-derived machine/weapon assets
- PZ model declarations
- Arc Pulse Rifle gameplay prototype
- documented Blender/FBX asset pipeline

Not yet proven in-game:
- final model scale/orientation/hand attachments
- plasma VFX/audio
- custom energy-cell ammunition
- gunship flyover behavior
- humanoid machine rigging/AI

## Install for local testing

Copy this repository as a mod folder under:

`C:/Users/<you>/Zomboid/mods/project-term-mod-pack/`

The folder must contain both `42/` and `common/`.

Enable **Project Term Mod Pack** in the Mods menu and activate it for the save being tested.

## First test

1. Start Project Zomboid Build 42.20+.
2. Enable the mod.
3. Start a fresh debug/test save.
4. Use debug item tools to add `ProjectTerm.ArcPulseRifle`.
5. Also add vanilla `Base.556Clip` magazines and `Base.556Bullets` for this temporary mechanics pass.
6. Equip/fire/reload/drop the rifle.
7. Check `console.txt` for script/model errors.

The rifle intentionally uses vanilla 5.56 mechanics at this stage. Once the custom model is confirmed in hand and on the ground, it will move to custom energy cells and plasma effects.

## Asset pipeline

See `docs/ASSET_PIPELINE.md`.

## Compatibility

Target baseline: Project Zomboid Build 42.20.x. Earlier/later B42 subversions should be treated as unverified until tested.

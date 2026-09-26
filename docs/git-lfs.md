# Git LFS setup

PROJECT TERM keeps code and text files in normal Git and stores large binary assets with Git LFS.

Tracked by LFS:
- 3D source/runtime assets: `*.glb`, `*.gltf`, `*.x`, `*.fbx`
- textures: `*.png`, `*.tga`, `*.dds`
- audio: `*.wav`, `*.ogg`

## One-time setup on Windows

1. Install Git LFS if it is not already installed.
2. Open a terminal in the repository and run:
   `git lfs install`
3. Pull the branch normally in GitHub Desktop.
4. Commit/push assets normally after that. Git LFS handles the binary transfer automatically.

You can verify tracking with:
`git lfs track`

Important: Git LFS rules only affect files committed after the rules exist. Existing large binaries already committed to normal Git history would need migration separately.

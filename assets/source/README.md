# Source assets

Keep original editable models, textures, and audio here when available and licensed for distribution. The original GLBs are not in this checkout. Do not substitute game or film assets.

Local exported assets recovered from the existing test installation are staged in ignored `assets/prepared/{models_X,textures}`. Packaging overlays these exports into `42/media/`. They are not source masters and have not yet passed the in-game scale/attachment gate. A clean clone needs this prepared export directory before packaging; validation fails rather than shipping missing model references.

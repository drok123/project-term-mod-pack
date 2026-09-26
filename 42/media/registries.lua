-- Build 42.13+ registry declarations.
-- Custom AmmoType ids must be registered before item scripts are parsed.
local arc_charge_key = ItemKey.new("ArcCharge", ItemType.NORMAL)
AmmoType.register("projectterm:arc_charge", arc_charge_key)

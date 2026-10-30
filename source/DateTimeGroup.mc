import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;

// Local or Zulu DTG per the "show" setting (0 local, 1 Zulu), in the accent color
(:glance)
function drawDtg(dc as Dc, x as Number, y as Number, font as FontType, justify as Number) as Void {
    var now = Time.now();
    var local = Properties.getValue("show") != 1;
    var text = local ? dateTimeGroup(Time.Gregorian.info(now, Time.FORMAT_SHORT), System.getClockTime().timeZoneOffset)
        : dateTimeGroup(Time.Gregorian.utcInfo(now, Time.FORMAT_SHORT), 0);
    dc.setColor(Properties.getValue("color") as Number, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, font, text, justify);
}

// DDHHMM + zone letter + mmmYY for time t at UTC offset off (seconds),
// e.g. 052125ZMAR25 in UTC, 052225AMAR25 local at UTC+1
(:glance)
function dateTimeGroup(t as Time.Gregorian.Info, off as Number) as String {
    var h = off / 3600;

    // Zone letters for UTC-12..UTC+12; J means local time with no zone letter
    var zone = "J";
    if (off % 3600 == 0 && h.abs() <= 12) {
        zone = "YXWVUTSRQPONZABCDEFGHIKLM".substring(h + 12, h + 13);
    }

    var m = (t.month as Number) * 3;
    return t.day.format("%02d") + t.hour.format("%02d") + t.min.format("%02d")
        + zone + "JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC".substring(m - 3, m) + t.year.toString().substring(2, 4);
}

// Current MGRS position in the accent color, marked by markOld() when it is only the last known position
(:glance)
function drawMgrs(dc as Dc, x as Number, y as Number, font as FontType, justify as Number) as Void {
    var info = Position.getInfo();
    var live = info.accuracy >= Position.QUALITY_POOR;
    dc.setColor(live ? Properties.getValue("color") as Number : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    var text = info.accuracy == Position.QUALITY_NOT_AVAILABLE ? "NO FIX" : mgrs(info.position);
    dc.drawText(x, y, font, live ? text : markOld(text), justify);
}

// Color screens mark an old position by drawing it gray
(:glance, :color)
function markOld(text as String) as String {
    return text;
}

// Black-and-white screens draw gray as white, so an old position gets a "~" instead
(:glance, :mono)
function markOld(text as String) as String {
    return text.equals("NO FIX") ? text : "~" + text;
}

(:glance)
function mgrs(loc as Position.Location or Null) as String {
    // Some devices report a missing position as 180,180 (pi radians) instead of null
    if (loc == null || (loc.toDegrees()[0] as Double).abs() > 90) {
        return "NO FIX";
    }
    return formatMgrs(loc.toGeoString(Position.GEO_MGRS));
}

// 8-digit (10 m) MGRS, e.g. "31U FT 4533 7324". The SDK always returns 17 chars like "31U FT 4533373249":
// 5 easting + 5 northing digits as one group; MGRS shortens by truncating, not rounding.
// Polar (UPS) areas come back as "00Z BA ..."; UPS has no zone number, so the "00" is dropped.
(:glance)
function formatMgrs(s as String) as String {
    var grid = s.substring(0, 7);
    if (grid.substring(0, 2).equals("00")) {
        grid = grid.substring(2, 7);
    }
    return grid + s.substring(7, 11) + " " + s.substring(12, 16);
}

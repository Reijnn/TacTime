import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.Test;
import Toybox.Time;

// Run with: monkeyc --unit-test ... && monkeydo <prg> <device> -t

(:debug)
function assertEq(logger as Logger, got as String, want as String) as Void {
    logger.debug(got);
    Test.assertEqualMessage(got, want, got + " != " + want);
}

(:test)
function testDtgZoneLetters(logger as Logger) as Boolean {
    // 5 March 2025 21:25 UTC; only the zone letter depends on the offset here
    var t = Time.Gregorian.utcInfo(Time.Gregorian.moment({:year => 2025, :month => 3, :day => 5, :hour => 21, :minute => 25}), Time.FORMAT_SHORT);
    assertEq(logger, dateTimeGroup(t, 0), "052125ZMAR25");
    assertEq(logger, dateTimeGroup(t, 3600), "052125AMAR25");
    assertEq(logger, dateTimeGroup(t, -5 * 3600), "052125RMAR25");
    assertEq(logger, dateTimeGroup(t, 12 * 3600), "052125MMAR25");
    assertEq(logger, dateTimeGroup(t, -12 * 3600), "052125YMAR25");
    assertEq(logger, dateTimeGroup(t, 19800), "052125JMAR25"); // UTC+5:30 has no letter
    assertEq(logger, dateTimeGroup(t, 14 * 3600), "052125JMAR25"); // beyond +12
    return true;
}

(:test)
function testDtgPadsAndMonths(logger as Logger) as Boolean {
    var t = Time.Gregorian.utcInfo(Time.Gregorian.moment({:year => 2030, :month => 12, :day => 1, :hour => 0, :minute => 5}), Time.FORMAT_SHORT);
    assertEq(logger, dateTimeGroup(t, 0), "010005ZDEC30");
    return true;
}

(:test)
function testMgrs(logger as Logger) as Boolean {
    assertEq(logger, formatMgrs("31U FT 4533373249"), "31U FT 4533 7324");
    assertEq(logger, formatMgrs("00Z BA 0611998170"), "Z BA 0611 9817");
    assertEq(logger, mgrs(new Position.Location({:latitude => 52.0907, :longitude => 5.1214, :format => :degrees})), "31U FT 4533 7324");
    assertEq(logger, mgrs(new Position.Location({:latitude => -85.0, :longitude => 45.0, :format => :degrees})), "B FR 9278 9278");
    assertEq(logger, mgrs(new Position.Location({:latitude => Math.PI, :longitude => Math.PI, :format => :radians})), "NO FIX");
    assertEq(logger, mgrs(null), "NO FIX");
    return true;
}

import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

// Full screen when the glance is opened
class TacTimeView extends WatchUi.View {
    private var _timer as Timer.Timer = new Timer.Timer();
    private var _buzzed as Boolean = false;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        _timer.start(method(:tick), 1000, true);
        _buzzed = false;
        // All satellite systems, with multi-band where the watch has it, for a faster and more accurate fix.
        // shortcut: watches below API 3.3.6 keep the default (GPS only), use :constellations if that matters
        if (Position has :hasConfigurationSupport) {
            var configs = [Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5, Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1];
            for (var i = 0; i < configs.size(); i++) {
                if (Position.hasConfigurationSupport(configs[i])) {
                    Position.enableLocationEvents({:acquisitionType => Position.LOCATION_CONTINUOUS, :configuration => configs[i]}, method(:onPosition));
                    return;
                }
            }
        }
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    function onHide() as Void {
        _timer.stop();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
    }

    // onUpdate reads the fix via Position.getInfo(); the callback redraws and buzzes once when the fix becomes good
    function onPosition(info as Position.Info) as Void {
        if (!_buzzed && info.accuracy == Position.QUALITY_GOOD && Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 300)]);
            _buzzed = true;
        }
        WatchUi.requestUpdate();
    }

    function tick() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth() / 2;
        var h = dc.getHeight() / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var sub = (WatchUi has :getSubscreen) ? WatchUi.getSubscreen() : null;
        // Instinct-style screens have a round subscreen at the top; center the text below it
        if (sub != null) {
            h = (sub.y + sub.height + dc.getHeight()) / 2;
        }
        drawFixBar(dc, sub, Position.getInfo().accuracy);
        var justify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var gap = centerGap(dc);
        drawDtg(dc, w, h - gap - dc.getFontHeight(Graphics.FONT_MEDIUM) / 2, Graphics.FONT_MEDIUM, justify);
        drawMgrs(dc, w, h + gap + dc.getFontHeight(Graphics.FONT_SMALL) / 2, Graphics.FONT_SMALL, justify);
    }
}

// GPS quality in 4 steps, one per Position.QUALITY level (the SDK gives no satellite count).
// Filled steps are thick and colored by the current level, empty steps thin.
// Round screens get a ring along the edge, Instinct-style screens a ring inside the subscreen, rectangles a bar at the bottom.
function drawFixBar(dc as Dc, sub as Graphics.BoundingBox or Null, accuracy as Number) as Void {
    var w = dc.getWidth();
    var pen = w / 40;
    var colors = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN];
    var color = colors[accuracy > 0 ? accuracy - 1 : 0];
    // Without a live fix the next step blinks, to show it is still searching
    var lit = accuracy;
    if (accuracy < Position.QUALITY_POOR && Time.now().value() % 2 == 0) {
        lit++;
    }
    var rect = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE;
    var x = w / 2;
    var y = dc.getHeight() / 2;
    var r = x;
    if (sub != null) {
        pen = sub.width / 12;
        x = sub.x + sub.width / 2;
        y = sub.y + sub.height / 2;
        r = sub.width / 2;
        rect = false;
    }
    for (var i = 0; i < 4; i++) {
        var on = i < lit;
        var p = on ? pen : (pen / 3 > 1 ? pen / 3 : 1);
        dc.setColor(barColor(on ? color : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
        if (rect) {
            dc.fillRectangle(i * w / 4 + pen, dc.getHeight() - p, w / 4 - 2 * pen, p);
        } else {
            dc.setPenWidth(p);
            dc.drawArc(x, y, r - pen / 2 - 1, Graphics.ARC_CLOCKWISE, 85 - i * 90, 5 - i * 90);
        }
    }
    dc.setPenWidth(1);
}

(:color)
function barColor(c as Number) as Number {
    return c;
}

// 1-bit screens draw these colors black, so the bar is all white there and only the step thickness shows the level
(:mono)
function barColor(c as Number) as Number {
    return Graphics.COLOR_WHITE;
}

// Space between the two lines, above and below the center
(:nohands)
function centerGap(dc as Dc) as Number {
    return dc.getHeight() / 24;
}

// The Instinct Crossover parks its physical hands horizontally across the center, so leave room for them
(:hands)
function centerGap(dc as Dc) as Number {
    return dc.getHeight() / 8;
}

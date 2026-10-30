import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Timer;
import Toybox.WatchUi;

// Full screen when the glance is opened
class TacTimeView extends WatchUi.View {
    private var _timer as Timer.Timer = new Timer.Timer();

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        _timer.start(method(:tick), 1000, true);
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    function onHide() as Void {
        _timer.stop();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
    }

    // onUpdate reads the fix via Position.getInfo(), so the callback only triggers a redraw
    function onPosition(info as Position.Info) as Void {
        WatchUi.requestUpdate();
    }

    function tick() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth() / 2;
        var h = dc.getHeight() / 2;
        // Instinct-style screens have a round subscreen at the top; center the text below it
        if (WatchUi has :getSubscreen) {
            var sub = WatchUi.getSubscreen();
            if (sub != null) {
                h = (sub.y + sub.height + dc.getHeight()) / 2;
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var justify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var gap = centerGap(dc);
        drawDtg(dc, w, h - gap - dc.getFontHeight(Graphics.FONT_MEDIUM) / 2, Graphics.FONT_MEDIUM, justify);
        drawMgrs(dc, w, h + gap + dc.getFontHeight(Graphics.FONT_SMALL) / 2, Graphics.FONT_SMALL, justify);
    }
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

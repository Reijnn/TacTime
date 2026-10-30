import Toybox.Graphics;
import Toybox.WatchUi;

(:glance)
class TacTimeGlanceView extends WatchUi.GlanceView {
    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var h = dc.getHeight();
        var justify = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        drawDtg(dc, 0, h / 4, Graphics.FONT_GLANCE, justify);
        drawMgrs(dc, 0, h * 3 / 4, Graphics.FONT_GLANCE, justify);
    }
}

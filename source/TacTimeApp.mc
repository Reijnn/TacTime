import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TacTimeApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new TacTimeView()];
    }

    (:glance)
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [new TacTimeGlanceView()];
    }
}

library angular2.src.render.dom.shadow_dom.native_shadow_dom_strategy;

import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "../view/view.dart" as viewModule;
import "style_url_resolver.dart" show StyleUrlResolver;
import "shadow_dom_strategy.dart" show ShadowDomStrategy;
import "util.dart"
    show
        moveViewNodesIntoParent; /**
 * This strategies uses the native Shadow DOM support.
 *
 * The templates for the component are inserted in a Shadow Root created on the component element.
 * Hence they are strictly isolated.
 */

class NativeShadowDomStrategy extends ShadowDomStrategy {
  StyleUrlResolver styleUrlResolver;
  NativeShadowDomStrategy(StyleUrlResolver styleUrlResolver) : super() {
    /* super call moved to initializer */;
    this.styleUrlResolver = styleUrlResolver;
  }
  attachTemplate(el, viewModule.RenderView view) {
    moveViewNodesIntoParent(DOM.createShadowRoot(el), view);
  }
  Future processStyleElement(
      String hostComponentId, String templateUrl, styleEl) {
    var cssText = DOM.getText(styleEl);
    cssText = this.styleUrlResolver.resolveUrls(cssText, templateUrl);
    DOM.setText(styleEl, cssText);
    return null;
  }
}

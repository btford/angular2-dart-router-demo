library angular2.test.render.dom.shadow_dom.light_dom_spec;

import "package:angular2/test_lib.dart"
    show describe, beforeEach, it, expect, ddescribe, iit, SpyObject, el, proxy;
import "package:angular2/src/facade/lang.dart"
    show IMPLEMENTS, isBlank, isPresent;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/render/dom/shadow_dom/content_tag.dart"
    show Content;
import "package:angular2/src/render/dom/shadow_dom/light_dom.dart"
    show LightDom;
import "package:angular2/src/render/dom/view/view.dart" show RenderView;
import "package:angular2/src/render/dom/view/view_container.dart"
    show ViewContainer;

@proxy
@IMPLEMENTS(RenderView)
class FakeView implements RenderView {
  var boundElements;
  var contentTags;
  var viewContainers;
  FakeView([containers = null]) {
    this.boundElements = [];
    this.contentTags = [];
    this.viewContainers = [];
    if (isPresent(containers)) {
      ListWrapper.forEach(containers, (c) {
        var boundElement = null;
        var contentTag = null;
        var vc = null;
        if (c is FakeContentTag) {
          contentTag = c;
          boundElement = c.contentStartElement;
        }
        if (c is FakeViewContainer) {
          vc = c;
          boundElement = c.templateElement;
        }
        ListWrapper.push(this.contentTags, contentTag);
        ListWrapper.push(this.viewContainers, vc);
        ListWrapper.push(this.boundElements, boundElement);
      });
    }
  }
  noSuchMethod(i) {
    super.noSuchMethod(i);
  }
}
@proxy
@IMPLEMENTS(ViewContainer)
class FakeViewContainer implements ViewContainer {
  var _nodes;
  var _contentTagContainers;
  var templateElement;
  FakeViewContainer(templateEl, [nodes = null, views = null]) {
    this.templateElement = templateEl;
    this._nodes = nodes;
    this._contentTagContainers = views;
  }
  nodes() {
    return this._nodes;
  }
  contentTagContainers() {
    return this._contentTagContainers;
  }
  noSuchMethod(i) {
    super.noSuchMethod(i);
  }
}
@proxy
@IMPLEMENTS(Content)
class FakeContentTag implements Content {
  var select;
  var _nodes;
  var contentStartElement;
  FakeContentTag(contentEl, [select = "", nodes = null]) {
    this.contentStartElement = contentEl;
    this.select = select;
    this._nodes = nodes;
  }
  insert(nodes) {
    this._nodes = nodes;
  }
  nodes() {
    return this._nodes;
  }
  noSuchMethod(i) {
    super.noSuchMethod(i);
  }
}
main() {
  describe("LightDom", () {
    var lightDomView;
    beforeEach(() {
      lightDomView = new FakeView();
    });
    describe("contentTags", () {
      it("should collect content tags from element injectors", () {
        var tag = new FakeContentTag(el("<script></script>"));
        var shadowDomView = new FakeView([tag]);
        var lightDom =
            new LightDom(lightDomView, shadowDomView, el("<div></div>"));
        expect(lightDom.contentTags()).toEqual([tag]);
      });
      it("should collect content tags from ViewContainers", () {
        var tag = new FakeContentTag(el("<script></script>"));
        var vc = new FakeViewContainer(null, null, [new FakeView([tag])]);
        var shadowDomView = new FakeView([vc]);
        var lightDom =
            new LightDom(lightDomView, shadowDomView, el("<div></div>"));
        expect(lightDom.contentTags()).toEqual([tag]);
      });
    });
    describe("expandedDomNodes", () {
      it("should contain root nodes", () {
        var lightDomEl = el("<div><a></a></div>");
        var lightDom = new LightDom(lightDomView, new FakeView(), lightDomEl);
        expect(toHtml(lightDom.expandedDomNodes())).toEqual(["<a></a>"]);
      });
      it("should include view container nodes", () {
        var lightDomEl = el("<div><template></template></div>");
        var lightDom = new LightDom(new FakeView([
          new FakeViewContainer(DOM.firstChild(lightDomEl), [el("<a></a>")])
        ]), null, lightDomEl);
        expect(toHtml(lightDom.expandedDomNodes())).toEqual(["<a></a>"]);
      });
      it("should include content nodes", () {
        var lightDomEl = el("<div><content></content></div>");
        var lightDom = new LightDom(new FakeView([
          new FakeContentTag(DOM.firstChild(lightDomEl), "", [el("<a></a>")])
        ]), null, lightDomEl);
        expect(toHtml(lightDom.expandedDomNodes())).toEqual(["<a></a>"]);
      });
      it("should work when the element injector array contains nulls", () {
        var lightDomEl = el("<div><a></a></div>");
        var lightDomView = new FakeView();
        var lightDom = new LightDom(lightDomView, new FakeView(), lightDomEl);
        expect(toHtml(lightDom.expandedDomNodes())).toEqual(["<a></a>"]);
      });
    });
    describe("redistribute", () {
      it("should redistribute nodes between content tags with select property set",
          () {
        var contentA = new FakeContentTag(null, "a");
        var contentB = new FakeContentTag(null, "b");
        var lightDomEl = el("<div><a>1</a><b>2</b><a>3</a></div>");
        var lightDom = new LightDom(
            lightDomView, new FakeView([contentA, contentB]), lightDomEl);
        lightDom.redistribute();
        expect(toHtml(contentA.nodes())).toEqual(["<a>1</a>", "<a>3</a>"]);
        expect(toHtml(contentB.nodes())).toEqual(["<b>2</b>"]);
      });
      it("should support wildcard content tags", () {
        var wildcard = new FakeContentTag(null, "");
        var contentB = new FakeContentTag(null, "b");
        var lightDomEl = el("<div><a>1</a><b>2</b><a>3</a></div>");
        var lightDom = new LightDom(
            lightDomView, new FakeView([wildcard, contentB]), lightDomEl);
        lightDom.redistribute();
        expect(toHtml(wildcard.nodes()))
            .toEqual(["<a>1</a>", "<b>2</b>", "<a>3</a>"]);
        expect(toHtml(contentB.nodes())).toEqual([]);
      });
      it("should remove all nodes if there are no content tags", () {
        var lightDomEl = el("<div><a>1</a><b>2</b><a>3</a></div>");
        var lightDom = new LightDom(lightDomView, new FakeView([]), lightDomEl);
        lightDom.redistribute();
        expect(DOM.childNodes(lightDomEl).length).toBe(0);
      });
      it("should remove all not projected nodes", () {
        var lightDomEl = el("<div><a>1</a><b>2</b><a>3</a></div>");
        var bNode = DOM.childNodes(lightDomEl)[1];
        var lightDom = new LightDom(lightDomView,
            new FakeView([new FakeContentTag(null, "a")]), lightDomEl);
        lightDom.redistribute();
        expect(bNode.parentNode).toBe(null);
      });
    });
  });
}
toHtml(nodes) {
  if (isBlank(nodes)) return [];
  return ListWrapper.map(nodes, DOM.getOuterHTML);
}

import Observable   from "../utils/observable"

export default class WindowResizeManager extends Observable {

  constructor() {
    super();
    this.registerResizeEventHandler();
    this.registerScrollEventHandler();
  }

  registerResizeEventHandler() {
    this.registerEventHandler("resize", (ev) => {
      this.fire("windowResized", this.windowSize);
    });
  }

  registerScrollEventHandler() {
    this.registerEventHandler("scroll", (ev) => {
      const scrollHeight   = this.contentSize.h;
      const scrollPosition = this.windowSize.h + this.scrollPosition.top;
      if ( (scrollHeight - scrollPosition) <= 200) {
        this.fire("scrolledBottom", {
          height: scrollHeight,
          position: scrollPosition
        });
      }
    });
  }

  registerEventHandler(key, handler) {
    if (window.addEventListener) {
      window.addEventListener(key, handler, false);
    } else {
      window.attachEvent(key, handler);
    }
  }

  get contentSize() {
    const width  = document.body.scrollWidth;
    const height = document.body.scrollHeight;
    return { w: width, h:height };
  }
  get windowSize() {
    const width  = (window.innerWidth||document.documentElement.clientWidth||0);
    const height = (window.innerHeight||document.documentElement.clientHeight||0);
    return { w: width, h:height };
  }
  get scrollPosition() {
    const doc = document.documentElement;
    return {
      left:  window.pageXOffset || doc.scrollLeft,
      top:   window.pageYOffset || doc.scrollTop
    }
  }
}

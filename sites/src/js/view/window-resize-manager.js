import Observable   from "../utils/observable"

export default class WindowResizeManager extends Observable {

  constructor() {
    super();
    this.registerEventHandler();
  }

  registerEventHandler() {
    const handler = (ev) => {
      this.fire("windowResized", this.windowSize);
    };
    if (window.addEventListener) {
      window.addEventListener("resize", handler, false);
    } else {
      window.attachEvent("resize", handler);
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
}

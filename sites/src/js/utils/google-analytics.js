import ContainerJS from "container-js"
import UUID        from "./uuid.js"

const window = (typeof window === 'object') ? window : {};

export default class GoogleAnalytics {

  constructor() {
    this.localStorage = ContainerJS.Inject;
  }

  initialize() {
    const userId = this.createOrGetUserId();
    this.run((ga) => ga('set', '&uid', userId ));
  }

  sendEvent( action, label="", value={} ) {
    this.run((ga) => ga('send', 'event', this.category, action, label, value));
  }

  createOrGetUserId() {
    const userId = this.localStorage.get("userId");
    if (userId && userId.id) return userId.id;

    const id = UUID.generate();
    this.localStorage.set("userId", {
      id: id
    });
    return id;
  }

  run( f ) {
    if (this.ga) f(this.ga);
  }

  get ga() {
    return window && window.ga;
  }
}

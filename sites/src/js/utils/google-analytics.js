import ContainerJS from "container-js"
import UUID        from "./uuid.js"

const w = (typeof window === 'object') ? window : {};

export default class GoogleAnalytics {

  constructor() {
    this.localStorage = ContainerJS.Inject;
  }

  initialize() {
    const userId = this.createOrGetUserId();
    this.run((ga) => {
      ga('create', 'UA-1267704-16', { 'userId': userId });
      ga('send', 'pageview');
    });
  }

  sendEvent( action, label="", value={} ) {
    this.run((ga) => ga('send', 'event', this.category, action, label, value));
  }
  sendError( message, isFatal  ) {
    this.run((ga) => {
      ga('send', 'exception', {
        'exDescription': message,
        'exFatal': isFatal,
        'appName': this.category,
        'appVersion': this.version
      });
    });
  }
  sendTiming( category, timingVar, time, label ) {
    this.run((ga) => {
      ga('timing', category, timingVar, time, label);
    });
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
    return w && w.ga;
  }
}

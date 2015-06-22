
export default class TimeSource {

  get now() {
    return this.time || new Date();
  }
  set now(now) {
    this.time = now;
  }

}

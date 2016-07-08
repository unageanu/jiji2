
export default class StageUpdater {

  constructor( stage ) {
    this.stage = stage;
  }

  requestUpdate() {
    if (this.request) return false;
    this.request = setTimeout(()=> {
      this.stage.update();
      this.request = null;
    }, 0);
    this.requested = true;
  }

}

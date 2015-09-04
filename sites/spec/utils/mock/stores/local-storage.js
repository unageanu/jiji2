import LocalStorage from "src/stores/local-storage";

export default class MockLocalStorage extends LocalStorage {
  constructor() {
    super();
    this.map = {};
  }
  load( key ) {
    return this.map[key];
  }
  save( key, data ) {
    this.map[key] = data;
  }
  delete( key ) {
    delete this.map[key];
  }
}

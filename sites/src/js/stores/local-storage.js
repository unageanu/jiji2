export default class LocalStorage {
  get( key ) {
    const data = this.load(key);
    return data ? JSON.parse(data) : null;
  }
  set( key, data ) {
    this.save(key, data ? JSON.stringify(data) : null);
  }
  load( key ) {
    return localStorage.getItem(key);
  }
  save( key, data ) {
    localStorage.setItem(key, data);
  }
}

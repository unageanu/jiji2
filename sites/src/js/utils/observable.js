export default class Observable {

  constructor(properties={}) {
    this.properties = properties;
  }

  addObserver(eventName, observer) {
    this.observers(eventName).push(observer);
  }

  fire( eventName, event={} ) {
    this.observers(eventName)
      .forEach(( o )=> o(eventName, event) );
  }

  observers(eventName) {
    return this.observers[eventName]
        || (this.observers[eventName] = []);
  }

  setProperty(key, value, comparator=(a, b) => a === b) {
    const current = this.getProperty(key);
    if (!comparator.call(this, current, value)) {
      this.properties[key] = value;
      this.fire("propertyChanged", {
        key:      key,
        newValue: value,
        oldValue: current
      });
    }
  }
  getProperty(key) {
    return this.properties[key];
  }
}

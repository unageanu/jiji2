import _ from "underscore"

export default class Observable {

  constructor(properties={}) {
    this.properties = properties;
    this.observers  = {};
  }

  addObserver(eventName, observer) {
    this.getObservers(eventName).push(observer);
  }

  fire( eventName, event={} ) {
    this.getObservers(eventName)
      .forEach(( o )=> o(eventName, event) );
  }

  getObservers(eventName) {
    return this.observers[eventName]
        || (this.observers[eventName] = []);
  }

  setProperty(key, value, comparator=_.isEqual) {
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

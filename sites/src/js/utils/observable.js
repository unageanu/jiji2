import _ from "underscore"

function getOrCreateEntry(map, key, generator=()=>[]) {
  if (map.has(key)) {
    return map.get(key);
  } else {
    const entry = generator();
    map.set(key, entry);
    return entry;
  }
}

class References {
  constructor() {
    this.refs = new Map();
  }
  register(eventName, observer) {
    getOrCreateEntry( this.refs, eventName ).push(observer);
  }
  forEach( f ) {
    this.refs.forEach( f );
  }
}

export default class Observable {

  constructor(properties={}) {
    this.properties = properties;
    this.observers  = new Map();
    this.observerReferences = new WeakMap();
  }

  addObserver(eventName, observer, receiver=null) {
    getOrCreateEntry(this.observers, eventName).push(observer);
    if (receiver) this.registerReference(eventName, observer, receiver);
  }
  removeObserver(eventName, ...observers) {
    const set = new Set(observers);
    const newObservers =
        getOrCreateEntry(this.observers, eventName)
        .filter( (item) => !set.has(item) );
    this.observers.set(eventName, newObservers);
  }

  removeAllObservers(receiver) {
    this.getReferences(receiver).forEach((value, key) => {
      this.removeObserver.apply(this, _.flatten([key, value]));
    });
  }

  registerReference(eventName, observer, receiver) {
    this.getReferences(receiver).register(eventName, observer);
  }
  getReferences(receiver) {
    return getOrCreateEntry(this.observerReferences, receiver, () => new References());
  }

  fire( eventName, event={} ) {
    getOrCreateEntry(this.observers, eventName)
      .forEach(( o )=> o(eventName, event) );
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

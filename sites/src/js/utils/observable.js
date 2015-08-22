import _              from "underscore"
import {EventEmitter} from "events"

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

export default class Observable extends EventEmitter {

  constructor(properties={}) {
    super();
    this.properties = properties;
    this.observerReferences = new WeakMap();
  }

  addObserver(eventName, observer, receiver=null) {
    this.on(eventName, observer);
    if (receiver) this.registerReference(eventName, observer, receiver);
  }
  removeObserver(eventName, ...observers) {
    observers.forEach( (observer) => this.removeListener(eventName, observer) );
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
    return getOrCreateEntry(
      this.observerReferences, receiver, () => new References());
  }

  fire( eventName, event={} ) {
    try {
      return this.emit( eventName, eventName, event );
    } catch (error) {
      console.log(error);
      console.log(error.stack);
      throw error;
    }
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

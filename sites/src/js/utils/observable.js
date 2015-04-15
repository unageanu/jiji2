export default class Observable {

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

}

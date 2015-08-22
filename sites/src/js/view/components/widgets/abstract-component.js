import React               from "react"

export default class AbstractComponent extends React.Component {

  registerPropertyChangeListener(observable, keys=null) {
    observable.addObserver("propertyChanged",
      this.createObserver(keys), this);
    this.registerObservable(observable);
  }

  createObserver(keys) {
    let base = this.onPropertyChanged.bind(this);
    if (keys) {
      return (k, ev) => {
        if (keys.has(ev.key)) base(k, ev)
      };
    } else {
      return base;
    }
  }

  onPropertyChanged(k, ev) {
    const newState = {};
    newState[ev.key] = ev.newValue;
    this.setState(newState);
  }

  componentWillUnmount() {
    if (!this.observables) return;
    this.observables.forEach((o) => o.removeAllObservers(this));
  }

  collectInitialState(model, keys) {
    const states = {};
    for (var k of keys) {
      states[k] = model[k];
    }
    return states;
  }

  registerObservable(observable) {
    this.observables = this.observables || new Set();
    this.observables.add(observable);
  }

}

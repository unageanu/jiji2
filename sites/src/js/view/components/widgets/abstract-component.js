import React               from "react"

export default class AbstractComponent extends React.Component {

  registerPropertyChangeListener(observable) {
    observable.addObserver("propertyChanged",
      this.onPropertyChanged.bind(this), this);
    this.registerObservable(observable);
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

  collectInitialState(model, ...keys) {
    return keys.reduce((r,k) => {
      r[k] = model[k];
      return r;
    }, {});
  }

  registerObservable(observable) {
    this.observables = this.observables || new Set();
    this.observables.add(observable);
  }

}

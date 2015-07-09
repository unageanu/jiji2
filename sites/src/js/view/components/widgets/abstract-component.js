import React               from "react"

export default class AbstractComponent extends React.Component {

  registerPropertyChangeListener(observable) {
    observable.addObserver("propertyChanged",
      this.onPropertyChanged.bind(this), this);
  }

  onPropertyChanged(k, ev) {
    const newState = {};
    newState[ev.key] = ev.newValue;
    this.setState(newState);
  }
  
}

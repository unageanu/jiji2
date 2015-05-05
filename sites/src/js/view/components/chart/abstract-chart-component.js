export default class AbstractChartComponent {

  constructor( chartModel ) {
    this.chartModel = chartModel;
    this.addObserver();
  }

  addObservers() {}
  attache( stage ) {}
}

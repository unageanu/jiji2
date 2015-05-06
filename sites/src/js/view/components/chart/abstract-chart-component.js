export default class AbstractChartComponent {

  constructor( chartModel ) {
    this.chartModel = chartModel;
    this.addObservers();
  }

  addObservers() {}
  attach( stage ) {}
}

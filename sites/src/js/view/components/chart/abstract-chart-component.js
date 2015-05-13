export default class AbstractChartComponent {

  constructor( chartModel ) {
    this.chartModel = chartModel;
    this.addObservers();
  }

  addObservers() {}
  attach( stage ) {}

  initializeElement(element, stageSize) {
    element.x = element.y = 0;
    element.setBounds( 0, 0, stageSize.w, stageSize.h );
    return element;
  }
}

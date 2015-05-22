import ContainerJS               from "container-js"
import Observable                from "../../utils/observable"
import Numbers                   from "../../utils/numbers"
import Deferred                  from "../../utils/deferred"
import GraphCoordinateCalculator from "./graph-coordinate-calculator"

const defaultColor = "#999";


class Graph {
  constructor(src, coordinateCalculator) {
    this.id     = src.id;
    this.colors = src.colors || [];
    this.type   = src.type;
    this.axises = src.axises || [];

    this.coordinateCalculator =
      GraphCoordinateCalculator.create(this.type, coordinateCalculator);
  }
  resolveColor(index) {
    if ( this.colors.length <= index
      || !this.colors[index]) {
      return defaultColor;
    }
    return this.colors[index];
  }
}

class GraphDataConverter {

  constructor( graph, coordinateCalculator ) {
    this.lines = [];

    this.graph = graph;
    this.coordinateCalculator = coordinateCalculator;
  }
  prepare( allValues ) {
    this.graph.coordinateCalculator.calculateRange(allValues);
  }
  push(values, timestamp) {
    const x = this.coordinateCalculator.calculateX(timestamp);
    values.forEach((v, i) => {
      if (v === null || v === undefined) return;
      if (!this.lines[i]) this.lines[i] = [];
      this.lines[i].push({
        timestamp: timestamp,
        value: v,
        x: x,
        y: this.graph.coordinateCalculator.calculateY( v )
      });
    });
  }
  getLines() {
    return this.lines.map((line, index) => {
      return {
        type:  this.graph.type,
        color: this.graph.resolveColor(index),
        line:  line
      };
    });
  }
  getAxises() {
    return this.graph.coordinateCalculator.calculateAxises(this.graph.axises);
  }
}

export default class Graphs extends Observable {

  constructor( context,
    coordinateCalculator, preferences, graphService) {
    super();
    this.context = context;

    this.preferences          = preferences;
    this.graphService         = graphService;
    this.coordinateCalculator = coordinateCalculator;
  }

  attach(slider) {
    this.slider = slider;
    this.slider.addObserver("propertyChanged", (n, e) => {
      if (e.key === "currentRange") {
        this.currentRange = e.newValue;
        this.update();
      }
    }, this);

    this.currentRange = slider.currentRange;
    this.update();
  }

  unregisterObservers() {
    this.slider.removeAllObservers(this);
  }

  update() {
    if (!this.currentRange) return;
    Deferred.when([
      this.fetchGraphs(this.currentRange),
      this.fetchGraphData(this.currentRange)
    ]).then( (results) => {
      this.updateGraphs(results[0]);
      this.coordinateCalculator.updateDeferred.then(
        () => this.updateGraphData(results[1]));
    });
  }
  fetchGraphs(range) {
    return this.graphService.fetchGraphs(
      range.start,
      range.end,
      this.context.backtestId
    );
  }
  fetchGraphData(range) {
    return this.graphService.fetchGraphData(
      range.start,
      range.end,
      this.preferences.chartInterval,
      this.context.backtestId
    );
  }

  get lines() {
    return this.getProperty("lines");
  }
  get axises() {
    return this.getProperty("axises");
  }
  updateGraphs( graphs ) {
    this.graphs = graphs.reduce(
      (p, c, i) => p.set(c.id, new Graph(c, this.coordinateCalculator)), new Map());
  }
  updateGraphData( data ) {
    try {
    var lines  = [];
    var axises = [];
    data.forEach((graphData) => {
      const converter = new GraphDataConverter(
        this.graphs.get(graphData.id), this.coordinateCalculator );
      converter.prepare(graphData.data);

      graphData.data.map((data) =>
        converter.push(data.values, data.timestamp));

      lines  = lines.concat( converter.getLines() );
      axises = axises.concat( converter.getAxises() );
    });
    this.setProperty("lines", lines);
    this.setProperty("axises", axises);
    } catch (error) {
      console.log(error);
      console.log(error.stack);
    }
  }
}

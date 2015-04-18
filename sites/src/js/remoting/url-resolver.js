export default class UrlResolver {
  resolveServiceUrl( serviceName, parameters={} ) {
    return "../../api/" + serviceName + this.createParameterString(parameters);
  }
  createParameterString( parameters ) {
      var params = [];
      for (let i in parameters) {
          if (!parameters[i]) continue;
          params.push( this.concatKeyValue(i, parameters[i]));
      }
      return params.length > 0 ? "?" + params.join("&") : "";
  }
  concatKeyValue(key, value) {
      return encodeURIComponent(key) + "=" + encodeURIComponent(value);
  }
}

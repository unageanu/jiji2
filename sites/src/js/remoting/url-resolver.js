import _               from "underscore"
import Dates           from "../utils/dates"
import StringFormatter from "../viewmodel/utils/string-formatter"

export default class UrlResolver {
  resolveServiceUrl( serviceName, parameters={} ) {
    return "/api/" + serviceName + this.createParameterString(parameters);
  }
  createParameterString( parameters ) {
      var params = [];
      for (let i in parameters) {
          if (parameters[i] == null) continue;
          params.push( this.concatKeyValue(i, parameters[i]));
      }
      return params.length > 0 ? "?" + params.join("&") : "";
  }
  concatKeyValue(key, value) {
    return encodeURIComponent(StringFormatter.camelCaseToSnakeCase(key)) + "="
      + encodeURIComponent(this.convertValue(value));
  }
  convertValue( value ) {
    if (Dates.isDateLikeObject(value)) {
      return value.toISOString();
    }
    return value;
  }
}

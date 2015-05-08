import Objects         from "../utils/objects"
import StringFormatter from "../viewmodel/utils/string-formatter"
import _               from "underscore"

const ISO8601 = /^\d{1,4}\-\d{1,2}\-\d{1,2}T\d{1,2}\:\d{1,2}\:\d{1,2}(\.\d{1,3})?(Z|[\+\-]\d{1,2}\:\d{1,2})$/;

export default class Transformaer {

  transformResponse(data) {
    return Objects.convert(data, (v, k)=> {
      if (/^(timestamp|.*\_at|start|end)$/.test(k) && ISO8601.test(v) ) {
        const ms = Date.parse(v);
        if (ms) {
          return new Date(ms);
        } else {
          throw new Error("illegal date fromat. key=" + k + " value=" + v);
        }
      }
      return v;
    }, StringFormatter.snakeCaseToCamelCase );
  }

  transformRequest(data) {
    return Objects.convert(data, (v, k)=> {
      if (_.isDate(v)) {
        return v.toISOString();
      }
      return v;
    }, StringFormatter.camelCaseToSnakeCase );
  }
}

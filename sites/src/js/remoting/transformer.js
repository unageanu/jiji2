import Objects         from "../utils/objects";

const ISO8601 = /^\d{1,4}\-\d{1,2}\-\d{1,2}T\d{1,2}\:\d{1,2}\:\d{1,2}(\.\d{1,3})?(Z|[\+\-]\d{1,2}\:\d{1,2})$/;

export default class Transformaer {

  transformResponse(data) {
    return Objects.convert(data, (v, k)=> {
      if (/^(timestamp|.*\_at)$/.test(k) && ISO8601.test(v) ) {
        const ms = Date.parse(v);
        if (ms) {
          return new Date(ms);
        } else {
          throw new Error("illegal date fromat. key=" + k + " value=" + v);
        }
      }
      return v;
    });
  }

}

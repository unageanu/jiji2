import _     from "underscore"
import Dates from "./dates"

export default class Objects {

  static traverseValues(object, fn) {
    Objects.convert(object, fn);
  }

  static convert(object, converter, keyConverter=null, key=null) {
    if ( _.isArray(object) ) {
      return object.map(
          (item) => this.convert(item, converter, keyConverter, key) );
    } else if (_.isFunction(object)
            || _.isDate(object)
            || _.isRegExp(object)
            || !_.isObject(object)
            || Dates.isDateLikeObject(object) ) {
      return converter(object, key);
    } else {
      return _.keys(object).reduce( (r, k) => {
        const newKey = keyConverter ? keyConverter(k) : k;
        r[newKey] = this.convert(object[k], converter, keyConverter, k);
        return r;
      }, {});
    }
  }

}

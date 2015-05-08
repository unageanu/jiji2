import _ from "underscore"

export default class Objects {

  static traverseValues(object, fn) {
    Objects.convert(object, fn, null);
  }

  static convert(object, converter, key=null) {
    if ( _.isArray(object) ) {
      return object.map(
          (item) => this.convert(item, converter, key) );
    } else if (_.isFunction(object)
            || _.isDate(object)
            || _.isRegExp(object)
            || !_.isObject(object) ) {
      return converter(object, key);
    } else {
      return _.keys(object).reduce( (r, k) => {
        r[k] = this.convert(object[k], converter, k);
        return r;
      }, {});
    }
  }

}

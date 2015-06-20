
export default class Collections {

  static toMap( array, keyResolver=(item) => item.id ) {
    return array.reduce((r, s) => {
      r[keyResolver(s)] = s;
      return r;
    }, {});
  }

  static sortBy( array, sortValueResolver=(item) => item ) {
    array.sort((a, b) => {
      return sortValueResolver(a) > sortValueResolver(b) ? 1 : -1;
    });
    return array;
  }

}

import Dates from "src/utils/dates"

const dateComparator = ( a, b ) => {
  if (Dates.isDateLikeObject(a) && Dates.isDateLikeObject(b)) {
    return a.getTime() === b.getTime();
  }
};

export default {
  toEq(util, customEqualityTesters) {
    customEqualityTesters = customEqualityTesters || [];
    customEqualityTesters.push(dateComparator);
    return {
      compare(actual, expected) {
        return {
          pass: util.equals(actual, expected, customEqualityTesters)
        };
      }
    };
  }
}

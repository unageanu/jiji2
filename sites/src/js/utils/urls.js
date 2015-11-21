import Url from "url"

const NOT_ARGUMENT = /^[a-z\-]+$/;

export default class Urls {

  static extractNormarizedPathName(url) {
    const pathName = Url.parse(url, false, true).pathname;
    return pathName.split('/').map((step) => {
      if (!step) {
        return "";
      } else if (NOT_ARGUMENT.test(step)) {
        return step
      } else {
        return "$";
      }
    }).join("/");
  }
}

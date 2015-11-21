import AbstractService from "./abstract-service"

export default class IconService extends AbstractService {

  fetch() {
    return this.xhrManager.xhr( this.serviceUrl(""), "GET");
  }

  post( file ) {
    this.googleAnalytics.sendEvent( "post icon" );

    const formData = new FormData();
    formData.append("file", file);
    return this.xhrManager.xhr(this.serviceUrl(""), "POST", formData, {
      multipart: true
    });
  }

  endpoint() {
    return "icons";
  }
}

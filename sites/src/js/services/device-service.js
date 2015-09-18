import AbstractService from "./abstract-service"

export default class DeviceService extends AbstractService {

  put( uuid, info ) {
    const url = this.serviceUrl( uuid );
    return this.xhrManager.xhr(url, "PUT", info, {isBackground:true});
  }

  endpoint() {
    return "devices";
  }
}

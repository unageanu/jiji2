import AbstractService from "./abstract-service"

export default class DeviceService extends AbstractService {

  put( uuid, info ) {
    this.googleAnalytics.sendEvent(
      "register device", this.createDeviceInfo(info) );
    const url = this.serviceUrl( uuid );
    return this.xhrManager.xhr(url, "PUT", info, {isBackground:true});
  }

  createDeviceInfo(info) {
    if (!info) return "unknown";
    return "" + info.platform
      + " " +  info.model
      + " " +  info.version;
    }

  endpoint() {
    return "devices";
  }
}

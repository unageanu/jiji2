import Observable   from "../utils/observable";

export default class ErrorEventQueue extends Observable {

  constructor() {
    super();
    this.queue = [];
  }

  shift() {
    return this.queue.shift();
  }
  push(errorEvent) {
    if (errorEvent.route == null) {
      if (this.exist(errorEvent)) return;
        // 通信エラー等同じメッセージを複数回出しても意味がないので、
        // 同じエラーがすでにあれば登録しない
      if (this.existRoutingEvent()) return;
        // 画面遷移イベントがある場合は、エラーイベントを追加しない。
        // 遷移した先でメッセージを出しても意味がないため。

      this.queue.push(errorEvent);
    } else {
      this.queue = []; // 他のイベントを全キャンセルして最優先で遷移する。
      this.queue.push(errorEvent);
    }
    this.fire("pushed", {event: errorEvent});
  }

  exist(errorEvent) {
    return this.queue.find((event) => {
      if (errorEvent.message != null) {
        return event.message === errorEvent.message;
      } else {
        return event.route === errorEvent.route;
      }
    }) != null;
  }
  existRoutingEvent() {
    return this.queue.find((event) => event.route != null ) != null;
  }
}

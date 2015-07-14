import ErrorEventQueue from "src/error-handling/error-event-queue"

describe("ErrorEventQueue", () => {

  var queue;

  beforeEach(() => {
    queue = new ErrorEventQueue();
  });

  describe("#shift", () => {
    it("pushで追加したイベントを1つ取り出せる", () => {
      queue.push({message:"a"});
      queue.push({message:"b"});

      expect(queue.shift()).toEqual({message:"a"});
      expect(queue.queue.length).toEqual(1);
      expect(queue.queue).toEqual([{message:"b"}]);
    });
  });

  describe("#push", () => {
    it("イベントを追加できる", () => {
      queue.push({message:"a"});
      expect(queue.queue).toEqual([{message:"a"}]);

      queue.push({message:"b"});
      expect(queue.queue).toEqual([{message:"a"}, {message:"b"}]);
    });

    it("メッセージが同じイベントは無視される", () => {
      queue.push({message:"a"});
      queue.push({message:"b"});
      queue.push({message:"c"});

      expect(queue.queue).toEqual([
        {message:"a"},
        {message:"b"},
        {message:"c"}
      ]);

      queue.push({message:"a"});
      expect(queue.queue).toEqual([
        {message:"a"},
        {message:"b"},
        {message:"c"}
      ]);

      queue.push({message:"b"});
      expect(queue.queue).toEqual([
        {message:"a"},
        {message:"b"},
        {message:"c"}
      ]);

      queue.push({message:"c"});
      expect(queue.queue).toEqual([
        {message:"a"},
        {message:"b"},
        {message:"c"}
      ]);

      queue.push({message:"d"});
      expect(queue.queue).toEqual([
        {message:"a"},
        {message:"b"},
        {message:"c"},
        {message:"d"}
      ]);
    });

    it("ルーティングイベントが追加されると他のイベントは破棄される", () => {
      queue.push({message:"a"});
      queue.push({message:"b"});
      queue.push({message:"c"});

      expect(queue.queue).toEqual([
        {message:"a"},
        {message:"b"},
        {message:"c"}
      ]);

      queue.push({route:"d"});
      expect(queue.queue).toEqual([
        {route:"d"}
      ]);

      queue.push({route:"e"});
      expect(queue.queue).toEqual([
        {route:"e"}
      ]);
    });

    it("ルーティングイベントが登録されている場合、メッセージイベントは追加されない", () => {
      queue.push({route:"d"});
      expect(queue.queue).toEqual([
        {route:"d"}
      ]);

      queue.push({message:"a"});
      expect(queue.queue).toEqual([
        {route:"d"}
      ]);
    });
  });

});

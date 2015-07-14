import ErrorMessages from "src/error-handling/error-messages"

describe("ErrorMessages", () => {


  it("エラーコードに対応するメッセージを生成できる", () => {
    expect(ErrorMessages.getMessageFor({
      code: "OPERATION_NOT_ALLOWED"
    })).toEqual("操作が許可されていません");

    expect(ErrorMessages.getMessageFor({
      code: "NOT_NULL"
    })).toEqual("値を入力してください");
  });

  it("エラーコードに対応するメッセージが未定義の場合、"
    + "デフォルトのメッセージが生成される", () => {
    expect(ErrorMessages.getMessageFor({
      code: "UNKNOWN_ERROR_CODE"
    })).toEqual("サーバーでエラーが発生しました");

    expect(ErrorMessages.getMessageFor({}))
      .toEqual("サーバーでエラーが発生しました");
  });

  it("パラメータを置換できる", () => {
    expect(ErrorMessages.getMessageFor({
      code: "NOT_NULL",
      field: "ファイル名"
    })).toEqual("ファイル名を入力してください");

    expect(ErrorMessages.getMessageFor({
      code: "NOT_NULL"
    }, {
      field: "ファイル名"
    })).toEqual("ファイル名を入力してください");

    expect(ErrorMessages.getMessageFor({
      code: "NOT_NULL",
      detail: {
        field: "ファイル名"
      }
    })).toEqual("ファイル名を入力してください");

    expect(ErrorMessages.getMessageFor({
      code: "NOT_FOUND"
    })).toEqual("データが見つかりません<br/>"
      + "画面を再読み込みして最新の情報に更新してください");
  });

});

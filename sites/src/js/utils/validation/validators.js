
import ValidatorBuilder from "./validator-builder"

const builder = new ValidatorBuilder();

export default {
  backtest: {
    name: builder.build({
      notNull: true,
      noSpecials : true,
      noExternalCharacters : true,
      noHankakuKana : true,
      maxLength: 200
    }),
    memo: builder.build({
      noSpecials : true,
      noExternalCharacters : true,
      noHankakuKana : true,
      maxLength: 2000
    }),
    pairNames: builder.build({
      notEmpty: true,
      size: 5
    }),
    balance: builder.build({
      notNull: true,
      number: true,
      min: 0
    })
  },

  mailAddress: builder.build({
    notNull: true,
    noSpecials : true,
    noExternalCharacters : true,
    noHankakuKana : true,
    prohibitedCharacter: "\"(),:;<>[\\]!#$&'*^`{|}~",
    maxLength: 100,
    pattern : {
      regexp : /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      code: "PATTERN"
    }
  }),

  password: builder.build({
    notNull: true,
    prohibitedCharacter: "'\\ ",
    alphabet: true,
    minLength: 4,
    maxLength: 16
  }),

  loginUser: builder.build({
    notNull: true
  }),
  loginPassword: builder.build({
    notNull: true
  }),


  all() {
    for (let i=0, n=arguments.length; i<n; i++) {
      if (!arguments[i]) return false;
    }
    return true;
  },
  any() {
    for (let i=0, n=arguments.length; i<n; i++) {
      if (arguments[i]) return true;
    }
    return false;
  }
}

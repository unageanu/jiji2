
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
    startTime : builder.build({
      notNull: true
    }),
    endTime : builder.build({
      notNull: true
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
    agentSetting: builder.build({
      notEmpty: true
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

  smtpServer: {
    host: builder.build({
      notNull: true,
      noSpecials : true,
      maxLength: 1000
    }),
    port: builder.build({
      number : true,
      maxLength: 10
    }),
    userName: builder.build({
      noSpecials : true,
      maxLength: 1000
    }),
    password: builder.build({
      noSpecials : true,
      maxLength: 1000
    })
  },

  serverUrl: builder.build({
    notNull: true,
    noSpecials : true,
    maxLength: 1000,
    pattern : {
      regexp : /^https?\:\/\/.*/,
      code: "PATTERN"
    }
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

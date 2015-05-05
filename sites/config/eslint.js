{
  ecmaFeatures: {
    arrowFunctions                   : true,
    binaryLiterals                   : true,
    blockBindings                    : true,
    classes                          : true,
    defaultParams                    : true,
    destructuring                    : true,
    forOf                            : true,
    generators                       : true,
    modules                          : true,
    objectLiteralComputedProperties  : true,
    objectLiteralDuplicateProperties : true,
    objectLiteralShorthandMethods    : true,
    objectLiteralShorthandProperties : true,
    octalLiterals                    : true,
    regexUFlag                       : true,
    regexYFlag                       : true,
    spread                           : true,
    superInFunctions                 : true,
    templateStrings                  : true,
    unicodeCodePointEscapes          : true,
    globalReturn                     : true,
    jsx                              : true
  },
  env: {
    browser : true,
    amd     : true,
    es6     : true,
    node    : true,
    jasmine : true
  },
  rules: {
    key-spacing        : 0,
    no-trailing-spaces : 0,
    space-infix-ops    : 0,
    eol-last           : 0,
    no-multi-spaces    : 0,

    curly : 0,

    no-use-before-define : 0,
    no-unused-vars       : 0,
    no-underscore-dangle : 0,

    no-console : 0
  }
}

import zhMsgs from './messages/zh.yml';
import jaMsgs from './messages/ja.yml';

import { addLocaleData  } from 'react-intl'
import zh from 'react-intl/locale-data/zh'
import ja from 'react-intl/locale-data/ja'

addLocaleData([...zh, ...ja]);

const messages = {
  zh: zhMsgs,
  ja: jaMsgs
};


export const getMessages = (locale) => {
  if (locale == null) return jaMsgs;
  locale = locale.replace(/\-.*$/, '');
  return messages[locale.toLowerCase()] || jaMsgs;
}

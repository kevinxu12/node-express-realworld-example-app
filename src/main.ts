import { setup } from "@detail-dev/trace";
// Or, if you're using requires:
// const { setup } = require('@detail-dev/trace');

setup({
  localDevMode: true
});

import { app } from './server'

/**
 * Server activation
 */

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.info(`server up on port ${PORT}`);
});

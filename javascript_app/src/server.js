const { createApp } = require("./app");

const DEFAULT_PORT = 3000;

const port = Number.parseInt(process.env.PORT ?? `${DEFAULT_PORT}`, 10);
const app = createApp();

app.listen(port, () => {
  console.log(`Home Monitoring JavaScript app listening on port ${port}`);
});

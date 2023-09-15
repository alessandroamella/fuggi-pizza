import { Printer } from "../printer/print";
import os from "os";

export const settings = {
  serverPort: "3000",
  username: os.userInfo().username,
  printers: [new Printer("Printer", "1fc9", "2016")],
};

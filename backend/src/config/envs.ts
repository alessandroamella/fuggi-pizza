import { cleanEnv, str } from "envalid";

export const envs = cleanEnv(process.env, {
  NODE_ENV: str(),
  DATABASE_URL: str(),
  SUDO_PW: str(),
});

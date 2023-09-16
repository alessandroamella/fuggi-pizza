import { spawn } from "child_process";
import { join } from "path";
import { cwd } from "process";
import { logger } from "../shared/logger";
import async, { retry } from "async";
import { settings } from "../config/settings";
import { Order } from "@prisma/client";

export class Printer {
  public name: string;
  public vendorId: string;
  public productId: string;

  private printQueue: async.QueueObject<string>;

  constructor(name: string, vendorId: string, productId: string) {
    this.name = name;
    this.vendorId = vendorId;
    this.productId = productId;

    this.printQueue = async.queue((text: string, callback: () => void) => {
      this._wait(this.textToPrintTimeMs(text)).then(() => {
        this._print(text)
          .then(callback)
          .catch((err) => {
            logger.error(err);
          });
      });
    }, 1);
  }

  private textToPrintTimeMs(text: string): number {
    return 2000 + text.length;
  }

  public async isConnected(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      retry(
        { times: 60, interval: 5000 },
        (callback) => {
          const process = spawn("sh", [
            join(cwd(), "scripts/printer_is_connected.sh"),
            this.vendorId,
            this.productId,
          ]);

          process.stderr.on("data", (data) => {
            logger.error("Printer stderr:");
            logger.error(data.toString());

            callback(new Error(data.toString()));
          });

          process.on("close", (code) => {
            logger.debug(`isConnected: ${code === 0}`);
            if (code === 0) {
              callback();
            } else {
              callback(new Error(`Process exited with code ${code}`));
            }
          });
        },
        (err) => {
          if (err) {
            logger.error(err);
            return reject(err);
          }
          return resolve(true);
        },
      );
    });
  }

  private async _print(text: string): Promise<void> {
    logger.debug("Print");

    return new Promise((resolve, reject) => {
      retry(
        { times: 5, interval: 5000 },
        (callback) => {
          logger.debug("Print try");

          const process = spawn("sudo", [
            "-u",
            settings.username,
            "python3",
            // const process = spawn("python3", [
            join(cwd(), "scripts/printer_print.py"),
            this.vendorId,
            this.productId,
            text,
          ]);

          process.stdout.on("data", (data) => {
            logger.info("Printer stdout:");
            logger.info(data.toString());
          });

          process.stderr.on("data", (data) => {
            logger.error("Printer stderr:");
            logger.error(data.toString());
            callback(new Error(data.toString()));
          });

          process.on("close", (code) => {
            if (code === 0) {
              callback();
            } else {
              callback(new Error(`Process exited with code ${code}`));
            }
          });
        },
        (err) => {
          if (err) {
            reject(err);
          } else {
            resolve();
          }
        },
      );
    });
  }

  private _addToQueue(text: string): void {
    this.printQueue.push(text);
  }

  private async _wait(number: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, number));
  }

  private async _printWrapper(text: string): Promise<boolean> {
    logger.debug("Print wrapper");

    try {
      if (!(await this.isConnected())) {
        logger.error("Printer is not connected");
        return false;
      } else {
        this._addToQueue(text);
        return true;
      }
    } catch (err) {
      logger.error(err);
      return false;
    }
  }

  public async print(text: string): Promise<boolean> {
    return this._printWrapper(text);
  }

  public async printOrder(order: Order): Promise<boolean> {
    return this._printWrapper(JSON.stringify(order));
  }
}

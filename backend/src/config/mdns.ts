import { spawn } from "child_process";
import exitHook from "exit-hook";
import { logger } from "../shared/logger";
import { settings } from "./settings";

const { mdnsName, mdnsPort } = settings;

export const runMdns = () => {
    const ad = spawn("avahi-publish-service", [mdnsName, "_http._tcp", mdnsPort]);

    logger.info(`mDNS process started with PID ${ad.pid} with command "${ad.spawnargs.join(" ")}"`);

    // print output
    ad.stdout.on("data", data => {
        logger.info(`mDNS service stdout: ${data}`);
    });

    ad.stderr.on("data", data => {
        // avahi è stupido e stampa un messaggio di errore quando il servizio viene creato
        if (
            typeof data.toString === "function" &&
            data.toString().includes("Established under name")
        ) {
            logger.info(
                `mDNS started with name ${data.toString().split(" ")[3]} on port ${mdnsPort}`
            );
        } else {
            logger.error(`mDNS service stderr: ${data}`);
        }
    });

    ad.on("error", err => {
        logger.error(`Error while starting mDNS service: ${err}`);
    });

    ad.on("close", code => {
        logger.info(`mDNS service exited with code ${code}`);
    });

    exitHook(() => {
        logger.info("Killing mDNS service");
        ad.kill();
    });
};

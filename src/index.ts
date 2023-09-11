import Elysia, { t } from "elysia";
import { swagger } from "@elysiajs/swagger";
import { PrismaClient } from "@prisma/client";

const app = new Elysia()
    .use(
        swagger({
            path: "/docs",
            documentation: {
                info: {
                    title: "Fuggi Pizza backend API",
                    contact: { name: "Alessandro Amella", email: "info@bitrey.it" },
                    version: "1.0",
                    description: "Fuggi Pizza backend API"
                }
            }
        })
    )
    .decorate("db", new PrismaClient())
    .group("/table", app => {
        return app
            .model({
                "table.crud": t.Object({
                    number: t.Integer()
                })
            })
            .get("/", async ({ db }) => db.table.findMany())
            .get(
                "/:id",
                async ({ db, params: { id } }) =>
                    await db.table.findUnique({ where: { number: parseInt(id) } })
            )
            .post(
                "/",
                async ({ db, body }) =>
                    db.table.create({
                        data: body
                    }),
                { body: "table.crud" }
            )
            .put(
                "/:id",
                async ({ db, body, params: { id } }) =>
                    db.table.update({
                        where: { number: parseInt(id) },
                        data: body
                    }),
                { body: "table.crud" }
            )
            .delete("/:id", async ({ db, params: { id } }) =>
                db.table.delete({
                    where: { number: parseInt(id) }
                })
            );
    })
    .get("/ping", () => "pong")
    .get("/hello/:name", ({ params }) => `Hello ${params.name}`);

app.listen(3000, () => console.log("Server is running on port 3000"));

import Elysia, { t } from "elysia";
import { swagger } from "@elysiajs/swagger";
import { PrismaClient } from "@prisma/client";
import { logger } from "./shared/logger";
// import { runMdns } from "./config/mdns";
import { settings } from "./config/settings";

// runMdns();

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
                "table.create": t.Object({
                    number: t.Integer(),
                    seats: t.Optional(t.Integer()),
                    notes: t.Optional(t.String())
                })
            })
            .model({
                "table.update": t.Object({
                    seats: t.Optional(t.Integer()),
                    notes: t.Optional(t.String())
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
                { body: "table.create" }
            )
            .put(
                "/:id",
                async ({ db, body, params: { id } }) =>
                    db.table.update({
                        where: { number: parseInt(id) },
                        data: body
                    }),
                { body: "table.update" }
            )
            .delete("/:id", async ({ db, params: { id } }) =>
                db.table.delete({
                    where: { number: parseInt(id) }
                })
            );
    })
    .group("/category", app => {
        return app
            .model({
                "category.create": t.Object({
                    name: t.String()
                })
            })
            .get("/", async ({ db }) => db.category.findMany())
            .get(
                "/:id",
                async ({ db, params: { id } }) =>
                    await db.category.findUnique({ where: { id: parseInt(id) } })
            )
            .post(
                "/",
                async ({ db, body }) =>
                    db.category.create({
                        data: body
                    }),
                { body: "category.create" }
            )
            .put(
                "/:id",
                async ({ db, body, params: { id } }) =>
                    db.category.update({
                        where: { id: parseInt(id) },
                        data: body
                    }),
                { body: "category.create" }
            )
            .delete("/:id", async ({ db, params: { id } }) =>
                db.category.delete({
                    where: { id: parseInt(id) }
                })
            );
    })
    .group("/dish", app => {
        return app
            .model({
                "dish.create": t.Object({
                    name: t.String(),
                    description: t.Optional(t.String()),
                    price: t.Integer(),
                    categoryId: t.Integer()
                })
            })
            .get("/", async ({ db }) =>
                db.dish.findMany({
                    select: {
                        id: true,
                        name: true,
                        description: true,
                        price: true,
                        category: true
                    }
                })
            )
            .get(
                "/:id",
                async ({ db, params: { id } }) =>
                    await db.dish.findUnique({
                        where: { id: parseInt(id) },
                        select: {
                            id: true,
                            name: true,
                            description: true,
                            price: true,
                            category: true
                        }
                    })
            )
            .post(
                "/",
                async ({ db, body }) =>
                    db.dish.create({
                        data: body
                    }),
                { body: "dish.create" }
            )
            .put(
                "/:id",
                async ({ db, body, params: { id } }) =>
                    db.dish.update({
                        where: { id: parseInt(id) },
                        data: body
                    }),
                { body: "dish.create" }
            )
            .delete("/:id", async ({ db, params: { id } }) =>
                db.dish.delete({
                    where: { id: parseInt(id) }
                })
            );
    })
    .group("/order", app => {
        return (
            app
                .model({
                    "order.create": t.Object({
                        tableId: t.Integer(),
                        dishes: t.Array(
                            t.Object({
                                dishId: t.Integer(),
                                quantity: t.Integer(),
                                notes: t.Optional(t.String())
                            })
                        ),
                        paymentDate: t.Optional(t.String()),
                        notes: t.Optional(t.String())
                    })
                })
                // must execute join to get dishes
                .get("/", async ({ db }) =>
                    db.order.findMany({
                        select: {
                            id: true,
                            date: true,
                            paymentDate: true,
                            notes: true,
                            dishes: {
                                select: {
                                    dishId: false,
                                    dish: {
                                        select: {
                                            id: true,
                                            name: true,
                                            price: true
                                        }
                                    },
                                    quantity: true,
                                    notes: true
                                }
                            },
                            table: true
                        }
                    })
                )
                .get(
                    "/:id",
                    async ({ db, params: { id } }) =>
                        await db.order.findUnique({
                            where: { id: parseInt(id) },
                            include: {
                                dishes: {
                                    include: {
                                        dish: true
                                    }
                                }
                            }
                        })
                )
                .post(
                    "/",
                    async ({ db, body }) =>
                        db.order.create({
                            data: {
                                ...body,
                                dishes: {
                                    create: body.dishes
                                }
                            }
                        }),
                    { body: "order.create" }
                )
                .put(
                    "/:id",
                    async ({ db, body, params: { id } }) =>
                        db.order.update({
                            where: { id: parseInt(id) },
                            data: {
                                ...body,
                                dishes: {
                                    create: body.dishes
                                }
                            }
                        }),
                    { body: "order.create" }
                )
                .delete("/:id", async ({ db, params: { id } }) => {
                    await db.orderedDish.deleteMany({
                        where: { orderId: parseInt(id) }
                    });
                    return db.order.delete({
                        where: { id: parseInt(id) }
                    });
                })
        );
    });

app.listen(settings.serverPort, () =>
    logger.info("Server is running on port " + settings.serverPort)
);

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
    .group("/category", app => {
        return app
            .model({
                "category.crud": t.Object({
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
                { body: "category.crud" }
            )
            .put(
                "/:id",
                async ({ db, body, params: { id } }) =>
                    db.category.update({
                        where: { id: parseInt(id) },
                        data: body
                    }),
                { body: "category.crud" }
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
                "dish.crud": t.Object({
                    name: t.String(),
                    description: t.Optional(t.String()),
                    price: t.Integer(),
                    categoryId: t.Integer()
                })
            })
            .get("/", async ({ db }) => db.dish.findMany())
            .get(
                "/:id",
                async ({ db, params: { id } }) =>
                    await db.dish.findUnique({ where: { id: parseInt(id) } })
            )
            .post(
                "/",
                async ({ db, body }) =>
                    db.dish.create({
                        data: body
                    }),
                { body: "dish.crud" }
            )
            .put(
                "/:id",
                async ({ db, body, params: { id } }) =>
                    db.dish.update({
                        where: { id: parseInt(id) },
                        data: body
                    }),
                { body: "dish.crud" }
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
                    "order.crud": t.Object({
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
                        include: {
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
                            }
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
                    { body: "order.crud" }
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
                    { body: "order.crud" }
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

app.listen(3000, () => console.log("Server is running on port 3000"));

import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  // Create some categories
  const pizza = await prisma.category.create({
    data: {
      name: "Pizza",
    },
  });
  const pasta = await prisma.category.create({
    data: {
      name: "Pasta",
    },
  });
  const dessert = await prisma.category.create({
    data: {
      name: "Dessert",
    },
  });

  // Create some dishes
  const margherita = await prisma.dish.create({
    data: {
      name: "Margherita",
      description: "Tomato sauce, mozzarella, basil",
      category: {
        connect: { id: pizza.id },
      },
      price: 8,
    },
  });
  const carbonara = await prisma.dish.create({
    data: {
      name: "Carbonara",
      description: "Spaghetti, eggs, bacon, cheese",
      category: {
        connect: { id: pasta.id },
      },
      price: 10,
    },
  });
  const tiramisu = await prisma.dish.create({
    data: {
      name: "Tiramisu",
      description: "Coffee-flavored dessert with mascarpone cream",
      category: {
        connect: { id: dessert.id },
      },
      price: 5,
    },
  });

  // Create some tables
  const table1 = await prisma.table.create({
    data: {
      number: 1,
      seats: 4,
      notes: "Near the window",
    },
  });
  const table2 = await prisma.table.create({
    data: {
      number: 2,
      seats: 2,
    },
  });
  const table3 = await prisma.table.create({
    data: {
      number: 3,
      seats: 6,
      notes: "Reserved for VIPs",
    },
  });

  // Create some orders
  const order1 = await prisma.order.create({
    data: {
      date: new Date("2023-09-16T18:00:00.000Z"),
      table: {
        connect: { number: table1.number },
      },
      paymentDate: new Date("2023-09-16T19:30:00.000Z"),
      notes: "Customer was satisfied",
      dishes: {
        createMany: {
          data: [
            { dishId: margherita.id, quantity: 2, notes: "Extra cheese" },
            { dishId: carbonara.id, quantity: 1 },
            { dishId: tiramisu.id, quantity: 3, notes: "One with no coffee" },
          ],
        },
      },
    },
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

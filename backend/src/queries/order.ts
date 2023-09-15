export const orderQuery = {
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
            price: true,
          },
        },
        quantity: true,
        notes: true,
      },
    },
    table: true,
  },
};

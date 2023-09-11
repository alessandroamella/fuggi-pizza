/*
  Warnings:

  - The primary key for the `Table` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `Table` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE `Order` DROP FOREIGN KEY `Order_tableId_fkey`;

-- AlterTable
ALTER TABLE `Table` DROP PRIMARY KEY,
    DROP COLUMN `id`,
    ADD PRIMARY KEY (`number`);

-- AddForeignKey
ALTER TABLE `Order` ADD CONSTRAINT `Order_tableId_fkey` FOREIGN KEY (`tableId`) REFERENCES `Table`(`number`) ON DELETE RESTRICT ON UPDATE CASCADE;

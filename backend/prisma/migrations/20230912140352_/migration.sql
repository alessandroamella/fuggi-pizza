/*
  Warnings:

  - You are about to drop the column `capacity` on the `Table` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE `Table` DROP COLUMN `capacity`,
    ADD COLUMN `notes` VARCHAR(191) NULL,
    ADD COLUMN `seats` INTEGER NULL;

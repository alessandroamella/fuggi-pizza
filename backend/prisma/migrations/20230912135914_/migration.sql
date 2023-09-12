/*
  Warnings:

  - Added the required column `capacity` to the `Table` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `Table` ADD COLUMN `capacity` INTEGER NOT NULL,
    ADD COLUMN `isOccupied` BOOLEAN NOT NULL DEFAULT false;

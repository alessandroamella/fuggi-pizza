"use client";

import { EditableTable } from "@refinedev/core";

export type ITable = {
  number: number;
  seats?: number;
  notes?: string;
};

export default function TableList() {
  // Definisci la funzione customColumns
  const customColumns = () => [
    { field: "number", title: "Numero", editable: false },
    { field: "seats", title: "Posti", editable: true },
    { field: "notes", title: "Note", editable: true },
  ];

  return (
    <EditableTable resource="table" action="list" columns={customColumns} />
  );
}

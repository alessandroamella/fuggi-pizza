"use client";

// import { QueryClient, QueryClientProvider } from "react-query";

import { CacheProvider } from "@chakra-ui/next-js";
import { ChakraProvider } from "@chakra-ui/react";

import { notificationProvider, RefineThemes } from "@refinedev/chakra-ui";
import { Refine } from "@refinedev/core";

import routerProvider from "@refinedev/nextjs-router/app";
import dataProvider from "@refinedev/simple-rest";

// const queryClient = new QueryClient();

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    // <QueryClientProvider client={queryClient}>
    <CacheProvider>
      <ChakraProvider theme={RefineThemes.Green}>
        <Refine
          notificationProvider={notificationProvider()}
          dataProvider={dataProvider("http://localhost:5500/api/v1")}
          routerProvider={routerProvider}
          resources={[
            {
              name: "table",
              list: "/table",
              show: "/table/show/:id",
              // create: "/table/create",
              // edit: "/table/edit/:id",
            },
            // {
            //   name: "category",
            //   list: "/category",
            //   show: "/category/show/:id",
            //   create: "/category/create",
            //   edit: "/category/edit/:id",
            // },
          ]}
          options={{
            syncWithLocation: true,
            warnWhenUnsavedChanges: true,
          }}
        >
          {children}
          {/* <UnsavedChangesNotifier /> */}
        </Refine>
      </ChakraProvider>
    </CacheProvider>
    // {/* </QueryClientProvider> */}
  );
}

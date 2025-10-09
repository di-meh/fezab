import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import prisma from "$lib/prisma"
import { sveltekitCookies } from "better-auth/svelte-kit";
import { getRequestEvent } from "$app/server";

export const auth = betterAuth({
    emailAndPassword: {
        enabled: true,
    },
    plugins: [sveltekitCookies(getRequestEvent)],
    database: prismaAdapter(prisma, {
        provider: "postgresql",
    }),
});
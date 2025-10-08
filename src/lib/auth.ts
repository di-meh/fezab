import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import { PrismaClient } from "../generated/prisma";
import { sveltekitCookies } from "better-auth/svelte-kit";
import { getRequestEvent } from "$app/server";

const prisma = new PrismaClient();
export const auth = betterAuth({
    plugins: [sveltekitCookies(getRequestEvent)],
    database: prismaAdapter(prisma, {
        provider: "postgresql",
    }),
});
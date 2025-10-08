import type { Handle } from '@sveltejs/kit';
import { paraglideMiddleware } from '$lib/paraglide/server';
import { svelteKitHandler } from "better-auth/svelte-kit";
import { auth } from "$lib/auth";
import { building } from '$app/environment';
import { sequence } from '@sveltejs/kit/hooks';
import { createTRPCHandle } from 'trpc-sveltekit';
import { router } from '$lib/trpc/router';
import { createContext } from '$lib/trpc/context';

const handleParaglide: Handle = ({ event, resolve }) => paraglideMiddleware(event.request, ({ request, locale }) => {
	event.request = request;

	return resolve(event, {
		transformPageChunk: ({ html }) => html.replace('%paraglide.lang%', locale)
	});
});

const handleBetterAuth: Handle = async ({ event, resolve }) => {

	const session = await auth.api.getSession({
		headers: event.request.headers,
	});
	if (session) {
		event.locals.session = session.session;
		event.locals.user = session.user;
  	}
	return svelteKitHandler({ event, resolve, auth, building });
}

const trpcHandle = createTRPCHandle({router, createContext});

export const handle: Handle = sequence(handleBetterAuth, trpcHandle, handleParaglide);

import type { Handle } from '@sveltejs/kit';
import { paraglideMiddleware } from '$lib/paraglide/server';
import { auth } from "$lib/auth";
import { svelteKitHandler } from "better-auth/svelte-kit";
import { building } from "$app/environment";

const handleParaglide: Handle = ({ event, resolve }) => paraglideMiddleware(event.request, ({ request, locale }) => {
	event.request = request;

	return resolve(event, {
		transformPageChunk: ({ html }) => html.replace('%paraglide.lang%', locale)
	});
});

const handleAuth: Handle = async ({ event, resolve }) => {
	// Fetch current session from Better Auth
  const session = await auth.api.getSession({
    headers: event.request.headers,
  });

  // Make session and user available on server
  if (session) {
    event.locals.session = session.session;
    event.locals.user = session.user;
  }
  
  return svelteKitHandler({ event, resolve, auth, building });
};

export const handle: Handle = async ({ event, resolve }) => {
	return handleParaglide({
		event,
		resolve: (event, opts) => handleAuth({ event, resolve: (event) => resolve(event, opts) })
	});
};
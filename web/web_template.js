//
// Copyright (c) 2022 lalawue
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the MIT license. See LICENSE for details.
//

// load moocscript browser lib after load fengari-web
function moocscript_web_install_lib() {
	function heredoc(f) {
		return f.toString().split('\n').slice(1, -1).join('\n') + '\n'
	}
	const tmpl_str = heredoc();

	// load moocscript-web source
	var res = fengari.load(tmpl_str, "moocscript-web");
	if (typeof(res) == "function") {
		res();
	} else {
		throw new SyntaxError("failed to load moocscript-web");
	}
}

// load moocscript-web api for 'require()'
function moocscript_web_install_api() {
	const f = fengari;
	const L = f.L;
	const l = f.lua;
	const la = f.lauxlib;

	// only load file from same site for 'require()'
	var mooc_loadscript = function(L) {
		var filename = la.luaL_checkstring(L, 1);

		var path = f.to_uristring(filename);
		var xhr = new XMLHttpRequest();
		xhr.open("GET", path, false);
		/*
		Synchronous xhr in main thread always returns a js string.
		Some browsers make console noise if you even attempt to set responseType
		*/

		if (typeof window === "undefined") {
			xhr.responseType = "arraybuffer";
		}

		xhr.send();

		if (xhr.status >= 200 && xhr.status <= 299) {
			if (typeof xhr.response === "string") {
				l.lua_pushstring(L, f.to_luastring(xhr.response));
				return 1;
			} else {
				return new Uint8Array(xhr.response);
			}
		} else {
			return 0;
		}
	}

	// set to `js.mooc_loadscript` in Lua side
	l.lua_getglobal(L, f.to_luastring("js", true));
	l.lua_pushcclosure(L, mooc_loadscript, 0);
	l.lua_setfield(L, -2, f.to_luastring("mooc_loadscript", true));
	l.lua_pop(L, 1);
}

// install listener for <script> tag
function moocscript_web_install_listener() {
	if (typeof document !== 'undefined' && document instanceof HTMLDocument) {
		const f = fengari;
		const L = f.L;
		const l = f.lua;
		const la = f.lauxlib;

		/* Have a document, e.g. we are in main browser window */
		var crossorigin_to_credentials = function(crossorigin) {
			switch (crossorigin) {
				case "anonymous":
					return "omit";

				case "use-credentials":
					return "include";

				default:
					return "same-origin";
			}
		};

		var msghandler = function(L) {
			var ar = new l.lua_Debug();
			if (l.lua_getstack(L, 2, ar)) l.lua_getinfo(L, f.to_luastring("Sl"), ar);
			f.push(L, new ErrorEvent("error", {
				bubbles: true,
				cancelable: true,
				message: f.lua_tojsstring(L, 1),
				error: f.tojs(L, 1),
				filename: ar.short_src ? f.to_jsstring(ar.short_src) : void 0,
				lineno: ar.currentline > 0 ? ar.currentline : void 0
			}));
			return 1;
		};

		var run_mooc_script = function(tag, code, chunkname) {
			{
				// local loadbuffer = package.loaded['moocscript.core'].loadbuffer
				// local ret, lua_code = loadbuffer(mooc_code, chunkname)
				l.lua_getglobal(L, "package");
				l.lua_getfield(L, -1, "loaded");
				l.lua_getfield(L, -1, "moocscript.core");
				l.lua_getfield(L, -1, "loadbuffer");
				l.lua_remove(L, -2);
				l.lua_remove(L, -2);
				l.lua_remove(L, -2);
				l.lua_pushstring(L, code);
				l.lua_pushstring(L, chunkname);
				l.lua_call(L, 2, 2);
				// got result
				const ret = l.lua_toboolean(L, -2)
				code = l.lua_tojsstring(L, -1);
				l.lua_pop(L, 1);
				if (ret) {
					code = f.to_luastring(code);
				} else {
					var filename = tag.src ? tag.src : document.location;
					const lineno = 0;
					var syntaxerror = new SyntaxError(code, filename, lineno);
					e = new ErrorEvent("error", {
						message: msg,
						error: syntaxerror,
						filename: filename,
						lineno: lineno
					});
				}
			}

			var ok = la.luaL_loadbuffer(L, code, null, chunkname);
			var e;

			if (ok === 3) {
				var msg = f.lua_tojsstring(L, -1);
				var filename = tag.src ? tag.src : document.location;
				var lineno = void 0;
				/* TODO: extract out of msg */

				var syntaxerror = new SyntaxError(msg, filename, lineno);
				e = new ErrorEvent("error", {
					message: msg,
					error: syntaxerror,
					filename: filename,
					lineno: lineno
				});
			} else if (ok === 0) {
				/* insert message handler below function */
				var base = l.lua_gettop(L);
				l.lua_pushcfunction(L, msghandler);
				l.lua_insert(L, base);
				/* set document.currentScript.
				   We can't set it normally; but we can create a getter for it, then remove the getter */

				Object.defineProperty(document, 'currentScript', {
					value: tag,
					configurable: true
				});
				ok = l.lua_pcall(L, 0, 0, base);
				/* Remove the currentScript getter installed above; this restores normal behaviour */

				delete document.currentScript;
				/* Remove message handler */

				l.lua_remove(L, base);
				/* Check if normal error that msghandler would have handled */

				if (ok === 2) {
					e = f.checkjs(L, -1);
				}
			}

			if (ok !== 0) {
				if (e === void 0) {
					e = new ErrorEvent("error", {
						message: l.lua_tojsstring(L, -1),
						error: f.tojs(L, -1)
					});
				}

				l.lua_pop(L, 1);

				if (window.dispatchEvent(e)) {
					console.error("uncaught exception", e.error);
				}
			}
		};

		var process_xhr_response = function process_xhr_response(xhr, tag, chunkname) {
			if (xhr.status >= 200 && xhr.status < 300) {
				var code = xhr.response;

				if (typeof code === "string") {
					code = f.to_luastring(xhr.response);
				} else {
					/* is an array buffer */
					code = new Uint8Array(code);
				}
				/* TODO: subresource integrity check? */


				run_mooc_script(tag, code, chunkname);
			} else {
				tag.dispatchEvent(new Event("error"));
			}
		};

		var run_mooc_script_tag = function(tag) {
			if (tag.src) {
				var chunkname = f.to_luastring("@" + tag.src);
				/* JS script tags are async after document has loaded */

				if (document.readyState === "complete" || tag.async) {
					if (typeof fetch === "function") {
						fetch(tag.src, {
							method: "GET",
							credentials: crossorigin_to_credentials(tag.crossorigin),
							redirect: "follow",
							integrity: tag.integrity
						}).then(function(resp) {
							if (resp.ok) {
								return resp.arrayBuffer();
							} else {
								throw new Error("unable to fetch");
							}
						}).then(function(buffer) {
							var code = new Uint8Array(buffer);
							run_mooc_script(tag, code, chunkname);
						}).catch(function(reason) {
							tag.dispatchEvent(new Event("error"));
						});
					} else {
						var xhr = new XMLHttpRequest();
						xhr.open("GET", tag.src, true);
						xhr.responseType = "arraybuffer";

						xhr.onreadystatechange = function() {
							if (xhr.readyState === 4) process_xhr_response(xhr, tag, chunkname);
						};

						xhr.send();
					}
				} else {
					/* Needs to be synchronous: use an XHR */
					var _xhr = new XMLHttpRequest();

					_xhr.open("GET", tag.src, false);

					_xhr.send();

					process_xhr_response(_xhr, tag, chunkname);
				}
			} else {
				var code = f.to_luastring(tag.innerHTML);

				var _chunkname = tag.id ? f.to_luastring("=" + tag.id) : code;

				run_mooc_script(tag, code, _chunkname);
			}
		};

		var contentTypeRegexp = /^(.*?\/.*?)([\t ]*;.*)?$/;
		var luaVersionRegex = /^(\d+)\.(\d+)$/;

		var try_tag = function try_tag(tag) {
			if (tag.tagName !== "SCRIPT") return;
			/* strip off mime type parameters */

			var contentTypeMatch = contentTypeRegexp.exec(tag.type);
			if (!contentTypeMatch) return;
			var mimetype = contentTypeMatch[1];
			if (mimetype !== "application/mooc" && mimetype !== "text/mooc") return;

			if (tag.hasAttribute("lua-version")) {
				var lua_version = luaVersionRegex.exec(tag.getAttribute("lua-version"));
				if (!lua_version || lua_version[1] !== LUA_VERSION_MAJOR || lua_version[2] !== LUA_VERSION_MINOR) return;
			}

			run_mooc_script_tag(tag);
		};

		if (typeof MutationObserver !== 'undefined') {
			/* watch for new script tags added to document */
			new MutationObserver(function(records, observer) {
				for (var i = 0; i < records.length; i++) {
					var record = records[i];

					for (var j = 0; j < record.addedNodes.length; j++) {
						try_tag(record.addedNodes[j]);
					}
				}
			}).observe(document, {
				childList: true,
				subtree: true
			});
		} else if (console.warn) {
			console.warn("fengari-web: MutationObserver not found; lua script tags will not be run when inserted");
		}
		/* the query selector here is slightly liberal,
		   more checks occur in try_tag */


		var selector = 'script[type^="application/mooc"], script[type^="text/mooc"]';
		/* try to run existing script tags */

		Array.prototype.forEach.call(document.querySelectorAll(selector), try_tag);
	}
}

moocscript_web_install_lib()
moocscript_web_install_api()
moocscript_web_install_listener()
var el_up = document.getElementById("GFG_UP");
var el_down = document.getElementById("GFG_DOWN");

function gfg_Run() {
	var cookies = document.cookie.split(';').reduce(
		(cookies, cookie) => {
			const [name, val] = cookie.split('=').map(c => c.trim());
			cookies[name] = val;
			return cookies;
		}, {});
	el_down.innerHTML = JSON.stringify(cookies);
}

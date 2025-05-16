document.getElementById('formConnect').addEventListener('submit', async function(event) {
	const id  = document.getElementById("ID").value;
	const mdp = document.getElementById("MDP").value;
	const ip  = document.getElementById("IP").value;

	sessionStorage.setItem("id", id);
	sessionStorage.setItem("mdp", mdp);
	sessionStorage.setItem("ip", ip);
	event.preventDefault();

	let tokenValid = await fetchToken();
	console.log("Token valid:", tokenValid);
	if (tokenValid === false) {
		document.getElementById("ID").value = id;
		document.getElementById("MDP").value = mdp;
		document.getElementById("IP").value = ip;
	} else {
		window.location.href = "../index.html";
	}
});

async function fetchToken() {
	const url = "https://" + sessionStorage.getItem("ip");

	const loginBody = {
		username: sessionStorage.getItem("id"),
		password: sessionStorage.getItem("mdp"),
	};

	try {
		const response = await fetch(`${url}/login`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify(loginBody),
		});


		if (!response.ok) {
			throw new Error(`HTTP error! status: ${response.status}`);
		}

		const data = await response.json();

		if (data.token) {
			console.log("Token fetched:", data.token);
			sessionStorage.setItem("token", data.token);
			return true;
		} else {
			throw new Error("Failed to fetch token");
		}
	} catch (error) {
		console.error("Error fetching token:", error);

		sessionStorage.removeItem("id");
		sessionStorage.removeItem("mdp");
		sessionStorage.removeItem("ip");
		return false;
	}
}

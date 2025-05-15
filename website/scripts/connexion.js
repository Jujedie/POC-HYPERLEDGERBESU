document.getElementById('formConnect').addEventListener('submit', function(event) {
	const id  = document.getElementById("id").value;
	const mdp = document.getElementById("mdp").value;
	const ip  = document.getElementById("ip").value;

	sessionStorage.setItem("id", id);
	sessionStorage.setItem("mdp", mdp);
	sessionStorage.setItem("ip", ip);
	event.preventDefault();

	if ( fetchToken() == false) {
		document.getElementById("id").value = id;
		document.getElementById("mdp").value = mdp;
		document.getElementById("ip").value = ip;
	} else {
		window.location.href = "../index.html";
	}
});

function fetchToken() {
	const url = "http://" + sessionStorage.getItem("ip");

	const loginBody = {
		id: sessionStorage.getItem("id"),
		password: sessionStorage.getItem("mdp"),
	};

	fetch(`${url}/login`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify(loginBody),
	})
		.then((response) => {
			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}
			return response.json();
		})
		.then((data) => {
			if (data.token) {
				console.log("Token fetched:", data.token);
				sessionStorage.setItem("token", data.token);
				return true;
			} else {
				throw new Error("Failed to fetch token");
			}
		})
		.catch((error) => {
			console.error("Error fetching token:", error);

			sessionStorage.removeItem("id");
			sessionStorage.removeItem("mdp");
			sessionStorage.removeItem("ip");
			return false;
		});
}
document.addEventListener("DOMContentLoaded", function () {
	if (
		sessionStorage.getItem("id") !== null &&
		sessionStorage.getItem("mdp") !== null &&
		sessionStorage.getItem("ip") !== null
	) {
		const error = Document.getElementById("error");
		if (error) {
			error.remove();
		}

		const cartographie = Document.getElementById("Cartographie");

		fetchToken();

		const nodes = getNodes()
		for (let i = 0; i < nodes.length; i++) {
			const node = nodes[i];
			const nodeDiv = document.createElement("div");
			nodeDiv.className = "node";
			nodeDiv.innerHTML = `
				<h3>${node.IP}</h3>
				<p>Enode: ${node.enode}</p>
				<p>Port: ${node.port}</p>
				<p>Type: ${node.type}</p>
			`;
			cartographie.appendChild(nodeDiv);
		}
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
			} else {
				throw new Error("Failed to fetch token");
			}
		})
		.catch((error) => console.error("Error fetching token:", error));
}

function getNodes() {
	let nodes = admin_peers();
	nodes = admin_nodeInfo() + nodes;
	return nodes;
}

function admin_peers() {
	const url = "http://" + sessionStorage.getItem("ip");

	const proposeBody = {
		jsonrpc: "2.0",
		method: "admin_peers",
		params: [],
		id: 1,
	};

	fetch(url, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Authorization: `Bearer ${sessionStorage.getItem("token")}`,
		},
		body: JSON.stringify(proposeBody),
	})
		.then((response) => {
			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}
			return response.json();
		})
		.then((data) => {
			console.log(data);
			return data;
		})
		.catch((error) => console.error("Error:", error));
}

function admin_nodeInfo() {
	const url = "http://" + sessionStorage.getItem("ip");

	const proposeBody = {
		jsonrpc: "2.0",
		method: "admin_nodeInfo",
		params: [],
		id: 1,
	};

	fetch(url, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Authorization: `Bearer ${sessionStorage.getItem("token")}`,
		},
		body: JSON.stringify(proposeBody),
	})
		.then((response) => {
			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}
			return response.json();
		})
		.then((data) => {
			console.log(data);
			return data;
		})
		.catch((error) => console.error("Error:", error));
}

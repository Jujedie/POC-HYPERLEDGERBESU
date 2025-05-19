import "./App.css";
import { jwtDecode } from "jwt-decode";


function DashboardNode() {
	async function connectRPC() {

		const loginBody = {
			username: sessionStorage.getItem("username"),
			password: sessionStorage.getItem("password"),
		};

		try {
			// Authentification
			const loginResponse = await fetch(`${sessionStorage.getItem("url")}/login`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify(loginBody),
			});

			const loginData = await loginResponse.json();
			const token = loginData.token;
			if (!token) {
				console.log("Échec de l'authentification.");
				message("Échec de l'authentification.", "red");
				return;
			} else {
				sessionStorage.setItem("token", token);

				console.log("Token récupéré:", token);
				message("", "green");
			}
		} catch (error) {
			console.error(error);
			console.log("Erreur lors de la requête.");
			message("Erreur lors de la requête.", "red");
		}

	}

	function tokenValidation() {
		const token = sessionStorage.getItem("token");
		if (!token) {
			window.location.href = "/connexion";
			return;
		}

		if (token.exp < Date.now() / 1000) {
			connectRPC();
		}
	}

	function getNodes() {
		const nodesList = document.getElementById("lstNodes");
		nodesList.innerHTML = "";

		const resNode = sendRPC("admin_nodeInfo");
		const resPeers = sendRPC("admin_peers");

		// Node
		const row = document.createElement("tr");
		row.classList.add("selectedNode");
		row.innerHTML = `<td>${resNode.enode}</td><td>${resNode.id}</td>`;
		nodesList.appendChild(row);

		// Peers
		resPeers.forEach(node => {
			const row = document.createElement("tr");
			row.innerHTML = `<td>${node.network.localAddress}</td><td>${node.id}</td>`;
			nodesList.appendChild(row);

		});
	}

	function message(text, color) {
		document.getElementById("error").innerHTML = text;
		document.getElementById("error").style.color = color;


	}

	async function sendRPC(method, paramList) {
		try {
			tokenValidation();

			const url = sessionStorage.getItem("url");
			const token = sessionStorage.getItem("token");

			const rpcBody = {
				jsonrpc: "2.0",
				method: method,
				params: paramList,
				id: 1,
			}

			const rpcResponse = await fetch(url, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Authorization: `Bearer ${token}`,
				},
				body: JSON.stringify(rpcBody),
			});

			const rpcData = await rpcResponse.json();

			if(!rpcData.result) {
				message(rpcData.error.message, "red");
				return ;
			}

			return rpcData.result;

		} catch(error) {
			message("Error fetching Node", "red");
			return ;
		}
	}


	return (
		<div className="App">
			<h1>Dashboard</h1>

			<table>
				<tbody id="lstNodes"></tbody>
			</table>
			<button onClick={getNodes}>Rafraichir liste noeuds</button>
			<div id="error"></div>
		</div>
	);
}

export default DashboardNode;

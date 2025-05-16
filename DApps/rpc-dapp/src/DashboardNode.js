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
				document.getElementById("error").innerHTML = "Échec de l'authentification.";
				document.getElementById("error").style.color = "red";
				return;
			} else {
				sessionStorage.setItem("token", token);

				console.log("Token récupéré:", token);
				document.getElementById("error").innerHTML = "";
				document.getElementById("error").style.color = "green";
			}
		} catch (error) {
			console.error(error);
			console.log("Erreur lors de la requête.");
			document.getElementById("error").innerHTML = "Erreur lors de la requête.";
			document.getElementById("error").style.color = "red";
		}

	}

	function tokenValidation() {
		if (jwtDecode(sessionStorage.getItem("token")).exp < Date.now() / 1000) {
			connectRPC();
		}
	}

	function getNodes() {
		const nodesList = document.getElementById("lstNodes");
		nodesList.innerHTML = "";

		tokenValidation();
		const url = sessionStorage.getItem("url");
		const token = sessionStorage.getItem("token");

		let rpcBody = {
			jsonrpc: "2.0",
			method: "admin_peers",
			params: [],
			id: 1,
		}

		fetch(`${url}`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				"Authorization": `Bearer ${token}`,
			},
			body: JSON.stringify(rpcBody),
		})
			.then(response => response.json())
			.then(data => {
				 // Clear previous content

				(data.result || []).forEach(node => {
					const row = document.createElement("tr");
					row.innerHTML = `<td>${node.enode}</td><td>${node.id}</td>`;
					nodesList.appendChild(row);
				});
			})
			.catch(error => console.error('Error fetching nodes:', error));
		
		rpcBody = {
			jsonrpc: "2.0",
			method: "admin_nodeInfo",
			params: [],
			id: 1,
		}

		fetch(`${url}`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				"Authorization": `Bearer ${token}`,
			},
			body: JSON.stringify(rpcBody),
		})
			.then(response => response.json())
			.then(data => {
				const row = document.createElement("tr");
				row.classList.add("selectedNode");
				row.innerHTML = `<td>${data.result.enode}</td><td>${data.result.id}</td>`;
				nodesList.appendChild(row);
			})
			.catch(error => console.error('Error fetching nodes:', error));
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

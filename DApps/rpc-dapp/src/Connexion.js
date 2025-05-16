import "./App.css";
import { BrowserRouter as Router, Routes, Route, Link, useNavigate } from "react-router-dom";
import DashboardNode from "./DashboardNode";

function Connexion() {
	const navigate = useNavigate();

	async function connectRPC() {
		const username = document.getElementById("inputUS").value;
		const password = document.getElementById("inputPassword").value;
		const url = document.getElementById("inputURL").value;

		const loginBody = {
			username: username,
			password: password,
		};

		try {
			// Authentification
			const loginResponse = await fetch(`${url}/login`, {
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
				sessionStorage.setItem("username", username);
				sessionStorage.setItem("password", password);
				sessionStorage.setItem("url", url);
				sessionStorage.setItem("token", token);
				
				console.log("Token récupéré:", token);
				document.getElementById("error").innerHTML = "";
				document.getElementById("error").style.color = "green";

				// Redirection vers le Dashboard
				navigate("/dashboardnode"); // <-- tout en minuscules
			}
		} catch (error) {
			console.error(error);
			console.log("Erreur lors de la requête.");
			document.getElementById("error").innerHTML = "Erreur lors de la requête.";
			document.getElementById("error").style.color = "red";
		}

	}

	return (
		<div className="App">
			<h1>Connexion</h1>

			<table>
				<tbody>
					<tr>
						<th>Identifiant</th>
						<th>
							<input type="text" id="inputUS" value={sessionStorage.getItem("username")} placeholder="Entrez le nom d'utilisateur" />
						</th>
					</tr>
					<tr>
						<th>Mot de passe</th>
						<th>
							<input type="password" id="inputPassword" value={sessionStorage.getItem("password")} placeholder="Entrez le mot de passe" />
						</th>
					</tr>
					<tr>
						<th>Adresse IP d'un noeud <br /> et son port RPC</th>
						<th>
							<input type="text" id="inputURL" value={sessionStorage.getItem("url")} placeholder="https://IP:portRPC" />
						</th>
					</tr>
				</tbody>
			</table>
			<button className="validation-button" id="rpc-request" onClick={connectRPC}>
				Se connecter
			</button>
			<div id="error"></div>
		</div>
	);
}

export default Connexion;

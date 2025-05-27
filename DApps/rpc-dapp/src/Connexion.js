import "./App.css";
import { BrowserRouter as Router, Routes, Route, Link, useNavigate } from "react-router-dom";
import DashboardNode from "./DashboardNode";
import { generateToken } from "./rpcUtils";

function Connexion() {
	const navigate = useNavigate();

	async function connectRPC() {
		const username = document.getElementById("inputUS").value;
		const password = document.getElementById("inputPassword").value;
		const url = document.getElementById("inputURL").value;

		sessionStorage.setItem("username", username);
		sessionStorage.setItem("password", password);
		sessionStorage.setItem("url", url);

		await generateToken(username, password, url);

		if(sessionStorage.getItem("token")) {
			navigate("/dashboardnode");
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

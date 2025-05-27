import "./App.css";
import { useState } from "react";
import { rpcMethods } from "./rpcUtils";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Connexion from "./Connexion";
import DashboardNode from "./DashboardNode";	

function App() {
	const [result, setResult] = useState("");
	const [selectedMethod, setSelectedMethod] = useState("");
	const [args, setArgs] = useState({});

	const selectedMethodDef = rpcMethods.find((m) => m.name === selectedMethod);

	async function sendRPC() {
		const id = document.getElementById("inputID").value;
		const password = document.getElementById("inputPassword").value;
		const url = document.getElementById("inputURL").value;

		const loginBody = {
			username: id,
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
				setResult("Échec de l'authentification.");
				return ;
			}

			// Appel RPC
			const paramList = selectedMethodDef?.params?.map((p) => args[p.name]) || [];

			const rpcBody = {
				jsonrpc: "2.0",
				method: selectedMethod,
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
			console.log(rpcData);
			if(rpcData.result) {
				setResult(JSON.stringify(rpcData.result, null, 2));
			} else {
				setResult(JSON.stringify(rpcData.error.message, null, 2));
			}
		} catch(error) {
			console.error(error);
			setResult("Erreur lors de la requête.");
		}

	}
	
	return (
		<Router>
			<nav>
				<Link to="/dashboardnode">Accueil</Link> | <Link to="/connexion">Connexion</Link>
			</nav>
			<Routes>
				<Route path="/" element={
					<div>
						<h1>Besu API</h1>

						<table>
						<tbody>
						<tr>
						<th>Identifiant</th>
						<th>
						<input type="text" id="inputID" placeholder="Entrez votre identifiant"/>
						</th>
						</tr>
						<tr>
						<th>Mot de passe</th>
						<th>
						<input type="password" id="inputPassword" placeholder="Entrez votre mot de passe"/>
						</th>
						</tr>
						<tr>
						<th>Adresse IP d'un noeud <br /> et son port RPC</th>
						<th>
						<input type="text" id="inputURL" placeholder="https://IP:portRPC"/>
						</th>
						</tr>
						<tr>
						<th>Méthode</th>
						<th>
						<select 
						id="inputMethod" 
						value={selectedMethod} 
						onChange={(e) => {
							setSelectedMethod(e.target.value);
							setArgs({});
						}}
						>
						<option value="">-- Sélectionnez une méthode --</option>
						{rpcMethods.map((method) => (
							<option key={method.name} value={method.name}>
							{method.name}
							</option>
						))}
						</select>
						</th>
						</tr>
						{selectedMethodDef?.params?.map((param) => (
							<tr key={param.name}>
							<th>{param.name}</th>
							<th>
							<input
							type="text"
							placeholder={param.description}
							value={args[param.name] || ""}
							onChange={(e) =>
								setArgs({ ...args, [param.name]: e.target.value })
							}
							/>
							</th>
							</tr>
						))}
						</tbody>
						</table>
						<button className="validation-button" id="rpc-request" onClick={sendRPC}>
						Envoyer la requête
						</button>
						<pre>{result}</pre>
					</div>
				} />
				<Route path="/connexion" element={<Connexion />} />
				<Route path="/dashboardnode" element={<DashboardNode />} />
			</Routes>
		</Router>
	);
}

export default App;

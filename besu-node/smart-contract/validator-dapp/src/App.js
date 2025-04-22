import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <h1>Validator App</h1>

      <div>
        <input type="text" id="inputAdress" placeholder="Entrez l'adresse du noeud" />
        <input type="text" id="inputIpValidateur" placeholder="IPValidateur:portRPC" />
        <select id="booleanInput">
          <option value="true">True</option>
          <option value="false">False</option>
        </select>
      </div>
      <button id="changeValidator" onClick={() => changeValidateur()}>Envoyer la requête</button>
    </div>
  );
}

function changeValidateur() {
  const url = Document.getElementById("inputIpValidateur").value;
  const address = Document.getElementById("inputAdress").value;
  const booleanValue = Document.getElementById("booleanInput").value === "true"; // Convert string to boolean

  const requestBody = {
    jsonrpc: "2.0",
    method: "qbft_proposeValidatorVote",
    params: [address, booleanValue],
    id: 1
  };

  fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(requestBody)
  })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error("Error:", error));
}

export default App;

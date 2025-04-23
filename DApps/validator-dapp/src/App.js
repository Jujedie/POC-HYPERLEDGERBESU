import './App.css';

const operationEnCour = {};

function App() {
  return (
    <div className="App">
      <h1>Validator App</h1>

      <table>
        <tr>
          <th><p>Adresse du noeud cible</p></th>
          <th><input type="text" id="inputAdress" placeholder="Entrez l'adresse du noeud"/></th>
        </tr>

        <tr>
          <th><p>Adresse IP d'un noeud validateur <br /> et son port RPC</p></th>
          <th><input type="text" id="inputIpValidateur" placeholder="http://IPValidateur:portRPC" /></th>
        </tr>

        <tr>
          <th><p>Proposition de vote pour un validateur <br /> true pour ajouter et false pour supprimer</p></th>
          <th><select id="booleanInput">
            <option value="true">True</option>
            <option value="false">False</option>
          </select></th>
        </tr>

        <tr>
          <button class="validation-button" id="changeValidator" onClick={() => changeValidateur()}>Envoyer la requête</button>
        </tr>
      </table>
    </div>
  );
}

function changeValidateur() {
  const url = document.getElementById("inputIpValidateur").value;
  const address = document.getElementById("inputAdress").value;
  const booleanValue = document.getElementById("booleanInput").value === "true"; 

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

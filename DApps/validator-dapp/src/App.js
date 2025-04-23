import './App.css';

const operationEnCour = {};

function App() {
  return (
    <div className="App">
      <h1>Validator App</h1>

      <table>
        <tbody>
          <tr>
            <th><p>Adresse du noeud cible</p></th>
            <th><input type="text" id="inputAdress" placeholder="Entrez l'adresse du noeud" /></th>
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
        </tbody>
      </table>
      <button className="validation-button" id="changeValidator" onClick={() => changeValidateur()}>Envoyer la requête</button>
    </div>
  );
}

function changeValidateur() {
  const url = document.getElementById("inputIpValidateur").value;
  const address = document.getElementById("inputAdress").value;
  const booleanValue = document.getElementById("booleanInput").value === "true";

  const proposeBody = {
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
    body: JSON.stringify(proposeBody)
  })
    .then(response => response.json())
    .then(data => {
      console.log("Vote proposé:", data);
      operationEnCour[address] = [url, booleanValue];
      waitForVoteApplication();
    })
    .catch(error => console.error("Error:", error));
}

function waitForVoteApplication() {
  const intervalId = setInterval(() => {
    
    const addresses = Object.keys(operationEnCour);
    for (const address of addresses) {
      if (operationEnCour[address] === undefined) {
        delete operationEnCour[address];
        continue;
      }

      const url = operationEnCour[address][0];
      const booleanValue = operationEnCour[address][1];

      const getValidatorsBody = {
        jsonrpc: "2.0",
        method: "qbft_getValidatorsByBlockNumber",
        params: ["latest"],
        id: 1
      };
      fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(getValidatorsBody)
      })
        .then(response => response.json())
        .then(data => {
          console.log("Liste des validateurs:", data);
          const validators = data.result || [];
          const isPresent = validators.map(a => a.toLowerCase()).includes(address.toLowerCase());

          if ((booleanValue && isPresent) || (!booleanValue && !isPresent)) {
            discardValidatorVote(url, address);
            operationEnCour[address] = undefined;
          }
        });
    }

    // Arrêter l'intervalle si plus aucune opération n'est en cours
    if (Object.keys(operationEnCour).every(addr => operationEnCour[addr] === undefined)) {
      clearInterval(intervalId);
    }
  }, 2000); // Vérifie toutes les 2 secondes
}

function discardValidatorVote(url, address) {
  const discardBody = {
    jsonrpc: "2.0",
    method: "qbft_discardValidatorVote",
    params: [address],
    id: 1
  };
  fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(discardBody)
  })
    .then(response => response.json())
    .then(data => {
      console.log("Vote discarded:", data);
      alert("Vote terminé et discard exécuté !");
    });
}


export default App;
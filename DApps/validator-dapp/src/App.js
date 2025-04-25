import './App.css';

const operationEnCour = {};

function App() {
  return (
    <div className="App">
      <h1>Validator App</h1>

      <table>
        <tbody>
          <tr>
            <th><p>Nom Identifiant</p></th>
            <th><input type="text" id="inputNom" placeholder="Entrez votre identifiant" /></th>
          </tr>
          <tr>
            <th><p>Mot de Passe</p></th>
            <th><input type="password" id="inputMdp" placeholder="Entrez votre mot de passe" /></th>
          </tr>
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
  const nom = document.getElementById("inputNom").value;
  const mdp = document.getElementById("inputMdp").value;
  const url = document.getElementById("inputIpValidateur").value;
  const address = document.getElementById("inputAdress").value;
  const booleanValue = document.getElementById("booleanInput").value === "true";

  const proposeBody = {
    jsonrpc: "2.0",
    method: "qbft_proposeValidatorVote",
    params: [address, booleanValue],
    id: 1
  };

  const loginBody = {
    username: nom,
    password: mdp
  };

  fetch(`${url}/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(loginBody)
  })
    .then(response => response.json())
    .then(data => {
      if (data.token) {
        console.log("Token fetched:", data.token);
        proposeBody.token = data.token; 
      } else {
        throw new Error("Failed to fetch token");
      }
    })
    .catch(error => console.error("Error fetching token:", error));

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

    document.getElementById("inputNom").value = "";
    document.getElementById("inputMdp").value = "";
    document.getElementById("inputIpValidateur").value = "";
    document.getElementById("inputAdress").value = "";
    document.getElementById("booleanInput").value = "true";

    document.getElementById("inputNom").focus();
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

      const nom = document.getElementById("inputNom").value;
      const mdp = document.getElementById("inputMdp").value;

      const loginBody = {
        username: nom,
        password: mdp
      };
    
      fetch(`${url}/login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(loginBody)
      })
        .then(response => response.json())
        .then(data => {
          if (data.token) {
            console.log("Token fetched:", data.token);
            getValidatorsBody.token = data.token; 
          } else {
            throw new Error("Failed to fetch token");
          }
        })
        .catch(error => console.error("Error fetching token:", error));
    

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
  const nom = document.getElementById("inputNom").value;
  const mdp = document.getElementById("inputMdp").value;

  const discardBody = {
    jsonrpc: "2.0",
    method: "qbft_discardValidatorVote",
    params: [address],
    id: 1
  };

  const loginBody = {
    username: nom,
    password: mdp
  };

  fetch(`${url}/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(loginBody)
  })
    .then(response => response.json())
    .then(data => {
      if (data.token) {
        console.log("Token fetched:", data.token);
        discardBody.token = data.token; 
      } else {
        throw new Error("Failed to fetch token");
      }
    })
    .catch(error => console.error("Error fetching token:", error));

  
  fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(discardBody)
  })
    .then(response => response.json())
    .then(data => {
      console.log("Vote discarded:", data);
    });
}


export default App;
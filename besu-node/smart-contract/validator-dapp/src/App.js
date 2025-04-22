import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <h1>Validator App</h1>

      <div>
        <input type="text" id="stringInput" placeholder="Entrez l'adresse du noeud" />
        <input type="text" id="stringInput2" placeholder="IPValidateur:portRPC" />
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
}

export default App;

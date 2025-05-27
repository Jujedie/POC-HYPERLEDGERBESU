import "./DashboardNode.css";
import { sendRPC, message } from "./rpcUtils";
import { useEffect, useState } from "react";
import { keccak_256 } from 'js-sha3';

function DashboardNode() {
	const [localNode, setLocalNode] = useState(null);
	const [peers, setPeers] = useState([]);
	const [selectedNode, setSelectedNode] = useState(null);
	const [loadingValidators, setLoadingValidators] = useState({});

	async function getNodes() {
		message("","green");
		setLocalNode(null);
		setPeers([]);
		setSelectedNode(null);


		const resNode = await sendRPC("admin_nodeInfo");
		const resPeers = await sendRPC("admin_peers");

		console.log(resNode);
		console.log(resPeers);

		if (!resNode || !resPeers) {
			message("Erreur lors de la récupération des nœuds", "red");
			return;
		}

		setLocalNode(resNode);
		setPeers(resPeers);
		setSelectedNode({ ...resNode, isLocal: true });
	}

	function peerToEthereumAddress(peerIdHex) {
		const peerIdBytes = Uint8Array.from(peerIdHex.match(/.{1,2}/g).map(byte => parseInt(byte, 16)));

		const hashHex = keccak_256(peerIdBytes);

		const ethAddress = '0x' + hashHex.slice(-40).toLowerCase();

		return ethAddress;
	}

	async function changeValidator(peerIdHex, proposal) {
		const nodeAddr = peerToEthereumAddress(peerIdHex.startsWith("0x") ? peerIdHex.slice(2) : peerIdHex);
		console.log(nodeAddr);
		setLoadingValidators((prev) => ({ ...prev, [nodeAddr]: proposal }));
		try {
			const result = await sendRPC("qbft_proposeValidatorVote", [nodeAddr, proposal]);
			if (result === true) {
				message(`Le vote pour le nœud ${nodeAddr} a été comptabilisé.`, "green");
			} else {
				message(`Échec de la proposition du nœud ${nodeAddr}.`, "red");
			}
		} catch (err) {
			message(`Erreur lors de la proposition : ${err.message}`, "red");
		} finally {
			setLoadingValidators((prev) => ({ ...prev, [nodeAddr]: !proposal }));
		}
	}

	useEffect(() => {
		getNodes();
	}, []);

	return (
		<div className="Dashboard">
			<h1>Dashboard</h1>
			<div className="dashboard-grid">
				<div className="node-details">
					<h2>Détails du nœud sélectionné</h2>
					{selectedNode ? (
						<table>
  <tbody>
    <tr>
      <th>Nom</th>
      <td>{selectedNode.name}</td>
    </tr>
    <tr>
      <th>Capabilities</th>
      <td>{selectedNode.caps?.join(', ') || 'N/A'}</td>
    </tr>
    <tr>
      <th>ID</th>
      <td>{selectedNode.id}</td>
    </tr>
    <tr>
      <th>Adresse</th>
      <td>
        {selectedNode.isLocal
          ? selectedNode.listenAddr
          : selectedNode.network?.remoteAddress?.split(':')[0] +
            ":" +
            parseInt(selectedNode.port || selectedNode.ports?.listener)}
      </td>
    </tr>
    <tr>
      <th>Enode</th>
      <td>{selectedNode.enode}</td>
    </tr>
    <tr>
      <th>Protocol Version</th>
      <td>{selectedNode.protocols?.eth?.version ?? 'N/A'}</td>
    </tr>
    <tr>
      <th>Difficulty</th>
      <td>{selectedNode.protocols?.eth?.difficulty ?? 'N/A'}</td>
    </tr>
    <tr>
      <th>Head</th>
      <td>{selectedNode.protocols?.eth?.head ?? 'N/A'}</td>
    </tr>
    {selectedNode.protocols?.eth?.config && (
      <>
        <tr>
          <th>Chain ID</th>
          <td>{selectedNode.protocols.eth.config.chainId}</td>
        </tr>
        <tr>
          <th>Genesis</th>
          <td>{selectedNode.protocols.eth.genesis}</td>
        </tr>
      </>
    )}
  </tbody>
</table>
					) : (
						<p>Aucun nœud sélectionné.</p>
					)}
				</div>

				<div className="node-list">
					<h2>Liste des nœuds</h2>
					<table>
						<thead>
							<tr>
								<th>Enode</th>
								<th>Adresse</th>
								<th></th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							{localNode && (
								<tr
									className={
										selectedNode?.enode === localNode.enode ? "selected" : ""
									}
									onClick={() =>
										setSelectedNode({ ...localNode, isLocal: true })
									}
								>
									<td>{localNode.enode}</td>
									<td>{localNode.listenAddr}</td>
									<td>
										<button
											onClick={(e) => {
												e.stopPropagation();
												changeValidator(localNode.id,true);
											}}
											disabled={loadingValidators[localNode.enode]}
										>
											{loadingValidators[localNode.enode]
												? "Ajout..."
												: "Ajouter comme validateur"}
										</button>
									</td>
									<td>
										<button
											onClick={(e) => {
												e.stopPropagation();
												changeValidator(localNode.id,false);
											}}
											disabled={loadingValidators[localNode.enode]}
										>
											{loadingValidators[localNode.enode]
												? "Suppression..."
												: "Supprimer des validateurs"}

										</button>
									</td>
								</tr>
							)}

							{peers.map((peer, index) => (
								<tr
									key={index}
									className={
										selectedNode?.enode === peer.enode ? "selected" : ""
									}
									onClick={() => setSelectedNode(peer)}
								>
									<td>{peer.enode}</td>
									<td>
										{peer.network.remoteAddress.split(':')[0] +
											":" +
											parseInt(peer.port)}
									</td>
									<td>
										<button
											onClick={(e) => {
												e.stopPropagation();
												changeValidator(peer.id,true);
											}}
											disabled={loadingValidators[peer.enode]}
										>
											{loadingValidators[peer.enode]
												? "Ajout..."
												: "Ajouter comme validateur"}
										</button>
									</td>
									<td>
										<button
											onClick={(e) => {
												e.stopPropagation();
												changeValidator(peer.id,false);
											}}
											disabled={loadingValidators[peer.enode]}
										>
											{loadingValidators[peer.enode]
												? "Suppression..."
												: "Supprimer des validateurs"}
										</button>
									</td>
								</tr>
							))}
						</tbody>
					</table>
				</div>
			</div>
			<button onClick={getNodes}>Rafraîchir la liste des nœuds</button>
			<div id="error"></div>
		</div>
	);
}

export default DashboardNode;


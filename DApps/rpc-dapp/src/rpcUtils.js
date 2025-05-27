import { jwtDecode } from "jwt-decode";

const logLevel = ["OFF","FATAL","ERROR","WARN","INFO","DEBUG","TRACE","ALL"];
const blockParameter = ["latest","earliest","pending","finalized","safe"];

export const rpcMethods = [
	{
		name: "admin_addPeer",
		description: "Adds a static node.",
		caution: "If connections are timing out, ensure the node ID in the enode URL is correct.",
		params: [
			{
				name: "enode",
				type: "string",
				description: "enode URL of peer to add",
				optional: false,
				validate: (val) => /^enode:\/\/[0-9a-fA-F]{128}@((?:\d{1,3}\.){3}\d{1,3}|(?:[0-9a-fA-F:]+)|[a-zA-Z0-9.-]+):[0-9]{1,5}$/.test(val),
			},
		],
		result: [
			{
				type: "boolean",
				description: "true if peer added or false if peer already a static node",
			},
		],
	},
	{
		name: "admin_changeLogLevel",
		description: "Changes the log level without restarting Besu. You can change the log level for all logs, or you can change the log level for specific packages or classes.\nYou can specify only one log level per RPC call.",
		params: [
			{
				name: "level",
				type: "string",
				description: "log level",
				optional: false,
				option: logLevel,
				default: "INFO",
				validate: (val) => logLevel.includes(val.toUpperCase()),
			},
			{
				name: "log_filter",
				type: "array",
				description: "(optional) packages or classes for which to change the log level",
				optional: true,
				validate: (val) => Array.isArray(val) && val.every((item) => typeof item === "string"),
			},
		],
		result: [
			{
				type: "string",
				description: "Success if the log level has changed, otherwise error",
			},
		],
	},
	{
		name: "admin_generateLogBloomCache",
		description: "Generates cached log bloom indexes for blocks. APIs such as eth_getLogs and eth_getFilterLogs use the cache for improved performance.",
		tip: "Manually executing admin_generateLogBloomCache is not required unless the --auto-log-bloom-caching-enabled command line option is set to false.",
		note: "Each index file contains 100000 blocks. The last fragment of blocks less than 100000 are not indexed.",
		params: [
			{
				name: "startBlock",
				type: "string",
				description: "block to start generating indexes",
				optional: false,
				validate: (val) => /^0x[0-9a-fA-F]+$/.test(val) || /^\d+$/.test(val),
			},
			{
				name: "endBlock",
				type: "string",
				description: "block to stop generating indexes",
				optional: false,
				validate: (val) => /^0x[0-9a-fA-F]+$/.test(val) || /^\d+$/.test(val),
			},
		],
		result: [
			{
				type: "object",
				description: "log bloom index details",
				properties: [
					{
						name: "startBlock",
						type: "string",
						description: "starting block for the last requested cache generation",
					},
					{
						name: "endBlock",
						type: "string",
						description: "ending block for the last requested cache generation",
					},
					{
						name: "currentBlock",
						type: "string",
						description: "most recent block added to the cache",
					},
					{
						name: "indexing",
						type: "boolean",
						description: "indicates if indexing is in progress",
					},
					{
						name: "requestAccepted",
						type: "boolean",
						description: "indicates acceptance of the request from this call to generate the cache",
					},
				],
			},
		],	
	},
	{
		name: "admin_logsRemoveCache",
		description: "Removes cache files for the specified range of blocks.",
		note: "pending returns the same value as latest\n\nYou can skip a parameter by using an empty string, \"\". If you specify:\n\nNo parameters, the call removes cache files for all blocks.\n\nOnly fromBlock, the call removes cache files for the specified block.\n\nOnly toBlock, the call removes cache files from the genesis block to the specified block",
		params: [
			{	
				name: "fromBlock",
				type: "string",
				description: "hexadecimal or decimal integer representing a block number, or one of the string tags latest, earliest, pending, finalized, or safe, as described in block parameter",
				optional: true,
				validate: (val) =>
					val === "" ||
						/^0x[0-9a-fA-F]+$/.test(val) ||
						/^\d+$/.test(val) ||
						blockParameter.includes(val),
			},
			{
				name: "toBlock",
				type: "string",
				description: "hexadecimal or decimal integer representing a block number, or one of the string tags latest, earliest, pending, finalized, or safe, as described in block parameter",
				optional: true,
				validate: (val) =>
					val === "" ||
						/^0x[0-9a-fA-F]+$/.test(val) ||
						/^\d+$/.test(val) ||
						blockParameter.includes(val),
			},
		],
		result: [
			{
				type: "object",
				description: "Cache Removed status or error",
			},
		],
	},
	{
		name: "admin_logsRepairCache",
		description: "Repairs cached logs by fixing all segments starting with the specified block number",
		params: [
			{
				name: "startBlock",
				type: "string",
				description: "decimal index of the starting block to fix; defaults to the head block",
				optional: true,
				validate: (val) => val === undefined || /^\d+$/.test(val),
			},
		],
		result: [
			{
				type: "object",
				description: "status of the repair request; Started or Already running",
			},
		],
	},
	{
		name: "admin_nodeInfo",
		description: "Returns networking information about the node The information includes general information about the node and specific information from each running Ethereum sub-protocol (for example, eth)",
		note: "If the node is running locally, the host of the enode and listenAddr display as [::] in the result. When advertising externally, the external address displayed for the enode and listenAddr is defined by --nat-method",
		params: [],
		result: [
			{
				type: "object",
				description: "node object with the following fields",
				properties: [
					{
						name: "enode",
						type: "string",
						description: "enode URL of the node",
					},
					{
						name: "listenAddr",
						type: "string",
						description: "host and port for the node",
					},
					{
						name: "name",
						type: "string",
						description: "client name",
					},
					{
						name: "id",
						type: "string",
						description: "node public key",
					},
					{
						name: "ports",
						type: "object",
						description: "peer discovery and listening ports",
					},
					{
						name: "protocols",
						type: "object",
						description: "list of objects containing information for each Ethereum sub-protocol",
					},
				],
			},
		],
	},
	{
		name: "admin_peers",
		description: "Returns networking information about connected remote nodes",
		params: [],
		result: [
			{
				type: "array",
				description: "list of objects returned for each remote node, with the following fields",
				items: {
					type: "object",
					properties: [
						{
							name: "version",
							type: "string",
							description: "P2P protocol version",
						},
						{
							name: "name",
							type: "string",
							description: "client name",
						},
						{
							name: "caps",
							type: "array",
							description: "list of Ethereum sub-protocol capabilities",
						},
						{
							name: "network",
							type: "object",
							description: "local and remote addresses established at time of bonding with the peer (the remote address might not match the hex value for port; it depends on which node initiated the connection)",
						},
						{
							name: "port",
							type: "string",
							description: "port on the remote node on which P2P discovery is listening",
						},
						{
							name: "id",
							type: "string",
							description: "node public key (excluding the 0x prefix, the node public key is the ID in the enode URL enode://<id ex 0x>@<host>:<port>)",
						},
						{
							name: "protocols",
							type: "object",
							description: "current state of peer including difficulty and head (head is the hash of the highest known block for the peer)",
						},
						{
							name: "enode",
							type: "string",
							description: "enode URL of the remote node",
						},
					],
				},
			},
		],
	},
	{
		name: "admin_removePeer",
		description: "Removes a static node",
		params: [
			{
				name: "enode",
				type: "string",
				description: "enode URL of peer to remove",
				optional: false,
				validate: (val) => /^enode:\/\/[0-9a-fA-F]{128}@((?:\d{1,3}\.){3}\d{1,3}|(?:[0-9a-fA-F:]+)|[a-zA-Z0-9.-]+):[0-9]{1,5}$/.test(val),
			},
		],
		result: [
			{
				type: "boolean",
				description: "true if peer removed or false if peer not a static node",
			},
		],
	},
	{
		name: "net_enode",
		description: "Returns the enode URL.",
		params: [],
		result: [
			{
				type: "string",
				description: "enode URL of the node",
			},
		],
	},
	{
		name: "net_listening",
		description: "Whether the client is actively listening for network connections.",
		params: [],
		result: [
			{
				type: "boolean",
				description: "indicates if the client is actively listening for network connections",
			},
		],
	},
	{
		name: "net_peerCount",
		description: "Returns the number of peers currently connected to the client.",
		params: [],
		result: [
			{
				type: "string",
				description: "number of connected peers in hexadecimal",
			},
		],
	},
	{
		name: "net_services",
		description: "Returns enabled services (for example, jsonrpc) and the host and port for each service.",
		note: "The --nat-method setting affects the JSON-RPC and P2P host and port values, but not the metrics host and port values.",
		params: [],
		result: [
			{
				type: "object",
				description: "enabled services",
			},
		],
	},
	{
		name: "net_version",
		description: "Returns the network ID.",
		params: [],
		result: [
			{
				type: "string",
				description: "current network ID",
			},
		],
	},
		{
		name: "qbft_discardValidatorVote",
		description: "Discards a proposal to add or remove a validator with the specified address.",
		params: [],
		result: [
			{
				type: "string",
				description: "current network ID",
			},
		],
	},
		{
		name: "net_version",
		description: "Returns the network ID.",
		params: [],
		result: [
			{
				type: "string",
				description: "current network ID",
			},
		],
	},
		{
		name: "net_version",
		description: "Returns the network ID.",
		params: [],
		result: [
			{
				type: "string",
				description: "current network ID",
			},
		],
	},
];

export async function generateToken(username, password, url) {
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

		console.log(url);
		const loginData = await loginResponse.json();
		console.log(loginData);
		const token = loginData.token;
		if (!token) {
			console.log("Échec de l'authentification.");
			message("Échec de l'authentification.", "red");
			return;
		} else {
			sessionStorage.setItem("token", token);

			console.log("Token récupéré:", token);
			message("", "green");
		}
	} catch (error) {
		console.error(error);
		console.log("Erreur lors de la requête.");
		message("Erreur lors de la requête.", "red");
	}

}


async function tokenValidation() {
	const token = sessionStorage.getItem("token");
	if (!token) {
		window.location.href = "/connexion";
		return;
	}

	if (jwtDecode(token).exp < Date.now() / 1000) {
		const username = sessionStorage.getItem("username");
		const password = sessionStorage.getItem("password");
		const url = sessionStorage.getItem("url");

		if(!username || !password || !url) {
			window.location.href = "/connexion";
			return ;	
		}

		await generateToken(username, password, url);
	}
}


export function message(text, color) {
	document.getElementById("error").innerHTML = text;
	document.getElementById("error").style.color = color;
}


export async function sendRPC(method, paramList) {
	try {
		await tokenValidation();

		const url = sessionStorage.getItem("url");
		const token = sessionStorage.getItem("token");

		if (!url || !token) {
			window.location.href = "/connexion";
			return;
		}

		const rpcBody = {
			jsonrpc: "2.0",
			method: method,
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

		if(!rpcData.result) {
			message(rpcData.error.message, "red");
			return null;
		}

		return rpcData.result;

	} catch(error) {
		console.log(error);
		return null;
	}
}



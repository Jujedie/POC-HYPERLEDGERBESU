package GestBesu.Metier;

import java.util.ArrayList;

public class Metier {
	private static String cheminData = "./besu-node/";

	private ArrayList<Noeud> lstNoeuds;
	private String ipAdress;
	private int portRpc;
	private String username;
	private String password;

	public Metier() {
		this.lstNoeuds  = new ArrayList<Noeud>();
		this.ipAdress   = "127.0.0.1";
		this.portRpc    = 8545;
		this.username   = "Allan";
		this.password   = "Allan";
	}

	public static String getCheminData() {return Metier.cheminData;}
	public ArrayList<Noeud> getLstNoeuds() {return lstNoeuds;}
	public String getIpAdress() {return ipAdress;}
	public int getPortRpc() {return portRpc;}
	public String getUsername() {return username;}
	public String getPassword() {return password;}

	public static void setCheminData(String cheminData         ) {Metier.cheminData = cheminData;}
	public void setLstNoeuds (ArrayList<Noeud> lstNoeuds) {this.lstNoeuds = lstNoeuds;}
	public void setIpAdress(String ipAdress) {this.ipAdress = ipAdress;}
	public void setPortRpc (int portRpc    ) {this.portRpc = portRpc;}
	public void setUsername(String username) {this.username = username;}
	public void setPassword(String password) {this.password = password;}

	public void majNoeuds() {
		Runtime.getRuntime().exec(new String[]{"/bin/sh -c", "cd " + cheminData + "script && ./rpc.sh --ip " + ipAdress + " --port " + portRpc + " --password " + password + " " + username + "admin_peers"});
	}
}

package GestBesu.Metier;

import java.util.ArrayList;


public class Metier {
	private ArrayList<Noeud> lstNoeuds;
	private String cheminData;
	private String ipAdress;
	private int portRpc;
	private String username;
	private String password;

	public Metier() {
		this.lstNoeuds  = new ArrayList<Noeud>();
		this.cheminData = "";
		this.ipAdress   = "127.0.0.1";
		this.portRpc    = 8545;
		this.username   = "Allan";
		this.password   = "Allan";
	}

	public ArrayList<Noeud> getLstNoeuds() {return lstNoeuds;}
	public String getCheminData() {return cheminData;}
	public String getIpAdress() {return ipAdress;}
	public int getPortRpc() {return portRpc;}
	public String getUsername() {return username;}
	public String getPassword() {return password;}

	public void setLstNoeuds (ArrayList<Noeud> lstNoeuds) {this.lstNoeuds = lstNoeuds;}
	public void setCheminData(String cheminData         ) {this.cheminData = cheminData;}
	public void setIpAdress(String ipAdress) {this.ipAdress = ipAdress;}
	public void setPortRpc (int portRpc    ) {this.portRpc = portRpc;}
	public void setUsername(String username) {this.username = username;}
	public void setPassword(String password) {this.password = password;}
}

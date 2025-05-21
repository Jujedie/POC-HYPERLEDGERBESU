package GestBesu.Metier;

public class Noeud {
	private String  adresse;
	private String  enode;
	private boolean estValidateur;

	public Noeud(String adresse, String enode, boolean estValidateur) {
		this.adresse        = adresse;
		this.enode          = enode;
		this.estValidateur  = estValidateur;
	}

	public String getAdresse() {return adresse;}
	public String getEnode() {return enode;}
	public boolean getEstValidateur() {return estValidateur;}
	public String getIp() {
		String[] parts = enode.split("@");
		String adrComplete = parts[1];
		String ip = adrComplete.split(":")[0];
		return ip;
	}
	public String getPort() {
		String[] parts = enode.split("@");
		String adrComplete = parts[1];
		String port = adrComplete.split(":")[1];
		return port;
	}
	public String getPublicKey() {
		String[] parts = enode.split("@");
		String adrComplete = parts[0];
		String publicKey = adrComplete.split("//")[1];
		return publicKey;
	}

	public void setAdresse(String adresse) {this.adresse = adresse;}
	public void setEnode(String enode) {this.enode = enode;}
	public void setEstValidateur(boolean estValidateur) {this.estValidateur = estValidateur;}
	
	public String toString() {
		return "Noeud [adresse= " + adresse + ", enode= " + enode + ", estValidateur=" + estValidateur + ", IP:PORT= " + this.getIp()+":"+this.getPort() + ", PublicKey= " + this.getPublicKey() + "]";
	}
}

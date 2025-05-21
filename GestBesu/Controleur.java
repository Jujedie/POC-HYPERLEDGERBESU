package GestBesu;

import GestBesu.Metier.Metier;

public class Controleur {
	private Metier metier;

	public Controleur() {
		this.metier = new Metier();
	}

	public Metier getMetier() {
		return metier;
	}

	public static void main(String[] args) {
		// Créer une instance de la classe Controleur
		Controleur controleur = new Controleur();
		controleur.getMetier().majNoeuds();

		// Créer une instance de la classe FramePrincipale
		//Vue.FramePrincipale framePrincipale = new Vue.FramePrincipale(controleur);

		// Afficher la fenêtre principale
		//framePrincipale.setVisible(true);
	}
}
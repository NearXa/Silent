# Silent

**Silent** est un scanner de ports furtif et personnalisable.
Il utilise `hping3`, `nc` et d’autres outils natifs pour détecter avec précision et discrétion les ports ouverts, fermés et filtrés.

Développé en solo par **NearXa**.

---

## 🚀 Fonctionnalités

* **Scan SYN furtif** avec des flags sur-mesure (`hping3`)
* **Délai ajustable** entre chaque sonde (`-d <secondes>`)
* **Mode super-furtif** : ordre de ports aléatoire et intervalles de délai dynamiques (`-s`)
* **Sortie verbeuse** pour suivre le scan en temps réel (`-v`)
* **Fichiers de log auto-générés** nommés `Silent_<IP>_<YYYYMMDD_HHMMSS>.log`
* **Détection des ports filtrés** via la logique RST/ACK

---

## 📋 Prérequis

Assure-toi d’avoir les outils suivants installés :

* `bash`
* `hping3`
* `netcat` (`nc`)
* `awk`
* `timeout`
* `bc` (pour des calculs de délais précis)

**Sous Debian/Ubuntu :**

```bash
sudo apt-get update && sudo apt-get install -y hping3 netcat-core coreutils gawk bc
```

---

## ⚙️ Utilisation

```bash
./silent.sh [options] <IP> <port_début> <port_fin>
```

|   Option   | Description                                                    |
| :--------: | :------------------------------------------------------------- |
| `-d <sec>` | Définit un délai fixe entre chaque sonde (par défaut : `0.1`). |
|    `-s`    | Mode super-furtif : séquence de ports et délais aléatoires.    |
|    `-v`    | Mode verbeux : affiche chaque port au moment du scan.          |
|    `-h`    | Affiche l’aide et quitte.                                      |

**Exemples**

* **Scan basique** des ports 20 à 80 sur `192.168.1.10` :

  ```bash
  ./silent.sh 192.168.1.10 20 80
  ```

* **Délai personnalisé** de 200 ms :

  ```bash
  ./silent.sh -d 0.2 192.168.1.10 20 80
  ```

* **Mode super-furtif** :

  ```bash
  ./silent.sh -s 10.0.0.5 1 1024
  ```

* **Mode verbeux** :

  ```bash
  ./silent.sh -v 10.0.0.1 1 500
  ```

---

> “Silence is the mother of truth” - Benjamin Disraeli